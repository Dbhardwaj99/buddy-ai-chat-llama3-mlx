//
//  MockChatInteractor.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import Foundation
import Combine

final class BubblyChatInteractor: ChatInteractorProtocol {
    func makeFirstMessage(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let firstMessage = self.chatData.randomMessage(
                sender: self.BubblyLLM,
                date: Date()
            )
            self.chatState.value.append(firstMessage)
        }
        
        startPolling()
    }
    
    var senders: MockUser?
    private var replyCounter = 0
    
    private var globalUser: GlobalUser
    
    private lazy var chatData = MockChatData()
    
    private lazy var chatState = CurrentValueSubject<[MockMessage], Never>([])
    private lazy var sharedState = chatState.share()
    let userDefaults = UserDefaults.standard
    private let isActive: Bool
    private var isLoading = false
    
    private var pollingManager: PollingManager?
    
    private var subscriptions = Set<AnyCancellable>()
    
    var messages: AnyPublisher<[MockMessage], Never> {
        sharedState.eraseToAnyPublisher()
    }
    
    var requestCount: Int {
        get { return userDefaults.integer(forKey: "request_count") }
        set { userDefaults.set(newValue, forKey: "request_count") }
    }
    
    var successCount: Int {
        get { return userDefaults.integer(forKey: "success_count") }
        set { userDefaults.set(newValue, forKey: "success_count") }
    }
    
    var failedCount: Int {
        get { return userDefaults.integer(forKey: "failed_count") }
        set { userDefaults.set(newValue, forKey: "failed_count") }
    }
    
    private var BubblyLLM: MockUser {
        chatData.steve
    }
    
    private var currentUser: MockUser {
        chatData.tim
    }
    
    init(isActive: Bool = false, gUser: GlobalUser){
        self.isActive = isActive
        self.globalUser = gUser
        
        chatState.value = PersistenceManager.shared.loadMessages()
    }
    
    func send(draftMessage: DraftMessage, user: MockUser) {
        print("Draft message Checkpoint: \(draftMessage)\n\n")
        
        if let id = draftMessage.id {
            if let index = chatState.value.firstIndex(where: { $0.uid == id }) {
                chatState.value.remove(at: index)
            }
        }
        
        Task {
            //            var status: Message.Status = .sending
            //            if Int.random(min: 0, max: 20) == 0 {
            //                status = .error(draftMessage)
            //            }
            let message = await draftMessage.toMockMessage(
                user: currentUser,
                status: .sent
            )
            
            print("message CHECKPOINT: \(message)\n\\n")
            DispatchQueue.main.async { [weak self] in
                self?.chatState.value.append(message)
                PersistenceManager.shared.saveMessages(self?.chatState.value ?? [])
//                self?.randomReplyMessage()
                self?.talkToLLM()
            }
        }
    }
    
    func startPolling() {
        pollingManager = PollingManager()
        pollingManager?.startPolling(interval: 0.5) { [weak self] draftMessage in
            guard let self = self else { return }
            
            self.send(draftMessage: draftMessage, user: self.currentUser)
            
            //                self.randomDraftMessage(sender: BubblyLLM)
        }
    }
    
    
    func connect() {
        Timer.publish(every: 2, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateSendingStatuses()
            }
            .store(in: &subscriptions)
    }
    
    func disconnect() {
        subscriptions.removeAll()
    }
    
    func loadNextPage() -> Future<Bool, Never> {
        Future<Bool, Never> { [weak self] promise in
            guard let self = self, !self.isLoading else {
                promise(.success(false))
                return
            }
            self.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                promise(.success(true))
            }
        }
    }
    
    
    func talkToLLM() {
////        guard let requestMessages = requestMessages(),
////              let encryptedData = BobbleOneWayEncryption().encryptAndSerialize(requestMessages) else {
////            return
////        }
//        guard let requestMessages = requestMessages() else {
//            return
//        }
//
//        do {
//            let encryptedData = (
//                try BobbleOneWayEncryption()
//                    .encryptAndSerialize(requestMessages)
//            )!
//            
//            let startTime = Date()
//            requestCount += 1
//            
//            NetworkManager.shared.hitLLMRequest(fileData: encryptedData) { [weak self] result in
//                guard let self = self else { return }
//                DispatchQueue.main.async {
//                    let latency = Date().timeIntervalSince(startTime)
//                    switch result {
//                    case .success(let responseModel):
//                        self.handleSuccessResponse(responseModel, latency: latency)
//                    case .failure(let error):
//                        self.handleFailureResponse(error,latency: latency)
//                    }
//                }
//            }
//        } catch {
//            print("Encryption failed with error: \(error)")
//        }
    }
    
    
    private func handleSuccessResponse(_ responseModel: LLMResponseModel,latency: TimeInterval) {
        
        successCount += 1
        guard let text = responseModel.data?.text else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let replyMessage = self.chatData.ComposeMessage(
                sender: self.BubblyLLM,
                date: Date(),
                BubblyReply: text
            )
            self.chatState.value.append(replyMessage)
        }
    }
    
    private func handleFailureResponse(_ error: Error,latency: TimeInterval) {
        failedCount += 1

        let apiErrorMessage = fetchErrorMessage()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let replyMessage = self.chatData.ComposeMessage(
                sender: self.BubblyLLM,
                date: Date(),
                BubblyReply: apiErrorMessage
            )
            self.chatState.value.append(replyMessage)
        }
    }
    
    private func fetchErrorMessage() -> String {
//        if NetworkManager.shared.isInternetConnected {
//            if let errorMessages = ConfigRepository().fetchChatBotModel()?.chatbotAssitantSettings?.errorMessagessLocalised,
//               let randomErrorMsg = errorMessages.randomElement() {
//                return randomErrorMsg
//            }
//        }
        return "Low or No Internet Connection"
    }
    
    func requestMessages() -> String? {
        do {
            var newMessages = chatState.value

            let userDefaults = UserDefaults(suiteName: "YOUR_APP_GROUP_ID")
            
            print("ALL MESSAGES: \(newMessages)")
            let jsonData = try JSONEncoder().encode(newMessages)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return nil }
            return jsonString

        } catch {
            print("\(error)")
            return nil
        }
    }
}

private extension BubblyChatInteractor {
    func randomReplyMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let replyMessage = self.chatData.randomMessage(
                sender: self.BubblyLLM,
                date: Date()
            )
            self.chatState.value.append(replyMessage)
        }
    }
    
    func updateSendingStatuses() {
        let updated = chatState.value.map {
            var message = $0
            if message.status == .sending {
                message.status = .sent
            } else if message.status == .sent {
                message.status = .read
            }
            return message
        }
        chatState.value = updated
        
        PersistenceManager.shared.saveMessages(chatState.value)
    }
}

struct FirstMediaModel: MediaModelProtocol {
    var mediaType: MediaType? = .image
    var duration: CGFloat? = nil

    func getURL() async -> URL? {
        URL(string: "https://example.com/media")
    }

    func getThumbnailURL() async -> URL? {
        URL(string: "https://example.com/thumbnail")
    }

    func getData() async throws -> Data? {
        "Sample Media Data".data(using: .utf8)
    }

    func getThumbnailData() async -> Data? {
        "Sample Thumbnail Data".data(using: .utf8)
    }
}
