//
//  MockMessage.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import Foundation

struct MockMessage : Codable {
    let uid: String
    let sender: MockUser
    let createdAt: Date
    var status: Message.Status?

    let text: String
    let images: MockImage?
    let videos: MockVideo?
}

extension MockMessage {
    func toChatMessage() -> Message {
        // Determine the attachment, prioritize video over image
        let attachment: Attachment? = {
            if let videoAttachment = videos?.toChatAttachment() {
                return videoAttachment
            }
            if let imageAttachment = images?.toChatAttachment() {
                return imageAttachment
            }
            return nil
        }()

        return Message(
            id: uid,
            user: sender.toChatUser(),
            status: status,
            createdAt: createdAt,
            text: text,
            attachments: attachment
        )
    }
}
