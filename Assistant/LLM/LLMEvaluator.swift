//
//  LLMEvaluator.swift
//  Assistant
//
//  Created by MacBook Pro on 07/09/25.
//

import Foundation
import MLX
import MLXLLM
import MLXLMCommon
import MLXRandom
import SwiftUI

enum LLMEvaluatorError: Error {
    case modelNotFound(String)
}

@Observable
@MainActor
class LLMEvaluator {
    static let shared = LLMEvaluator()
    var running = false
    var cancelled = false
    var output = ""
    var modelInfo = ""
    var stat = ""
    var progress = 0.0
    var thinkingTime: TimeInterval?
    var collapsed: Bool = false
    var isThinking: Bool = false
    var lastModelPath: String?

    var elapsedTime: TimeInterval? {
        if let startTime {
            return Date().timeIntervalSince(startTime)
        }

        return nil
    }

    private var startTime: Date?

    var modelConfiguration = ModelConfiguration.defaultModel

    func switchModel(_ model: ModelConfiguration) async {
        progress = 0.0 // reset progress
        loadState = .idle
        modelConfiguration = model
        _ = try? await load(modelName: model.name)
    }

    /// parameters controlling the output
    let generateParameters = GenerateParameters(temperature: 0.9)
    let maxTokens = 4096

    /// update the display every N tokens -- 4 looks like it updates continuously
    /// and is low overhead.  observed ~15% reduction in tokens/s when updating
    /// on every token
    let displayEveryNTokens = 4

    enum LoadState {
        case idle
        case loaded(ModelContainer)
    }

    var loadState = LoadState.idle
    var downloadMessage: String {
        switch loadState {
        case .idle:
            return modelInfo.isEmpty ? "Idle" : modelInfo
        case .loaded:
            return modelInfo
        }
    }

