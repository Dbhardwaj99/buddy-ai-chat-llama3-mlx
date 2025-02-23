//
//  AttachmentGrid.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import SwiftUI

@available(iOS 15.0, *)
struct AttachmentsGrid: View {
    let onTap: (Attachment) -> Void
    let maxImages: Int = 1 // TODO: Make injectable

    private let single: (Attachment)?
    private let grid: [Attachment]
    private let onlyOne: Bool

    private let hidden: String?
    private let showMoreAttachmentId: String?
    
    @State private var isVideoViewPresented: Bool = false

    init(attachment: Attachment?, onTap: @escaping (Attachment) -> Void) {
        let toShow: [Attachment] = attachment != nil ? [attachment!] : []
        
        if toShow.count > maxImages {
            hidden = "+\(toShow.count - (maxImages - 1))"
            if let attachment = toShow[safe: (maxImages - 1)] {
                showMoreAttachmentId = attachment.id
            } else {
                showMoreAttachmentId = nil
            }
        } else {
            hidden = nil
            showMoreAttachmentId = nil
        }
        
        if toShow.count % 2 == 0 {
            single = nil
            grid = toShow
        } else {
            single = toShow.first
            grid = toShow.dropFirst().map { $0 }
        }
        
        self.onlyOne = toShow.count == 1
        self.onTap = onTap
    }

    
    var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }

    
    var body: some View {
            VStack(spacing: 4) {
                if let attachment = single {
                    AttachmentCell(attachment: attachment, isVideoViewPresented: $isVideoViewPresented, onTap: onTap)
                        .frame(width: 204, height: grid.isEmpty ? 200 : 100)
                        .clipped()
                        .cornerRadius(onlyOne ? 0 : 12)
                }
                if !grid.isEmpty {
                    ForEach(pair(), id: \.id) { pair in
                        HStack(spacing: 4) {
                            AttachmentCell(attachment: pair.left, isVideoViewPresented: $isVideoViewPresented, onTap: onTap)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(12)
                            AttachmentCell(attachment: pair.right, isVideoViewPresented: $isVideoViewPresented, onTap: onTap)
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(12)
                                .overlay {
                                    if pair.right.id == showMoreAttachmentId, let hidden = hidden {
                                        ZStack {
                                            RadialGradient(
                                                colors: [
                                                    .black.opacity(0.8),
                                                    .black.opacity(0.6),
                                                ],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 90
                                            )
                                            Text(hidden)
                                                .font(.body)
                                                .bold()
                                                .foregroundColor(.white)
                                        }
                                        .allowsHitTesting(false)
                                    }
                                }
                        }
                    }
                }
            }
        }
    
    
//    var body: some View {
//        VStack(spacing: 4) {
//            if let attachment = single {
//                AttachmentCell(attachment: attachment, onTap: onTap)
//                    .frame(width: 204, height: grid.isEmpty ? 200 : 100)
//                    .clipped()
//                    .cornerRadius(onlyOne ? 0 : 12)
//            }
//            if !grid.isEmpty {
//                ForEach(pair(), id: \.id) { pair in
//                    HStack(spacing: 4) {
//                        AttachmentCell(attachment: pair.left, onTap: onTap)
//                            .frame(width: 100, height: 100)
//                            .clipped()
//                            .cornerRadius(12)
//                        AttachmentCell(attachment: pair.right, onTap: onTap)
//                            .frame(width: 100, height: 100)
//                            .clipped()
//                            .overlay {
//                                if pair.right.id == showMoreAttachmentId, let hidden = hidden {
//                                    ZStack {
//                                        RadialGradient(
//                                            colors: [
//                                                .black.opacity(0.8),
//                                                .black.opacity(0.6),
//                                            ],
//                                            center: .center,
//                                            startRadius: 0,
//                                            endRadius: 90
//                                        )
//                                        Text(hidden)
//                                            .font(.body)
//                                            .bold()
//                                            .foregroundColor(.white)
//                                    }
//                                    .allowsHitTesting(false)
//                                }
//                            }
//                            .cornerRadius(12)
//                    }
//                }
//            }
//        }
//    }
}

@available(iOS 15.0, *)
private extension AttachmentsGrid {
    func pair() -> [AttachmentsPair] {
        var pairs = [AttachmentsPair]()
        for i in stride(from: 0, to: grid.count, by: 2) {
            if i + 1 < grid.count {
                pairs.append(AttachmentsPair(left: grid[i], right: grid[i + 1]))
            } else {
                pairs.append(AttachmentsPair(left: grid[i], right: grid[i]))
            }
        }
        return pairs
    }
}

struct AttachmentsPair {
    let left: Attachment
    let right: Attachment

    var id: String {
        left.id + "+" + right.id
    }
}

//#if DEBUG
//struct AttachmentsGrid_Preview: PreviewProvider {
//    private static let examples = [1, 2, 3, 4, 5, 10]
//
//    static var previews: some View {
//        Group {
//            ForEach(examples, id: \.self) { count in
//                ScrollView {
//                    AttachmentsGrid(
//                        attachment: Attachment/*.random(count: count)*/,
//                        onTap: { _ in
//                        })
//                        .padding()
//                        .background(Color.white)
//                }
//            }
//            .padding()
//            .background(Color.secondary)
//        }
//    }
//}

extension Array where Element == Attachment {
    static func random(count: Int) -> [Attachment] {
        return Swift.Array(repeating: 0, count: count)
            .map { _ in randomAttachment() }
    }

    private static func randomAttachment() -> Attachment {
        if Int.random(in: 0...3) == 0 {
            return Attachment.randomVideo()
        } else {
            return Attachment.randomImage()
        }
    }
}

extension Attachment {
    static func randomImage() -> Attachment {
        Attachment(id: UUID().uuidString, url: URL(string: "https://placeimg.com/640/480/sepia")!, type: .image)
    }
    // TODO get video, not image
    static func randomVideo() -> Attachment {
        Attachment(id: UUID().uuidString, url: URL(string: "https://placeimg.com/640/480/sepia")!, type: .video)
    }
}
//#endif
