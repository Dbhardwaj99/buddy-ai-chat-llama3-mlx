//
//  WrappingViews.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import SwiftUI

extension ChatView {
    
    static func mapMessages(_ messages: [Message]) -> [MessagesSection] {
        guard messages.hasUniqueIDs() else {
            fatalError("Messages can not have duplicate ids, please make sure every message gets a unique id")
        }
        
        let result: [MessagesSection]
        
        result = mapMessagesQuoteModeReplies(messages)
        
        
        return result
    }
    
    static func mapMessagesQuoteModeReplies(_ messages: [Message]) -> [MessagesSection] {
        let dates = Set(messages.map({ $0.createdAt.startOfDay() }))
            .sorted()
            .reversed()
        var result: [MessagesSection] = []
        
        for date in dates {
            let section = MessagesSection(
                date: date,
                // use fake isFirstSection/isLastSection because they are not needed for quote replies
                rows: wrapSectionMessages(messages.filter({ $0.createdAt.isSameDay(date) }), isFirstSection: false, isLastSection: false)
            )
            result.append(section)
        }
        
        return result
    }
    
    static private func wrapSectionMessages(_ messages: [Message], isFirstSection: Bool, isLastSection: Bool) -> [MessageRow] {
        messages
            .enumerated()
            .map {
                let index = $0.offset
                let message = $0.element
                let nextMessage = messages[safe: index + 1]
                let prevMessage = messages[safe: index - 1]
                
                let nextMessageExists = nextMessage != nil
                let prevMessageExists = prevMessage != nil
                let nextMessageIsSameUser = nextMessage?.user.id == message.user.id
                let prevMessageIsSameUser = prevMessage?.user.id == message.user.id
                
                let position: PositionInUserGroup
                if nextMessageExists, nextMessageIsSameUser, prevMessageIsSameUser {
                    position = .middle
                } else if !nextMessageExists || !nextMessageIsSameUser, !prevMessageIsSameUser {
                    position = .single
                } else if nextMessageExists, nextMessageIsSameUser {
                    position = .first
                } else {
                    position = .last
                }
                
                let positionInSection: PositionInSection
                if !prevMessageExists, !nextMessageExists {
                    positionInSection = .single
                } else if !prevMessageExists {
                    positionInSection = .first
                } else if !nextMessageExists {
                    positionInSection = .last
                } else {
                    positionInSection = .middle
                }
                
                let positionInChat: PositionInChat
                if !isFirstSection, !isLastSection {
                    positionInChat = .middle
                } else if !prevMessageExists, !nextMessageExists, isFirstSection, isLastSection {
                    positionInChat = .single
                } else if !prevMessageExists, isFirstSection {
                    positionInChat = .first
                } else if !nextMessageExists, isLastSection {
                    positionInChat = .last
                } else {
                    positionInChat = .middle
                }
                
                return MessageRow(message: $0.element, positionInUserGroup: position)
            }
            .reversed()
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