    /// Resolve a local weights directory for a given model configuration, if it exists.
    /// We consider a path local if it points to a folder containing model.safetensors.
    private func resolveLocalWeightsURL(for model: ModelConfiguration) -> URL? {
        // Try interpreting configuration.id as a filesystem path
        let candidatePaths: [URL] = {
            var urls: [URL] = []
            let idString = "\(model.id)" // Convert Identifier to String
            // If id looks like a file URL
            if let asURL = URL(string: idString), asURL.scheme == "file" {
                urls.append(asURL)
            }
            // Treat id as a plain path
            urls.append(URL(fileURLWithPath: idString))
            // Try within the app bundle resources
            if let bundleURL = Bundle.main.resourceURL {
                urls.append(bundleURL.appendingPathComponent(model.name))
                // Also try using lastPathComponent of id
                urls.append(bundleURL.appendingPathComponent(URL(fileURLWithPath: idString).lastPathComponent))
            }
            return urls
        }()

        let fm = FileManager.default
        for url in candidatePaths {
            var isDir: ObjCBool = false
            if fm.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                // Ensure the expected weights file exists in this directory
                let weights = url.appendingPathComponent("model.safetensors")
                if fm.fileExists(atPath: weights.path) {
                    return url
                }
            }
        }
        return nil
    }

    /// load and return the model -- can be called multiple times, subsequent calls will
    /// just return the loaded model
    func load(modelName: String) async throws -> ModelContainer {
        guard let model = ModelConfiguration.getModelByName(modelName) else {
            throw LLMEvaluatorError.modelNotFound(modelName)
        }

        switch loadState {
        case .idle:
            // limit the buffer cache
            MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)

            // If we have local weights, indicate that we're loading locally
            if let localURL = resolveLocalWeightsURL(for: model) {
                Task { @MainActor in
                    self.modelInfo = "Loading \(model.name) from local weights at \(localURL.lastPathComponent)..."
                    self.progress = 0.0
                }
                print("[LLM] Using local weights at: \(localURL.path)")
                lastModelPath = localURL.path
            } else {
                print("[LLM] No local weights found. Using remote repository: \(model.id)")
                lastModelPath = "repo://\(model.id)"
            }

            let modelContainer = try await LLMModelFactory.shared.loadContainer(configuration: model) { progress in
                Task { @MainActor in
                    // Use a generic message here; if it's local, this closure is unlikely to be called.
                    self.modelInfo = "Loading \(model.name): \(Int(progress.fractionCompleted * 100))%"
                    self.progress = progress.fractionCompleted
                }
            }
            Task { @MainActor in
                self.modelInfo = "Loaded \(model.name). Weights: \(MLX.GPU.activeMemory / 1024 / 1024)M"
                self.progress = 1.0
            }
            // Log where we believe weights came from / are stored
            if let localURL = resolveLocalWeightsURL(for: model) {
                print("[LLM] Loaded weights from: \(localURL.path)")
                lastModelPath = localURL.path
            } else {
                let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.path ?? "<unknown>"
                print("[LLM] Loaded remote model: \(model.name) (repo: \(model.id)). Cache directory: \(caches)")
                lastModelPath = "repo://\(model.id)"
            }
            loadState = .loaded(modelContainer)
            return modelContainer

        case let .loaded(modelContainer):
            return modelContainer
        }
    }

    func stop() {
        isThinking = false
        cancelled = true
    }

    func generate(modelName: String, thread: Thread, systemPrompt: String) async -> String {
        guard !running else { return "" }

        running = true
        cancelled = false
        output = ""
        startTime = Date()

        do {
            let modelContainer = try await load(modelName: modelName)

            // augment the prompt as needed
            let promptHistory = await modelContainer.configuration.getPromptHistory(thread: thread, systemPrompt: systemPrompt)

            if await modelContainer.configuration.modelType == .reasoning {
                isThinking = true
            }

            // each time you generate you will get something new
            MLXRandom.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))

            let generationStart = Date()
            let result = try await modelContainer.perform { context in
                let input = try await context.processor.prepare(input: .init(messages: promptHistory))
                return try MLXLMCommon.generate(
                    input: input, parameters: generateParameters, context: context
                ) { tokens in

                    var cancelled = false
                    Task { @MainActor in
                        cancelled = self.cancelled
                    }

                    // update the output -- this will make the view show the text as it generates
                    if tokens.count % displayEveryNTokens == 0 {
                        let text = context.tokenizer.decode(tokens: tokens)
                        
                        Task { @MainActor in
                            let cleaned = sanitize(text)
                            self.output = cleaned
                            let elapsed = Date().timeIntervalSince(generationStart)
                            if elapsed > 0 {
                                let rate = Double(tokens.count) / elapsed
                                self.stat = " Tokens/second: " + String(format: "%.2f", rate)
                                print(String(format: "[LLM] %d tokens, %.2f tok/s", tokens.count, rate))
                            }
                        }
                    }

                    if tokens.count >= maxTokens || cancelled {
                        return .stop
                    } else {
                        return .more
                    }
                }
            }

            // update the text if needed, e.g. we haven't displayed because of displayEveryNTokens
            if result.output != output {
                output = sanitize(result.output)
            }
            stat = " Tokens/second: \(String(format: "%.3f", result.tokensPerSecond))"

        } catch {
            output = "Failed: \(error)"
        }

        running = false
        print(output)
        return output
    }
    
    func sanitize(_ text: String) -> String {
        var cleaned = text
        if let range = cleaned.range(of: "<end_of_turn>") {
            cleaned = String(cleaned[..<range.lowerBound])
        }
        let unwanted = ["<end_of_turn>", "<eot>", "<eot_id>", "<|eot_id|>", "<end_of_turn>\n"]
        for marker in unwanted {
            cleaned = cleaned.replacingOccurrences(of: marker, with: "")
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


public extension ModelConfiguration {
    enum ModelType {
        case regular, reasoning
    }

    var modelType: ModelType {
        .regular
    }
}

extension ModelConfiguration: @retroactive Equatable {
    public static func == (lhs: MLXLMCommon.ModelConfiguration, rhs: MLXLMCommon.ModelConfiguration) -> Bool {
        return lhs.name == rhs.name
    }

    /// Hugging Face Gemma model (MLX format). MLXLLM will download/cache weights and provide progress.
    public static var gemma_hf: ModelConfiguration {
        let repoId = "mlx-community/gemma-3-1b-it-4bit"
        return ModelConfiguration(
            id: repoId,
            tokenizerId: repoId,
            overrideTokenizer: nil,
            defaultPrompt: "",
            extraEOSTokens: ["<end_of_turn>"]
        )
    }

    /// Optional: local Gemma directory if bundled alongside the app
    public static var gemma_local: ModelConfiguration {
        let localURL = (Bundle.main.resourceURL ?? URL(fileURLWithPath: ".")).appendingPathComponent("Gemma")
        let localPath = localURL.path
        return ModelConfiguration(
            id: localPath,
            tokenizerId: localPath,
            overrideTokenizer: nil,
            defaultPrompt: "",
            extraEOSTokens: ["<end_of_turn>"]
        )
    }

    public static var availableModels: [ModelConfiguration] = [
        gemma_hf,
        gemma_local,
    ]

    public static var defaultModel: ModelConfiguration {
        gemma_hf
    }

    public static func getModelByName(_ name: String) -> ModelConfiguration? {
        if let model = availableModels.first(where: { $0.name == name }) {
            return model
        } else {
            return nil
        }
    }

    func getPromptHistory(thread: Thread, systemPrompt: String) -> [[String: String]] {
        var history: [[String: String]] = []

        // Build alternating user/assistant turns; merge consecutive same-role messages
        var lastRole: String = "assistant" // so first appended user message won't merge
        var isFirstUserTurn = true

        for message in thread.sortedMessages {
            let role = message.role.rawValue
            let content = formatForTokenizer(message.content).trimmingCharacters(in: .whitespacesAndNewlines)

            // Skip empty messages
            if content.isEmpty { continue }

            var finalContent = content
            if role == "user" && isFirstUserTurn {
                // Inline system instruction into the first user message to avoid standalone system turns
                finalContent = systemPrompt + "\n\n" + content
                isFirstUserTurn = false
            }

            if role == lastRole, var last = history.popLast() {
                // Merge with previous same-role turn
                let merged = (last["content"] ?? "") + "\n\n" + finalContent
                last["content"] = merged
                history.append(last)
            } else {
                history.append(["role": role, "content": finalContent])
                lastRole = role
            }
        }

        return history
    }

    // TODO: Remove this function when Jinja gets updated
    func formatForTokenizer(_ message: String) -> String {
        if modelType == .reasoning {
            let pattern = "<think>.*?(</think>|$)"
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
                let range = NSRange(location: 0, length: message.utf16.count)
                let formattedMessage = regex.stringByReplacingMatches(in: message, options: [], range: range, withTemplate: "")
                return " " + formattedMessage
            } catch {
                return " " + message
            }
        }
        return message
    }

    /// Remove special control tokens and end markers that should not appear in the UI.
    public static func sanitize(_ text: String) -> String {
        var cleaned = text
        if let range = cleaned.range(of: "<end_of_turn>") {
            cleaned = String(cleaned[..<range.lowerBound])
        }
        let unwanted = ["<end_of_turn>", "<eot>", "<eot_id>", "<|eot_id|>", "<end_of_turn>\n"]
        for marker in unwanted {
            cleaned = cleaned.replacingOccurrences(of: marker, with: "")
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns the model's approximate size, in GB.
    public var modelSize: Decimal? {
        // Try to compute the installed Gemma weights size; fallback to a reasonable default
        if let weightsURL = Bundle.main.resourceURL?.appendingPathComponent("Gemma").appendingPathComponent("model.safetensors"),
           let attributes = try? FileManager.default.attributesOfItem(atPath: weightsURL.path),
           let fileSize = attributes[.size] as? NSNumber {
            let bytes = fileSize.doubleValue
            let gigabytes = bytes / 1024.0 / 1024.0 / 1024.0
            return Decimal(gigabytes)
        }
        return 1.5
    }
}


class MessageLLM {
    var id: UUID
    var role: Role
    var content: String
    var timestamp: Date
    var generatingTime: TimeInterval?
    
    var thread: Thread?
    
    init(role: Role, content: String, thread: Thread? = nil, generatingTime: TimeInterval? = nil) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.thread = thread
        self.generatingTime = generatingTime
    }
}


final class Thread: Sendable {
    var id: UUID
    var title: String?
    var timestamp: Date
    
    var messages: [MessageLLM] = []
    
    var sortedMessages: [MessageLLM] {
        return messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    init() {
        self.id = UUID()
        self.timestamp = Date()
    }
}
