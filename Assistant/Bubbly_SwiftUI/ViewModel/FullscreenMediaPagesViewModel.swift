//
//  FullscreenMediaPagesViewModel.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import Foundation
import Combine

final class FullscreenMediaPagesViewModel: ObservableObject {
    var attachments: [Attachment]
    @Published var index: Int

    @Published var showMinis = true
    @Published var offset: CGSize = .zero

    @Published var videoPlaying = false
    @Published var videoMuted = false

    @Published var toggleVideoPlaying = {}
    @Published var toggleVideoMuted = {}

    init(attachments: [Attachment], index: Int) {
        self.attachments = attachments
        self.index = index
    }
}
