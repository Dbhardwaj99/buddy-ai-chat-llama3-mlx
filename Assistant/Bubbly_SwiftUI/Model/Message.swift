//
//  Message.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import SwiftUI

public struct Message: Identifiable, Hashable, Codable {

    public enum Status: Equatable, Hashable, Codable {
        case sending
        case sent
        case read
        case error(DraftMessage)

        public func hash(into hasher: inout Hasher) {
            switch self {
            case .sending:
                return hasher.combine("sending")
            case .sent:
                return hasher.combine("sent")
            case .read:
                return hasher.combine("read")
            case .error:
                return hasher.combine("error")
            }
        }

        public static func == (lhs: Message.Status, rhs: Message.Status) -> Bool {
            switch (lhs, rhs) {
            case (.sending, .sending):
                return true
            case (.sent, .sent):
                return true
            case (.read, .read):
                return true
            case ( .error(_), .error(_)):
                return true
            default:
                return false
            }
        }
    }

    public var id: String
    public var user: User
    public var status: Status?
    public var createdAt: Date

    public var text: String
    public var attachments: Attachment? = nil

    public var triggerRedraw: UUID?

    public init(id: String,
                user: User,
                status: Status? = nil,
                createdAt: Date = Date(),
                text: String = "",
                attachments: Attachment? = nil) {

        self.id = id
        self.user = user
        self.status = status
        self.createdAt = createdAt
        self.text = text
        self.attachments = attachments
    }

    
    public static func makeMessage(
        id: String,
        user: User,
        status: Status? = nil,
        draft: DraftMessage
    ) async -> Message {
        // Determine the attachment: prioritize video over image
        let attachment: Attachment? = await {
            if let videoMedia = draft.video {
                return videoMedia.toChatAttachment()
            } else if let imageMedia = draft.image {
                return imageMedia.toChatAttachment()
            }
            return nil
        }()

        // Construct and return the message
        return Message(
            id: id,
            user: user,
            status: status,
            createdAt: draft.createdAt,
            text: draft.text,
            attachments: attachment
        )
    }
    
//    public static func makeMessage(
//        id: String,
//        user: User,
//        status: Status? = nil,
//        draft: DraftMessage
//    ) async -> Message {
//        let attachments = await { () -> [Attachment] in
//            guard let imageMedia = draft.image else {
//                return []
//            }
//            
//            guard let videoMedia = draft.video else {
//                return []
//            }
//            
//            let imagethumbnailURL = imageMedia.thumbnail
//            
//            
////            guard let videothumbnailURL = await videoMedia.thumbnail else {
////                return []
////            }
//
//            
//            return [Attachment(id: UUID().uuidString, url: imagethumbnailURL, type: .image)]
////            case .video:
////                guard let fullURL = await media.getURL() else {
////                    return []
////                }
////                return [Attachment(id: UUID().uuidString, thumbnail: thumbnailURL, full: fullURL, type: .video)]
////            }
//        }()
//
//        // Use the first attachment if it exists, or provide a default/placeholder
//        let attachment = attachments.first ?? Attachment(id: UUID().uuidString, url: URL(string: "https://example.com/placeholder.png")!, type: .image)
//
//        // Construct and return the message
//        return Message(
//            id: id,
//            user: user,
//            status: status,
//            createdAt: draft.createdAt,
//            text: draft.text,
//            attachments: attachment
//        )
//    }
}

extension Message {
    var time: String {
        DateFormatter.timeFormatter.string(from: createdAt)
    }
}

extension Message: Equatable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.user == rhs.user &&
        lhs.status == rhs.status &&
        lhs.createdAt == rhs.createdAt &&
        lhs.text == rhs.text &&
        lhs.attachments == rhs.attachments
    }
}

extension Sequence {
    func asyncCompactMap<T>(
        _ transform: (Element) async throws -> T?
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            if let el = try await transform(element) {
                values.append(el)
            }
        }

        return values
    }
}
