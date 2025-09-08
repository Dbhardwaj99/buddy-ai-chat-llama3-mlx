//
//  OGChatView.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import SwiftUI
import Pow

public typealias MediaPickerParameters = SelectionParamsHolder


@available(iOS 15.0, *)
public struct ChatView<MessageContent: View, InputViewContent: View>: View {

    public typealias MessageBuilderClosure = ((
        _ message: Message,
        _ positionInGroup: PositionInUserGroup
    ) -> MessageContent)
    
    @Environment(\.presentationMode) private var presentationMode

    public typealias TapAvatarClosure = (User, String) -> ()

    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Environment(\.chatTheme) private var theme

    // MARK: - Parameters
    let sections: [MessagesSection]
    let ids: [String]
    let didSendMessage: (DraftMessage) -> Void

    // MARK: - View builders

    var messageBuilder: MessageBuilderClosure? = nil
    
    var betweenListAndInputViewBuilder: (()->AnyView)?
    
    @Binding var showChat: Bool
    
    var mainHeaderBuilder: (()->AnyView)?

    var headerBuilder: ((Date)->AnyView)?

    // MARK: - Customization

    @State var isListAboveInputView: Bool = true
    @StateObject private var keyboard = KeyboardResponder()
    
    var showDateHeaders: Bool = true
    var isScrollEnabled: Bool = true
    var avatarSize: CGFloat = 32
    var messageUseMarkdown: Bool = false
    var showMessageMenuOnLongPress: Bool = true
    var showNetworkConnectionProblem: Bool = false
    var tapAvatarClosure: TapAvatarClosure?
    var mediaPickerSelectionParameters: MediaPickerParameters?
    var orientationHandler: MediaPickerOrientationHandler = {_ in}
    var chatTitle: String?
    var paginationHandler: PaginationHandler?
    var showMessageTimeView = true
    var messageFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
    var availablelInput: AvailableInputType = .textOnly
    @State private var showMenu = false
    @State private var showPopup = false

    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var bubblyviewModel = BubblyViewModel()
    @StateObject private var inputViewModel = InputViewModel()
    @StateObject private var globalFocusState = GlobalFocusState()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var keyboardState = KeyboardState()

    @State private var isScrolledToBottom: Bool = true
    @State private var shouldScrollToTop: () -> () = {}

    @State private var isShowingMenu = false
    @State private var needsScrollView = false
    @State private var readyToShowScrollView = false
    @State private var menuButtonsSize: CGSize = .zero
    @State private var tableContentHeight: CGFloat = 0
    @State private var inputViewSize = CGSize.zero
    @State private var cellFrames = [String: CGRect]()
    @State private var menuCellPosition: CGPoint = .zero
    @State private var menuBgOpacity: CGFloat = 0
    @State private var menuCellOpacity: CGFloat = 0
    @State private var menuScrollView: UIScrollView?

    init(messages: [Message],
                didSendMessage: @escaping (DraftMessage) -> Void,
                messageBuilder: @escaping MessageBuilderClosure, showChat: Binding<Bool>,
                BviewModel: BubblyViewModel) {
        self.didSendMessage = didSendMessage
        self.sections = ChatView.mapMessages(messages)
        self.ids = messages.map { $0.id }
        self.messageBuilder = messageBuilder
        self._showChat = showChat
    }

    public var body: some View {
        ZStack {
            Image(.bluredBG) // Use the same background image as the login page
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 10)
                .opacity(0.3)
            
            VStack {
                headView
//                    .padding(.top, 60)
                    .padding(.bottom, -5)
                mainView
            }
            .ignoresSafeArea()
            .blur(radius: showMenu || showPopup ? 8 : 0)
            .disabled(showMenu || showPopup)
            
            if showMenu || showPopup {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showMenu = false
                        showPopup = false
                    }
            }
            
            // Slide-in Menu
            if showMenu {
                VStack {
                    Spacer()
                }
                .frame(width: 300, height: UIScreen.main.bounds.height)
                .background(Color.black)
                .offset(x: showMenu ? -100 : -300)  // ✅ Use offset instead of position
                .transition(
                    .asymmetric(
                        insertion: .movingParts.skid,
                        removal: .movingParts.skid(direction: .trailing)
                    )
                )
                .animation(.interactiveSpring(dampingFraction: 0.66), value: showMenu) // ✅ Keep one animation
            }
            
