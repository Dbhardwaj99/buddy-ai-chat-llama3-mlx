//
//  BubblyViewModel.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import Foundation
import Combine

final class BubblyViewModel: ObservableObject {
    @Published var messages: [Message] = []
    
    var chatTitle: String = "Assistant"

    var chatCover: URL? = AssetExtractor.createLocalUrl(forImageNamed: "bubbly")!
    private let interactor: ChatInteractorProtocol
    private var subscriptions = Set<AnyCancellable>()

    init(interactor: ChatInteractorProtocol = BubblyChatInteractor()) {
        self.interactor = interactor
    }

    func send(draft: DraftMessage) {
        interactor.send(draftMessage: draft, user: MockUser(uid: "1", name: "Tim"))
    }
    
    func onStart() {
        interactor.makeFirstMessage()
//        send(draft: interactor.makeFirstMessage())
        if #available(iOS 14.0, *) {
            interactor.messages
                .compactMap { messages in
                    messages.map { $0.toChatMessage() }
                }
                .assign(to: &$messages)
        } else {
            // Fallback on earlier versions
        }

        interactor.connect()
    }

    func onStop() {
        interactor.disconnect()
    }

    func loadMoreMessage(before message: Message) {
        interactor.loadNextPage()
            .sink { _ in }
            .store(in: &subscriptions)
    }
}
