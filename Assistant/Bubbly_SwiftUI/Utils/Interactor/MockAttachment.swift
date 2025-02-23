//
//  MockAttachment.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import Foundation

public struct MockImage : Codable {
    let id: String
    let thumbnail: URL
    let full: URL

    func toChatAttachment() -> Attachment {
            Attachment(id: id, thumbnail: thumbnail, full: full, type: .image)
        }
}

public struct MockVideo : Codable {
    let id: String
    let thumbnail: URL
    let full: URL

    func toChatAttachment() -> Attachment {
        Attachment(
            id: id,
            thumbnail: thumbnail,
            full: full,
            type: .video
        )
    }
}
