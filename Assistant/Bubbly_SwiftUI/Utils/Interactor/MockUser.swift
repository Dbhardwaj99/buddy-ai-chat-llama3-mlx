//
//  Mockuser.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import Foundation

struct MockUser: Codable, Equatable {
    let uid: String
    let name: String
    let avatar: URL?

    static let global = GlobalUser.shared

    init(uid: String, name: String, avatar: URL? = nil) {
        self.uid = uid
        self.name = name
        self.avatar = avatar
    }
    
    static var current: MockUser {
        return MockUser(uid: global.uid, name: global.name, avatar: global.avatar)
    }
}

extension MockUser {
    var isCurrentUser: Bool {
        uid == "1"
    }
}

extension MockUser {
    func toChatUser() -> User {
        User(id: uid, name: name, avatarURL: avatar, isCurrentUser: isCurrentUser)
    }
}
