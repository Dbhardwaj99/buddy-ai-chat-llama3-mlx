//
//  FullscreenMediaPages.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
struct FullscreenMediaPages: View {
    @Environment(\.chatTheme) private var theme
    @StateObject var viewModel: FullscreenMediaPagesViewModel
    
    @State private var isVideoViewPresented = false
    var safeAreaInsets: EdgeInsets
    var onClose: () -> Void

    var body: some View {
        ZStack {
            backgroundView
            mediaContent
            overlayMiniGallery
            overlayTopBar
            overlayVideoControls
        }
        .ignoresSafeArea()
    }

    private var backgroundView: some View {
        Color.black
            .opacity(max((200.0 - viewModel.offset.height) / 200.0, 0.5))
            .gesture(closeGesture)
            .offset(viewModel.offset)
    }

    private var mediaContent: some View {
        VStack {
            TabView(selection: $viewModel.index) {
                ForEach(viewModel.attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
                    AttachmentsPage(attachment: attachment)
                        .tag(index)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(false)
                        .ignoresSafeArea()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .gesture(closeGesture)
        }
    }

    private var overlayMiniGallery: some View {
        VStack {
            Spacer()
            if viewModel.showMinis {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal) {
                        HStack(spacing: 2) {
                            ForEach(viewModel.attachments.enumerated().map({ $0 }), id: \.offset) { (index, attachment) in
                                AttachmentCell(
                                    attachment: attachment,
                                    isVideoViewPresented: $isVideoViewPresented
                                ) { _ in
                                    withAnimation {
                                        viewModel.index = index
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .cornerRadius(4)
                                .clipped()
                                .id(index)
                                .overlay(selectionOverlay(for: index))
                            }
                        }
                    }
                    .padding([.top, .horizontal], 12)
                    .background(Color.black)
                    .onAppear {
                        proxy.scrollTo(viewModel.index)
                    }
                    .onChange(of: viewModel.index) { newValue in
                        withAnimation {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
            }
        }
        .offset(y: -safeAreaInsets.bottom)
    }

    private var overlayTopBar: some View {
        VStack {
            if viewModel.showMinis {
                Text("\(viewModel.index + 1)/\(viewModel.attachments.count)")
                    .foregroundColor(.white)
                    .offset(y: safeAreaInsets.top)

                Button(action: onClose) {
                    theme.images.mediaPicker.cross
                        .padding(5)
                }
                .tint(.white)
                .padding(.leading, 15)
                .offset(y: safeAreaInsets.top - 5)
            }
        }
    }

    private var overlayVideoControls: some View {
        HStack(spacing: 20) {
            if viewModel.showMinis, viewModel.attachments[viewModel.index].type == .video {
                (viewModel.videoPlaying ? theme.images.fullscreenMedia.pause : theme.images.fullscreenMedia.play)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(5)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.toggleVideoPlaying()
                    }

                (viewModel.videoMuted ? theme.images.fullscreenMedia.unmute : theme.images.fullscreenMedia.mute)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(5)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.toggleVideoMuted()
                    }
            }
        }
        .foregroundColor(.white)
        .padding(.trailing, 10)
        .offset(y: safeAreaInsets.top - 5)
    }

    private var closeGesture: some Gesture {
        DragGesture()
            .onChanged { viewModel.offset = closeSize(from: $0.translation) }
            .onEnded {
                withAnimation {
                    viewModel.offset = .zero
                }
                if $0.translation.height >= 100 {
                    onClose()
                }
            }
    }

    private func closeSize(from size: CGSize) -> CGSize {
        CGSize(width: 0, height: max(size.height, 0))
    }

    private func selectionOverlay(for index: Int) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(theme.colors.sendButtonBackground, lineWidth: 2)
            .opacity(viewModel.index == index ? 1 : 0)
    }
}
//
//@available(iOS 15.0, *)
//private extension FullscreenMediaPages {
//    func closeSize(from size: CGSize) -> CGSize {
//        CGSize(width: 0, height: max(size.height, 0))
//    }
//}

