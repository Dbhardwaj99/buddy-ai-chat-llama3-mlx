//
//  Created by Alex.M on 17.06.2022.
//

import Foundation

struct User: Codable, Equatable, Hashable {
    let id: String
    let name: String
    let avatarURL: URL?
    let isCurrentUser: Bool
    
    init(from globalUser: GlobalUser, isCurrentUser: Bool) {
        self.id = globalUser.id
        self.name = globalUser.name
        self.avatarURL = URL(string: globalUser.avatar)
        self.isCurrentUser = isCurrentUser
    }
}

struct GlobalUser: Codable {
    let id: String
    let name: String
    let avatar: String
    var isPremium: Bool
    var chatStates: [ChatState]
}
