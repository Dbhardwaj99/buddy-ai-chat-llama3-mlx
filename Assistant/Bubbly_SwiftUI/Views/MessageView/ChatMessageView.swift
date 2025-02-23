//
//  ChatMessageView.swift
//
//
//  Created by Alisa Mylnikova on 20.03.2023.
//

import SwiftUI

struct ChatMessageView<MessageContent: View>: View {
    
    typealias MessageBuilderClosure = ChatView<MessageContent, EmptyView >.MessageBuilderClosure
    
    @ObservedObject var viewModel: ChatViewModel
    
    var messageBuilder: MessageBuilderClosure?
    
    let row: MessageRow
    let avatarSize: CGFloat
    let tapAvatarClosure: ChatView.TapAvatarClosure?
    let messageUseMarkdown: Bool
    let isDisplayingMessageMenu: Bool
    let showMessageTimeView: Bool
    let messageFont: UIFont
    
    var body: some View {
        Group {
            if let messageBuilder = messageBuilder {
                messageBuilder(
                    row.message,
                    row.positionInUserGroup
                    
                )
            } else {
                MessageView(
                    viewModel: viewModel,
                    message: row.message,
                    positionInUserGroup: row.positionInUserGroup,
                    avatarSize: avatarSize,
                    tapAvatarClosure: tapAvatarClosure,
                    messageUseMarkdown: messageUseMarkdown,
                    isDisplayingMessageMenu: isDisplayingMessageMenu,
                    showMessageTimeView: showMessageTimeView,
                    font: messageFont)
            }
        }
        .id(row.message.id)
    }
}
