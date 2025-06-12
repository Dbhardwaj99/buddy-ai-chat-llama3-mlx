//
//  Created by Alex.M on 27.06.2022.
//

import Foundation
import UIKit

final class MockChatData {

    // Alternative for avatars `https://ui-avatars.com/api/?name=Tim`
    let system = MockUser(uid: "0", name: "System")
    let tim = MockUser(
        uid: "1",
        name: "Tim"
//        avatar: AssetExtractor.createLocalUrl(forImageNamed: "tim")!
    )
    let steve = MockUser(
        uid: "2",
        name: "Steve",
        avatar: AssetExtractor.createLocalUrl(forImageNamed: "bubbly")!
    )
//    let bob = MockUser(
//        uid: "3",
//        name: "Bob",
//        avatar: AssetExtractor.createLocalUrl(forImageNamed: "bob")!
//    )

    func randomMessage(sender: MockUser, date: Date? = nil, includeImage: Bool = false) -> MockMessage {
        let date = date ?? Date()
        let images = includeImage ? randomMockImage() : nil // Only include image if flag is true

        let shouldGenerateText = images == nil ? true : .random()

        return MockMessage(
            uid: UUID().uuidString,
            sender: sender,
            createdAt: date,
            status: sender.isCurrentUser ? .read : nil,
            text: shouldGenerateText ? Lorem.sentence(nbWords: Int.random(in: 100...1000), useMarkdown: true) : "",
            images: images,
            videos: nil
        )
    }
    
    func ComposeMessage(sender: MockUser, date: Date? = nil, BubblyReply: String) -> MockMessage {
        let date = date ?? Date()

        return MockMessage(
            uid: UUID().uuidString,
            sender: sender,
            createdAt: date,
            status: sender.isCurrentUser ? .read : nil,
            text: BubblyReply,
            images: nil,
            videos: nil
        )
    }

    func randomImages() -> MockImage? {
        guard Int.random(min: 0, max: 10) == 0 else {
            return nil
        }
        
        return randomMockImage()
    }

    func randomMockImage() -> MockImage {
        let color = randomColorHex()
        return MockImage(
            id: UUID().uuidString,
            thumbnail: URL(string: "https://via.placeholder.com/150/\(color)")!,
            full: URL(string: "https://via.placeholder.com/600/\(color)")!
        )
    }
    
//    func randomMockImageURL() -> URL {
//        let color = randomColorHex()
//        
//        thumbnail: URL(string: "https://via.placeholder.com/150/\(color)")!,
//        full: URL(string: "https://via.placeholder.com/600/\(color)")!
//    }

    func randomColorHex() -> String {
        (0...6)
            .map { _ in randomHexChar() }
            .joined()
    }
}

private extension MockChatData {
    func randomHexChar() -> String {
        let letters = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
        return letters.random()!
    }
}

class AssetExtractor {

    static func createLocalUrl(forImageNamed name: String) -> URL? {

        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("\(name).pdf")

        guard fileManager.fileExists(atPath: url.path) else {
            guard
                let image = UIImage(named: name),
                let data = image.pngData()
            else { return nil }

            fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
            return url
        }

        return url
    }
}

extension DraftMessage {
//    func makeMockImage() async -> MockImage? {
//        guard let media = medias, media.type == .image else {
//            print("Media is nil or not of type image")
//            return nil
//        }
//        
//        let thumbnail = await media.getThumbnailURL()
//        let full = await media.getURL()
//        
//        guard let thumbnail = thumbnail, let full = full else {
//            print("Failed to fetch URLs for media")
//            return nil
//        }
//        
//        return MockImage(id: media.id.uuidString, thumbnail: thumbnail, full: full)
//    }

//    func makeMockVideo() async -> MockVideo? {
//        await medias
//            .filter { $0.type == .video }
//            .asyncMap { (media: Media) -> (Media, URL?, URL?) in
//                (media, await media.getThumbnailURL(), await media.getURL())
//            }
//            .first { (_, thumb, full) -> Bool in
//                thumb != nil && full != nil
//            }
//            .map { media, thumb, full in
//                MockVideo(id: media.id.uuidString, thumbnail: thumb!, full: full!)
//            }
//    }

    func toMockMessage(user: MockUser, status: Message.Status = .read) async -> MockMessage {
//        let mockImage = await makeMockImage()

        return MockMessage(
            uid: id ?? UUID().uuidString,
            sender: user,
            createdAt: createdAt,
            status: user.isCurrentUser ? status : nil,
            text: text,
            images: image,
            videos: video
        )
    }
}