            // Pop-up View
            if showPopup {
                VStack {
                    Text("Popup Content")
                        .frame(width: 300, height: 200)
                        .background(Color.white)
                        .cornerRadius(10)
//                        .shadow(radius: 10)
                }
                .transition(.scale)
                .animation(.easeInOut(duration: 0.3), value: showPopup)
            }
        }
        .environmentObject(keyboardState)
    }

    var mainView: some View {
        ZStack(alignment: .bottom) { // Align everything at the bottom
            listWithButton
                .padding(.bottom, isListAboveInputView ? keyboard.keyboardHeight + 5 : 95)

//            if let builder = betweenListAndInputViewBuilder {
//                builder() // The extra view injected between list and input
//            }

            inputView
                .padding(.bottom, isListAboveInputView ? keyboard.keyboardHeight : 30) // Adjust position instead of using `.position()`
        }
        .onReceive(globalFocusState.$focus) { newFocus in
            isListAboveInputView = (newFocus != nil) // Move list up when keyboard is focused
//            if isListAboveInputView{
//                NotificationCenter.default.post(name: .onScrollToBottom, object: nil)
//            }
        }
        .onChange(of: isListAboveInputView) { _ in
            NotificationCenter.default.post(name: .onScrollToBottom, object: nil)
        }
    }
    
    var headView: some View {
        VStack{
            Color.clear
                .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            
            Rectangle()
//                .foregroundStyle(.white)
                .foregroundStyle(.clear)
//                .opacity(0.15)
                .frame(width: UIScreen.main.bounds.width, height: 30)
            //            .cornerRadius(30)
                .overlay(content: {
                    HStack {
                        Button(action: { showMenu.toggle() } ) {
                            Image(.menu)
                                .foregroundStyle(.white)
                                .clipShape(.circle)
                                .frame(width: 50, height: 30)
                        }
                        .padding(.trailing, 30)
                        
//                        Spacer(minLength: 100)
                        Spacer()
                        
                        HStack(spacing: -30){
                            Text("Dibling")
                                .foregroundStyle(.white)
                            //                            .font()
                                .bold()
                                .lineLimit(1)
                                .padding(.trailing, 40)
                            
                            Image(.dropDown)
                                .resizable()
                                .frame(width: 13, height: 13)
                            
                        }
                        Spacer()
                        
                        
                        Button(action: { showChat.toggle() } ) {
                            Image(.slider)
                                .foregroundStyle(.white)
                                .clipShape(.circle)
                                .frame(width: 50, height: 30)
                        }
                    }
                    .padding(.horizontal, 20)
                })
        }
    }

    var waitingForNetwork: some View {
        VStack {
            Rectangle()
                .foregroundColor(.black.opacity(0.12))
                .frame(height: 1)
            HStack {
                Spacer()
                Image("waiting", bundle: .current)
                Text("Waiting for network")
                Spacer()
            }
            .padding(.top, 6)
            Rectangle()
                .foregroundColor(.black.opacity(0.12))
                .frame(height: 1)
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    var listWithButton: some View {
        ZStack(alignment: .bottomTrailing) {
            list
                .padding(.horizontal, 10)
            
            if !isScrolledToBottom {
                Button {
                    NotificationCenter.default.post(name: .onScrollToBottom, object: nil)
                } label: {
                    theme.images.scrollToBottom
                        .frame(width: 40, height: 40)
                        .circleBackground(Color.gray)
                        .opacity(0.4)
                }
                .padding(8)
                .padding(.trailing, 25)
                .padding(.bottom, isListAboveInputView ? 60 : 40)
            }
        }
    }

    @ViewBuilder
    var list: some View {
        UIList(viewModel: viewModel,
               inputViewModel: inputViewModel,
               isScrolledToBottom: $isScrolledToBottom,
               shouldScrollToTop: $shouldScrollToTop,
               tableContentHeight: $tableContentHeight,
               messageBuilder: messageBuilder,
               mainHeaderBuilder: mainHeaderBuilder,
               headerBuilder: headerBuilder,
               inputView: inputView,
               showDateHeaders: showDateHeaders,
               isScrollEnabled: isScrollEnabled,
               avatarSize: avatarSize,
               showMessageMenuOnLongPress: showMessageMenuOnLongPress,
               tapAvatarClosure: tapAvatarClosure,
               paginationHandler: paginationHandler,
               messageUseMarkdown: messageUseMarkdown,
               showMessageTimeView: showMessageTimeView,
               messageFont: messageFont,
               sections: sections,
               ids: ids
        )
        .applyIf(!isScrollEnabled) {
            $0.frame(height: tableContentHeight)
        }
        .onStatusBarTap {
            shouldScrollToTop()
        }
//        .transparentNonAnimatingFullScreenCover(item: $viewModel.messageMenuRow) {
//            if let row = viewModel.messageMenuRow {
//                ZStack(alignment: .topLeading) {
//                    theme.colors.messageMenuBackground
//                        .opacity(menuBgOpacity)
//                        .ignoresSafeArea(.all)
//                }
//                .onAppear {
//                    DispatchQueue.main.async {
//                        if let frame = cellFrames[row.id] {
//                            showMessageMenu(frame)
//                        }
//                    }
//                }
//                .onTapGesture {
//                    hideMessageMenu()
//                }
//            }
//        }
        .onPreferenceChange(MessageMenuPreferenceKey.self) {
            self.cellFrames = $0
        }
        .onTapGesture {
            globalFocusState.focus = nil
        }
        .onAppear {
            viewModel.didSendMessage = didSendMessage
            viewModel.inputViewModel = inputViewModel
            viewModel.globalFocusState = globalFocusState

            inputViewModel.didSendMessage = { value in
                Task { @MainActor in
                    didSendMessage(value)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: .onScrollToBottom, object: nil)
                }
            }
        }
    }

    var inputView: some View {
        Group {
            InputView(
                viewModel: inputViewModel,
                inputFieldId: viewModel.inputFieldId,
                availableInput: availablelInput,
                messageUseMarkdown: messageUseMarkdown
//                    recorderSettings: recorderSettings
            )
            .padding(.horizontal, 10)
//            Spacer(minLength: 20)
        }
        .sizeGetter($inputViewSize)
        .environmentObject(globalFocusState)
        .onAppear(perform: inputViewModel.onStart)
        .onDisappear(perform: inputViewModel.onStop)
    }

//    func messageMenu(_ row: MessageRow) -> some View {
//        MessageMenu(
//            isShowingMenu: $isShowingMenu,
//            menuButtonsSize: $menuButtonsSize,
//            alignment: row.message.user.isCurrentUser ? .right : .left,
//            leadingPadding: avatarSize + MessageView.horizontalAvatarPadding * 2,
//            trailingPadding: MessageView.statusViewSize + MessageView.horizontalStatusPadding,
//            onAction: menuActionClosure(row.message)) {
//                ChatMessageView(viewModel: viewModel, messageBuilder: messageBuilder, row: row, chatType: type, avatarSize: avatarSize, tapAvatarClosure: nil, messageUseMarkdown: messageUseMarkdown, isDisplayingMessageMenu: true, showMessageTimeView: showMessageTimeView, messageFont: messageFont)
//                    .onTapGesture {
//                        hideMessageMenu()
//                    }
//            }
//            .frame(height: menuButtonsSize.height + (cellFrames[row.id]?.height ?? 0), alignment: .top)
//            .opacity(menuCellOpacity)
//    }

//    func menuActionClosure(_ message: Message) -> (MenuAction) -> () {
//        if let messageMenuAction {
//            return { action in
//                hideMessageMenu()
//                messageMenuAction(action, viewModel.messageMenuAction(), message)
//            }
//        } else if MenuAction.self == DefaultMessageMenuAction.self {
//            return { action in
//                hideMessageMenu()
//                viewModel.messageMenuActionInternal(message: message, action: action as! DefaultMessageMenuAction)
//            }
//        }
//        return { _ in }
//    }

    func showMessageMenu(_ cellFrame: CGRect) {
        DispatchQueue.main.async {
            let wholeMenuHeight = menuButtonsSize.height + cellFrame.height
            let needsScrollTemp = wholeMenuHeight > UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom

            menuCellPosition = CGPoint(x: cellFrame.midX, y: cellFrame.minY + wholeMenuHeight/2 - safeAreaInsets.top)
            menuCellOpacity = 1

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                var finalCellPosition = menuCellPosition
                if needsScrollTemp ||
                    cellFrame.minY + wholeMenuHeight + safeAreaInsets.bottom > UIScreen.main.bounds.height {

                    finalCellPosition = CGPoint(x: cellFrame.midX, y: UIScreen.main.bounds.height - wholeMenuHeight/2 - safeAreaInsets.top - safeAreaInsets.bottom
                    )
                }

                withAnimation(.linear(duration: 0.1)) {
                    menuBgOpacity = 0.9
                    menuCellPosition = finalCellPosition
                    isShowingMenu = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                needsScrollView = needsScrollTemp
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                readyToShowScrollView = true
                if let menuScrollView = menuScrollView {
                    menuScrollView.contentOffset = CGPoint(x: 0, y: menuScrollView.contentSize.height - menuScrollView.frame.height + safeAreaInsets.bottom)
                }
            }
        }
    }

    func hideMessageMenu() {
        menuScrollView = nil
        withAnimation(.linear(duration: 0.1)) {
            menuCellOpacity = 0
            menuBgOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.messageMenuRow = nil
            isShowingMenu = false
            needsScrollView = false
            readyToShowScrollView = false
        }
    }
}

