//
//  ChatView.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import Foundation
import SwiftUI
import Combine

struct BubblyView: View {
    
    @Environment(\.presentationMode) private var presentationMode

    @StateObject private var viewModel: BubblyViewModel
    @StateObject private var keyboard = KeyboardResponder()
    @State var kbHeight: CGFloat = 0
    @Binding var showChat: Bool
    
    private let title: String
    
    init(
        viewModel: BubblyViewModel = BubblyViewModel(),
        title: String,
        showChat: Binding<Bool>
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.title = title
        self._showChat = showChat
        
    }
    
    var body: some View {
        ChatView(
            messages: viewModel.messages,
            didSendMessage: {draft in
                viewModel.send(draft: draft)
            }, showChat: $showChat
        )
        .enableLoadMore(pageSize: 3) { message in
            viewModel.loadMoreMessage(before: message)
        }
        .betweenListAndInputViewBuilder {
            Rectangle()
                .frame(height: keyboard.keyboardHeight)
                .animation(.easeInOut(duration: 0.3))
                .foregroundStyle(.red)
        }
        .messageUseMarkdown(true)
        .navigationBarBackButtonHidden()
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                HStack {
//                    if let url = viewModel.chatCover {
//                        CachedAsyncImage(url: url, urlCache: .shared) { phase in
//                            switch phase {
//                            case .success(let image):
//                                image
//                                    .resizable()
//                                    .scaledToFill()
//                            default:
//                                Rectangle().fill(Color(hex: "AFB3B8"))
//                            }
//                        }
//                        .frame(width: 35, height: 35)
//                        .clipShape(Circle())
//                    }
//                    
//                    VStack(alignment: .center, spacing: 0) {
//                        Text(viewModel.chatTitle)
//                            .fontWeight(.semibold)
//                            .font(.headline)
//                            .foregroundColor(.black)
//                    }
//                    Spacer()
////                    
////                    
////                    Button { presentationMode.wrappedValue.dismiss() } label: {
////                        Text("Done")
////                            .font(.title3)
////                            .foregroundColor(Color(hex: "#00B9B7"))
////                            .fontWeight(.bold)
////                    }
//                }
//                .frame(maxWidth: .infinity, idealHeight: 200)
//                .background(
//                    Color.white.edgesIgnoringSafeArea(.bottom)
//                ) // Ensure no extra background/shadow
//                .padding(.horizontal, 20)
//            }
//        }
//        .navigationBarHidden(true)
//        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: viewModel.onStart)
        .onDisappear(perform: viewModel.onStop)
    }
}

extension Color {
    static var exampleBlue = Color(hex: "#4962FF")
    static var examplePickerBg = Color(hex: "1F1F1F")
}


class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .sink { notification in
                if let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) {
                    DispatchQueue.main.async {
                        self.keyboardHeight = notification.name == UIResponder.keyboardWillHideNotification ? 0 : frame.height
                    }
                }
            }
    }
}
