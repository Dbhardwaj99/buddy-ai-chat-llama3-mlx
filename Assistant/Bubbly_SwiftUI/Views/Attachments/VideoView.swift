//
//  VideoView.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 13/12/24.
//

import Foundation
import SwiftUI
import AVKit

struct VideoView: View {

    @EnvironmentObject var mediaPagesViewModel: FullscreenMediaPagesViewModel
    @Environment(\.chatTheme) private var theme

    @StateObject var viewModel: VideoViewModel

    var body: some View {
        Group {
            if let player = viewModel.player, viewModel.status == .readyToPlay {
                content(for: player)
            } else {
                ActivityIndicator()
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            viewModel.onStart()

            mediaPagesViewModel.toggleVideoPlaying = {
                viewModel.togglePlay()
            }
            mediaPagesViewModel.toggleVideoMuted = {
                viewModel.toggleMute()
            }
        }
        .onDisappear {
            viewModel.onStop()
        }
        .onChange(of: viewModel.isPlaying) { newValue in
            mediaPagesViewModel.videoPlaying = newValue
        }
        .onChange(of: viewModel.isMuted) { newValue in
            mediaPagesViewModel.videoMuted = newValue
        }
        .onChange(of: viewModel.status) { status in
            print("Player Status: \(status)")  // Debugging line to check player status
            if status == .readyToPlay {
                viewModel.togglePlay()
            }
        }
    }

    func content(for player: AVPlayer) -> some View {
        VideoPlayer(player: player)
    }
}
