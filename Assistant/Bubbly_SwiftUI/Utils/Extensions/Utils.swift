//
//  Utils.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import SwiftUI

extension View {

    func sizeGetter(_ size: Binding<CGSize>) -> some View {
        modifier(SizeGetter(size: size))
    }
}

extension Collection where Element == CGPoint {
    
    subscript (safe index: Index) -> CGPoint {
        return indices.contains(index) ? self[index] : .zero
    }
}

struct SizeGetter: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> Color in
                    if proxy.size != self.size {
                        DispatchQueue.main.async {
                            self.size = proxy.size
                        }
                    }
                    return Color.clear
                }
            )
    }
}

struct SubmenuButtonPreferenceKey: PreferenceKey {
    typealias Value = [CGSize]

    static var defaultValue: Value = []

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

struct SubmenuButtonPreferenceViewSetter: View {

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(key: SubmenuButtonPreferenceKey.self,
                            value: [geometry.frame(in: .global).size])
        }
    }
}
