//
//  View+StatusBar.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import SwiftUI
//import UIKit

public extension View {

    /// for this to work make sure all the other scrollViews have scrollsToTop = false
    func onStatusBarTap(onTap: @escaping () -> ()) -> some View {
        self.overlay {
            StatusBarTabDetector(onTap: onTap)
                .offset(x: UIScreen.main.bounds.width)
        }
    }
}

private struct StatusBarTabDetector: UIViewRepresentable {

    var onTap: () -> ()

    func makeUIView(context: Context) -> UIView {
        let fakeScrollView = UIScrollView()
        fakeScrollView.contentOffset = CGPoint(x: 0, y: 10)
        fakeScrollView.delegate = context.coordinator
        fakeScrollView.scrollsToTop = true
        fakeScrollView.contentSize = CGSize(width: 100, height: UIScreen.main.bounds.height * 2)
        return fakeScrollView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {

        var onTap: () -> ()

        init(onTap: @escaping () -> ()) {
            self.onTap = onTap
        }

        func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
            onTap()
            return false
        }
    }
}

extension View {

    func transparentNonAnimatingFullScreenCover<Item, Content>(item: Binding<Item?>, @ViewBuilder content: @escaping () -> Content) -> some View where Item : Equatable, Item : Identifiable, Content : View {
        modifier(TransparentNonAnimatableFullScreenModifier(item: item, fullScreenContent: content))
    }
}

private struct TransparentNonAnimatableFullScreenModifier<Item, FullScreenContent>: ViewModifier where Item : Equatable, Item : Identifiable, FullScreenContent : View {

    @Binding var item: Item?
    let fullScreenContent: () -> (FullScreenContent)

    func body(content: Content) -> some View {
        content
            .onChange(of: item) { _ in
                UIView.setAnimationsEnabled(false)
            }
            .fullScreenCover(item: $item) { _ in
                ZStack {
                    fullScreenContent()
                }
                .background(FullScreenCoverBackgroundRemovalView())
                .onAppear {
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
                .onDisappear {
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
            }
    }

}

private struct FullScreenCoverBackgroundRemovalView: UIViewRepresentable {

    private class BackgroundRemovalView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }

    func makeUIView(context: Context) -> UIView {
        return BackgroundRemovalView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

}
