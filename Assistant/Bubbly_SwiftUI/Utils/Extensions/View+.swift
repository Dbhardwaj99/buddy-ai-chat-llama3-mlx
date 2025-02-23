//
//  View+.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import SwiftUI

extension View {
    func viewSize(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }

    func circleBackground(_ color: Color) -> some View {
        self.background {
            Circle().fill(color)
        }
    }

    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool,
                                    alignment: Alignment = .leading,
                                    @ViewBuilder placeholder: () -> Content) -> some View {
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}
