//
//  Models.swift
//  Assistant
//
//  Created by Divyansh Bhardwaj on 23/02/25.
//

import Foundation

import Foundation
import Combine

struct Bot: Codable {
    let avatar: String
    let name: String
    let description: String
}

struct ChatState: Codable {
    let id: String
    var messages: [MockMessage]
    let bot: Bot
}




//class ViewModel: ObservableObject {
//    @Published var currentUser: User?
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        loadUser()
//    }
//    
//    func loadUser() {
//        if let loadedUser = PersistenceManager.shared.loadUser() {
//            currentUser = loadedUser
//        }
//    }
//    
//    func createUser(from profile: UserProfile) {
//        let newUser = User(id: profile.id, name: profile.name ?? "Guest", avatar: "", isPremium: false, chatStates: [])
//        PersistenceManager.shared.saveUser(newUser)
//        currentUser = newUser
//    }
//    
//    func addChatState(bot: Bot) {
//        guard var user = currentUser else { return }
//        PersistenceManager.shared.addChatState(to: &user, bot: bot)
//        currentUser = user
//    }
//    
//    func deleteChatState(chatStateId: String) {
//        guard var user = currentUser else { return }
//        PersistenceManager.shared.deleteChatState(from: &user, chatStateId: chatStateId)
//        currentUser = user
//    }
//}
