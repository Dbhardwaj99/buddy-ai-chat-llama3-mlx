//
//  Created by Alex.M on 02.10.2023.
//

import Foundation
import Combine
import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public final class KeyboardState: ObservableObject {
    @Published private(set) public var isShown: Bool = false

    private var subscriptions = Set<AnyCancellable>()

    init() {
        #if os(iOS)
        subscribeKeyboardNotifications()
        #elseif os(macOS)
        subscribeMacKeyboardMonitoring()
        #endif
    }
}

private extension KeyboardState {
    #if os(iOS)
    func subscribeKeyboardNotifications() {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .receive(on: RunLoop.main)
        .assign(to: \.isShown, on: self)
        .store(in: &subscriptions)
    }
    #elseif os(macOS)
    func subscribeMacKeyboardMonitoring() {
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self = self else { return event }
            let hasFocusedField = NSApp.keyWindow?.firstResponder is NSTextView
            DispatchQueue.main.async {
                self.isShown = hasFocusedField
            }
            return event
        }
    }
    #endif
}
