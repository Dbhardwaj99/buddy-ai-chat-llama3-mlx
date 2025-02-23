//
//  MessageView.swift
//  Chat
//
//  Created by Alex.M on 23.05.2022.
//

import SwiftUI

struct MessageView: View {

    @Environment(\.chatTheme) private var theme

    @ObservedObject var viewModel: ChatViewModel

    let message: Message
    let positionInUserGroup: PositionInUserGroup
    let avatarSize: CGFloat
    let tapAvatarClosure: ChatView.TapAvatarClosure?
    let messageUseMarkdown: Bool
    let isDisplayingMessageMenu: Bool
    let showMessageTimeView: Bool

    @State var avatarViewSize: CGSize = .zero
    @State var statusSize: CGSize = .zero
    @State var timeSize: CGSize = .zero

    static let widthWithMedia: CGFloat = 204
    static let horizontalNoAvatarPadding: CGFloat = 8
    static let horizontalAvatarPadding: CGFloat = 8
    static let horizontalTextPadding: CGFloat = 12
    static let horizontalAttachmentPadding: CGFloat = 1 // for multiple attachments
    static let statusViewSize: CGFloat = 14
    static let horizontalStatusPadding: CGFloat = 8
    static let horizontalBubblePadding: CGFloat = 70

    var font: UIFont

    enum DateArrangement {
        case hstack, vstack, overlay
    }

    var additionalMediaInset: CGFloat {
        message.attachments == nil ? 0 : MessageView.horizontalAttachmentPadding * 2
    }

    var dateArrangement: DateArrangement {
        let timeWidth = timeSize.width + 10
        let textPaddings = MessageView.horizontalTextPadding * 2
        let widthWithoutMedia = UIScreen.main.bounds.width
        - (message.user.isCurrentUser ? MessageView.horizontalNoAvatarPadding : avatarViewSize.width)
        - statusSize.width
        - MessageView.horizontalBubblePadding
        - textPaddings

        let maxWidth = message.attachments == nil ? widthWithoutMedia : MessageView.widthWithMedia - textPaddings
        let finalWidth = message.text.width(withConstrainedWidth: maxWidth, font: font, messageUseMarkdown: messageUseMarkdown)
        let lastLineWidth = message.text.lastLineWidth(labelWidth: maxWidth, font: font, messageUseMarkdown: messageUseMarkdown)
        let numberOfLines = message.text.numberOfLines(labelWidth: maxWidth, font: font, messageUseMarkdown: messageUseMarkdown)

        if numberOfLines == 1, finalWidth + CGFloat(timeWidth) < maxWidth {
            return .hstack
        }
        if lastLineWidth + CGFloat(timeWidth) < finalWidth {
            return .overlay
        }
        return .vstack
    }

    var showAvatar: Bool {
        positionInUserGroup == .single
        || (positionInUserGroup == .last)
    }

    var topPadding: CGFloat {
        return positionInUserGroup == .single || positionInUserGroup == .first ? 12 : 8
    }

    var bottomPadding: CGFloat {
        return 0
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {

            VStack(alignment: message.user.isCurrentUser ? .trailing : .leading, spacing: 2) {
                bubbleView(message)
            }
        }
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
//        .padding(.leading, 10)
//        .padding(.trailing, 30)
//        .padding(.trailing, message.user.isCurrentUser ? MessageView.horizontalNoAvatarPadding : 0)
//        .padding(message.user.isCurrentUser ? .leading : .trailing, MessageView.horizontalBubblePadding)
        .frame(maxWidth: UIScreen.main.bounds.width, alignment: message.user.isCurrentUser ? .trailing : .leading)
    }

    @ViewBuilder
    func bubbleView(_ message: Message) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if message.attachments != nil {
                attachmentsView(message)
            }

            if !message.text.isEmpty {
                textWithTimeView(message)
                    .font(Font(font))
            }
        }
        .bubbleBackground(message, theme: theme)
    }

    @ViewBuilder
    func replyBubbleView(_ message: Message) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(message.user.name)
                .fontWeight(.semibold)
                .padding(.horizontal, MessageView.horizontalTextPadding)

            if message.attachments != nil {
                attachmentsView(message)
                    .padding(.top, 4)
                    .padding(.bottom, message.text.isEmpty ? 0 : 4)
            }

            if !message.text.isEmpty {
                MessageTextView(
                    text: message.text,
                    messageUseMarkdown: messageUseMarkdown,
                    isCurrentUser: message.user.isCurrentUser
                )
                    .padding(.horizontal, MessageView.horizontalTextPadding)
            }
        }
        .font(.caption2)
        .padding(.vertical, 8)
        .frame(width: message.attachments == nil ? nil : MessageView.widthWithMedia + additionalMediaInset)
        .bubbleBackground(message, theme: theme, isReply: true)
    }

    @ViewBuilder
    var avatarView: some View {
        Group {
            if showAvatar {
                AvatarView(url: message.user.avatarURL, avatarSize: avatarSize)
                    .contentShape(Circle())
                    .onTapGesture {
                        tapAvatarClosure?(message.user, message.id)
                    }
            } else {
                Color.clear.viewSize(avatarSize)
            }
        }
        .padding(.horizontal, MessageView.horizontalAvatarPadding)
        .sizeGetter($avatarViewSize)
    }

    @ViewBuilder
    func attachmentsView(_ message: Message) -> some View {
        AttachmentsGrid(attachment: message.attachments) {
            viewModel.presentAttachmentFullScreen($0)
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    func textWithTimeView(_ message: Message) -> some View {
        let messageView = MessageTextView(
            text: message.text,
            messageUseMarkdown: messageUseMarkdown,
            isCurrentUser: message.user.isCurrentUser
        )
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, MessageView.horizontalTextPadding)
        Group {
            switch dateArrangement {
            case .hstack:
                HStack(alignment: .lastTextBaseline, spacing: 12) {
                    messageView
                    if message.attachments != nil {
                        Spacer()
                    }
                }
                .padding(.vertical, 8)
            case .vstack:
                VStack(alignment: .leading, spacing: 4) {
                    messageView
                    HStack(spacing: 0) {
                        Spacer()
                    }
                }
                .padding(.vertical, 8)
            case .overlay:
                messageView
                    .padding(.vertical, 8)
            }
        }
    }
}

extension View {

    @ViewBuilder
    func bubbleBackground(_ message: Message, theme: ChatTheme, isReply: Bool = false) -> some View {
        let radius: CGFloat = message.attachments == nil ? 12 : 20
        let additionalMediaInset: CGFloat = 0
        self
            .frame(width: message.attachments == nil ? nil : MessageView.widthWithMedia + additionalMediaInset)
            .foregroundColor(message.user.isCurrentUser ? theme.colors.textDarkContext : theme.colors.textLightContext)
            .background {
                //                if message.attachments == nil {
                RoundedRectangle(cornerRadius: radius)
                    .foregroundColor(message.user.isCurrentUser ? theme.colors.myMessage : theme.colors.friendMessage)
                    .opacity(isReply ? 0.5 : 1)
                    .overlay(
 // Adding a black border
                        RoundedRectangle(cornerRadius: radius)
                            .stroke(
                                message.user.isCurrentUser ? Color.white : Color.black,
                                lineWidth: 1
                            )
                    )
                //                }
            }
            .cornerRadius(radius)
    }
}
