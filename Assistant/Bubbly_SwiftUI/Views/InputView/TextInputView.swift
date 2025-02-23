//
//  TextInputView.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 12/12/24.
//

import SwiftUI

struct TextInputView: View {

    @Environment(\.chatTheme) private var theme

    @EnvironmentObject private var globalFocusState: GlobalFocusState

    @Binding var text: String
    var inputFieldId: UUID
//    var style: InputViewStyle
    var availableInput: AvailableInputType

    var body: some View {
        TextField("", text: $text, axis: .vertical)
            .customFocus($globalFocusState.focus, equals: .uuid(inputFieldId))
            .placeholder(when: text.isEmpty) {
                Text("Type a message...")
                    .foregroundColor(theme.colors.buttonBackground)
            }
            .foregroundColor(theme.colors.textLightContext)
            .backgroundStyle(Color(hex: "#DCDBDC"))
            .padding(.vertical, 10)
            .padding(.leading, 12)
            .onTapGesture {
                globalFocusState.focus = .uuid(inputFieldId)
            }
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.height > 50 { // Detect downward swipe
                            globalFocusState.focus = nil // Dismiss keyboard
                        }
                    }
            )
    }
}
