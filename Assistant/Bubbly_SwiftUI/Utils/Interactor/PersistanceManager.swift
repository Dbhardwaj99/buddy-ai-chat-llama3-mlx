//
//  PersistanceManager.swift
//  Bobble
//
//  Created by Divyansh Bhardwaj on 05/01/25.
//  Copyright © 2025 Touchtalent. All rights reserved.
//

import Foundation

//class PersistenceManager {
//    static let shared = PersistenceManager()
//    
//
//    private init() {}
//
//    func saveMessages(_ messages: [MockMessage]) {
//        let encoder = JSONEncoder()
//        if let data = try? encoder.encode(messages) {
//            UserDefaults.standard.set(data, forKey: chatCacheKey)
//        }
//    }
//
//    func loadMessages() -> [MockMessage] {
//        let decoder = JSONDecoder()
//        if let data = UserDefaults.standard.data(forKey: chatCacheKey),
//           let messages = try? decoder.decode([MockMessage].self, from: data) {
//            return messages
//        }
//        return []
//    }
//
////    func clearMessages() {
////        UserDefaults.standard.removeObject(forKey: chatCacheKey)
////    }
//}


class PersistenceManager {
    static let shared = PersistenceManager()
    var user: GlobalUser?
    private let userCacheKey = "userCache"
    private let chatCacheKey = "chatCache"
    
    private init() {}
    
    func saveUser(_ user: GlobalUser) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(user) {
            UserDefaults.standard.set(data, forKey: userCacheKey)
        }
    }
    
    func createNewUser() {
        let newUser = GlobalUser(id: UUID().uuidString, name: "Guest", avatar: "", isPremium: false, chatStates: [])
        saveUser(newUser)
        self.user = newUser
    }
    
    func loadUser() -> GlobalUser? {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: userCacheKey),
           let user = try? decoder.decode(GlobalUser.self, from: data) {
            self.user = user
            return user
        }
        return nil
    }
    
    func clearUser() {
        UserDefaults.standard.removeObject(forKey: userCacheKey)
    }
    
    func addChatState(to user: inout GlobalUser, bot: Bot) {
        let newChatState = ChatState(id: UUID().uuidString, messages: [], bot: bot)
        user.chatStates.append(newChatState)
        saveUser(user)
    }
    
    func deleteChatState(from user: inout GlobalUser, chatStateId: String) {
        user.chatStates.removeAll { $0.id == chatStateId }
        saveUser(user)
    }
    
    func getCurrentState() -> ChatState? {
        return user?.chatStates.last
    }
    
    func saveCurrentState() {
        if let user = user {
            saveUser(user)
        }
    }
    
    func saveMessages(_ messages: [MockMessage]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(messages) {
            UserDefaults.standard.set(data, forKey: chatCacheKey)
        }
    }

    func loadMessages() -> [MockMessage] {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: chatCacheKey),
           let messages = try? decoder.decode([MockMessage].self, from: data) {
            return messages
        }
        return []
    }
}
