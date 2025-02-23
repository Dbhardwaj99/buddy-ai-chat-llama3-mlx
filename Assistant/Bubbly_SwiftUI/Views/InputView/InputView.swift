//
//  InputView.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import SwiftUI


public enum InputViewAction {
    case send
}

public enum InputViewState {
    case empty
    case hasTextOrMedia

    var canSend: Bool {
        switch self {
        case .hasTextOrMedia: return true
        default: return false
        }
    }
}

public enum AvailableInputType {
    case textAndMedia
    case textOnly

    var isMediaAvailable: Bool {
        [.textAndMedia].contains(self)
    }
}

public struct InputViewAttachments {
    public var medias: Media?
}

struct InputView: View {

    @Environment(\.chatTheme) private var theme
//    @Environment(\.mediaPickerTheme) private var pickerTheme

    @ObservedObject var viewModel: InputViewModel
    var inputFieldId: UUID
    var availableInput: AvailableInputType
    var messageUseMarkdown: Bool

    private var onAction: (InputViewAction) -> Void {
        viewModel.inputViewAction()
    }

    private var state: InputViewState {
        viewModel.state
    }

    @State private var overlaySize: CGSize = .zero

    @State private var recordButtonFrame: CGRect = .zero
    @State private var lockRecordFrame: CGRect = .zero
    @State private var deleteRecordFrame: CGRect = .zero

    @State private var dragStart: Date?
    @State private var tapDelayTimer: Timer?
    @State private var cancelGesture = false
    private let tapDelay = 0.2

    var body: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 10) {
                HStack(alignment: .bottom, spacing: 0) {
                    textView
                }
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(fieldBackgroundColor)
                }
                rightOutsideButton
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .backgroundStyle(.clear)
    }

    @ViewBuilder
    var textView: some View {
        Group {
            TextInputView(text: $viewModel.text, inputFieldId: inputFieldId, availableInput: availableInput)
        }
        .frame(minHeight: 48)
    }

    @ViewBuilder
    var rightOutsideButton: some View {
        ZStack {
            Group {
                sendButton
                    .disabled(!state.canSend)
            }
            .compositingGroup()
        }
            .viewSize(48)
        }

    @ViewBuilder
    func textView(_ text: String) -> some View {
        Text(text)
    }

    var sendButton: some View {
        Button {
            onAction(.send)
        } label: {
            theme.images.inputView.arrowSend
                .viewSize(48)
                .rotationEffect(.degrees(state.canSend ? 0 : 180)) // Rotate if can't send
                .animation(.easeInOut(duration: 0.2), value: state.canSend)
                .circleBackground(
                    state.canSend ? Color(hex: "#3D74A2") : Color(hex: "#CBE1F0")
                )
        }
    }

    var fieldBackgroundColor: Color {
        return theme.colors.inputLightContextBackground
    }

    var backgroundColor: Color {
        return theme.colors.mainBackground
    }
}
