//
//  ChatInteractorProtocol.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import Foundation
import Combine

protocol ChatInteractorProtocol {
    var messages: AnyPublisher<[MockMessage], Never> { get }
//    var senders: MockUser? {/* */get }
    
    func send(draftMessage: DraftMessage, user: MockUser)

    func connect()
    func disconnect()
    func makeFirstMessage()

    func loadNextPage() -> Future<Bool, Never>
}
