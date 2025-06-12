//
//  Created by Alex.M on 17.06.2022.
//

import Foundation

public struct User: Codable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let avatarURL: URL?
    public let isCurrentUser: Bool

    public init(id: String, name: String, avatarURL: URL?, isCurrentUser: Bool) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.isCurrentUser = isCurrentUser
    }
}

struct GlobalUser: Codable {
    let id: String
    let name: String
    let avatar: String
    var isPremium: Bool
    var chatStates: [ChatState]
    
    func toUser(isCurrentUser: Bool) -> User {
        return User(id: id, name: name, avatarURL: URL(string: avatar), isCurrentUser: isCurrentUser)
    }
    
    func toMockUser() -> MockUser {
        return MockUser(uid: id, name: name, avatar: URL(string: avatar))
    }
}

struct MockUser: Codable, Equatable {
    let uid: String
    let name: String
    let avatar: URL?

//    static let global = GlobalUser.shared

    init(uid: String, name: String, avatar: URL? = nil) {
        self.uid = uid
        self.name = name
        self.avatar = avatar
    }
    
//    static var current: MockUser {
//        return MockUser(uid: global.uid, name: global.name, avatar: global.avatar)
//    }
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