@available(iOS 14.0, *)
extension ChatView {
    func betweenListAndInputViewBuilder<V: View>(_ builder: @escaping ()->V) -> ChatView {
        var view = self
        view.betweenListAndInputViewBuilder = {
            AnyView(builder())
        }
        return view
    }


    func mainHeaderBuilder<V: View>(_ builder: @escaping ()->V) -> ChatView {
        var view = self
        view.mainHeaderBuilder = {
            AnyView(builder())
        }
        return view
    }

    func headerBuilder<V: View>(_ builder: @escaping (Date)->V) -> ChatView {
        var view = self
        view.headerBuilder = { date in
            AnyView(builder(date))
        }
        return view
    }

    func isListAboveInputView(_ isAbove: Bool) -> ChatView {
        var view = self
        view.isListAboveInputView = isAbove
        return view
    }

    func showDateHeaders(_ showDateHeaders: Bool) -> ChatView {
        var view = self
        view.showDateHeaders = showDateHeaders
        return view
    }

    func isScrollEnabled(_ isScrollEnabled: Bool) -> ChatView {
        var view = self
        view.isScrollEnabled = isScrollEnabled
        return view
    }

    func showMessageMenuOnLongPress(_ show: Bool) -> ChatView {
        var view = self
        view.showMessageMenuOnLongPress = show
        return view
    }

