//
//  MediaType.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import Foundation
import Combine

public enum MediaType {
    case image
    case video
}

public struct Media: Identifiable, Equatable {
    public var id = UUID()
    internal let source: MediaModelProtocol

    public static func == (lhs: Media, rhs: Media) -> Bool {
        lhs.id == rhs.id
    }
}

public extension Media {

    var type: MediaType {
        source.mediaType ?? .image
    }

    var duration: CGFloat? {
        source.duration
    }

    func getURL() async -> URL? {
        await source.getURL()
    }

    func getThumbnailURL() async -> URL? {
        await source.getThumbnailURL()
    }

    func getData() async -> Data? {
        try? await source.getData()
    }

    func getThumbnailData() async -> Data? {
        await source.getThumbnailData()
    }
}

protocol MediaModelProtocol {
    var mediaType: MediaType? { get }
    var duration: CGFloat? { get }

    func getURL() async -> URL?
    func getThumbnailURL() async -> URL?

    func getData() async throws -> Data?
    func getThumbnailData() async -> Data?
}
