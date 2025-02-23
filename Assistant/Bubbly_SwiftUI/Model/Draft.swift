//
//  Created by Alex.M on 17.06.2022.
//

import Foundation

public struct DraftMessage : Codable {
    public var id: String?
    public let text: String
    public let createdAt: Date
    
    public var image: MockImage? = nil
    public var video: MockVideo? = nil

    public init(id: String? = nil, 
                text: String,
                medias: Media? = nil,
                createdAt: Date,
                image: MockImage? = nil,
                video: MockVideo? = nil) {
        self.id = id
        self.text = text
        self.image = image
        self.video = video
        self.createdAt = createdAt
    }
}