    func showNetworkConnectionProblem(_ show: Bool) -> ChatView {
        var view = self
        view.showNetworkConnectionProblem = show
        return view
    }

    func assetsPickerLimit(assetsPickerLimit: Int) -> ChatView {
        var view = self
        view.mediaPickerSelectionParameters = MediaPickerParameters()
        view.mediaPickerSelectionParameters?.selectionLimit = assetsPickerLimit
        return view
    }

    func setMediaPickerSelectionParameters(_ params: MediaPickerParameters) -> ChatView {
        var view = self
        view.mediaPickerSelectionParameters = params
        return view
    }

    func orientationHandler(orientationHandler: @escaping MediaPickerOrientationHandler) -> ChatView {
        var view = self
        view.orientationHandler = orientationHandler
        return view
    }

    /// when user scrolls up to `pageSize`-th meassage, call the handler function, so user can load more messages
    /// NOTE: doesn't work well with `isScrollEnabled` false
    func enableLoadMore(pageSize: Int, _ handler: @escaping ChatPaginationClosure) -> ChatView {
        var view = self
        view.paginationHandler = PaginationHandler(handleClosure: handler, pageSize: pageSize)
        return view
    }

    @available(*, deprecated)
    func chatNavigation(title: String, status: String? = nil, cover: URL? = nil) -> some View {
        var view = self
        view.chatTitle = title
        return view.modifier(ChatNavigationModifier(title: title, status: status, cover: cover))
    }

    // makes sense only for built-in message view

    func avatarSize(avatarSize: CGFloat) -> ChatView {
        var view = self
        view.avatarSize = avatarSize
        return view
    }

    func tapAvatarClosure(_ closure: @escaping TapAvatarClosure) -> ChatView {
        var view = self
        view.tapAvatarClosure = closure
        return view
    }

    func messageUseMarkdown(_ messageUseMarkdown: Bool) -> ChatView {
        var view = self
        view.messageUseMarkdown = messageUseMarkdown
        return view
    }

    func showMessageTimeView(_ isShow: Bool) -> ChatView {
        var view = self
        view.showMessageTimeView = isShow
        return view
    }

    func setMessageFont(_ font: UIFont) -> ChatView {
        var view = self
        view.messageFont = font
        return view
    }

    // makes sense only for built-in input view

    func setAvailableInput(_ type: AvailableInputType) -> ChatView {
        var view = self
        view.availablelInput = type
        return view
    }

//    func setRecorderSettings(_ settings: RecorderSettings) -> ChatView {
//        var view = self
//        view.recorderSettings = settings
//        return view
//    }

}

//public extension Notification.Name {
//    static let onScrollToBottom = Notification.Name("onScrollToBottom")
//}

struct MessageMenuPreferenceKey: PreferenceKey {
    typealias Value = [String: CGRect]

    static var defaultValue: Value = [:]

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { (_, new) in new }
    }
}

@available(iOS 14.0, *)
public extension ChatView where MessageContent == EmptyView, InputViewContent == EmptyView {

    
    init(messages: [Message],
//         chatType: ChatType = .conversation,
         didSendMessage: @escaping (DraftMessage) -> Void, showChat: Binding<Bool>) {
        self.didSendMessage = didSendMessage
        self.sections = ChatView.mapMessages(messages)
        self.ids = messages.map { $0.id }
        self._showChat = showChat
    }
}
