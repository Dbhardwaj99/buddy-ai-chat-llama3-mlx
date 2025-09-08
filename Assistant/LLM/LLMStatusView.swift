//
//  LLMStatusView.swift
//  Assistant
//
//  Created by Assistant on 08/09/25.
//

import SwiftUI

struct LLMStatusView: View {
    @State private var modelName: String = LLMEvaluator.shared.modelConfiguration.name
    @State private var isLoading: Bool = false

    var body: some View {
        let evaluator = LLMEvaluator.shared
        VStack(spacing: 20) {
            HStack {
                Text("Model Download")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 8) {
                Text(evaluator.modelInfo.isEmpty ? "Tap Load to start downloading Gemma" : evaluator.modelInfo)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ProgressView(value: evaluator.progress)
                HStack {
                    Text(String(format: "%.0f%%", evaluator.progress * 100))
                        .monospacedDigit()
                    Spacer()
                    Text(evaluator.stat)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)

            HStack(spacing: 12) {
                Button(action: {
                    Task { @MainActor in
                        isLoading = true
                        _ = try? await evaluator.load(modelName: modelName)
                        isLoading = false
                    }
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 44)
                        .foregroundStyle(Color.accentColor)
                        .overlay(
                            Text(isLoading ? "Loading..." : "Load Gemma")
                                .foregroundStyle(.white)
                                .bold()
                        )
                }

                Button(action: {
                    evaluator.stop()
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 44)
                        .foregroundStyle(Color.red)
                        .overlay(
                            Text("Cancel")
                                .foregroundStyle(.white)
                                .bold()
                        )
                }
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .padding(.top, 24)
    }
}

#Preview {
    LLMStatusView()
}


