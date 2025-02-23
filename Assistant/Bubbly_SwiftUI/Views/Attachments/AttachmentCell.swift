//
//  AttachmentCell.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import SwiftUI

struct AttachmentCell: View {

    @Environment(\.chatTheme) private var theme

    let attachment: Attachment
    @Binding var isVideoViewPresented: Bool

    let onTap: (Attachment) -> Void

    var body: some View {
        Group {
            if attachment.type == .image {
                content
            } else if attachment.type == .video {
                content
                    .overlay {
                        theme.images.message.playVideo
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                    }
            } else {
                content
                    .overlay {
                        Text("Unknown")
                    }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if attachment.type == .video {
                isVideoViewPresented = true
            } else {
                onTap(attachment)
            }
        }
        .sheet(isPresented: $isVideoViewPresented) {
            VideoView(viewModel: VideoViewModel(attachment: attachment))
                .environmentObject(
                    FullscreenMediaPagesViewModel(attachments: [attachment], index: 0)
                )
        }
    }

    var content: some View {
        AsyncImageView(url: attachment.thumbnail)
    }
}

struct AsyncImageView: View {

    @Environment(\.chatTheme) var theme
    let url: URL

    var body: some View {
        CachedAsyncImage(url: url, urlCache: .imageCache) { imageView in
            imageView
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Rectangle()
                    .foregroundColor(theme.colors.inputLightContextBackground)
                    .frame(minWidth: 100, minHeight: 100)
                ActivityIndicator(size: 30, showBackground: false)
            }
        }
    }
}
