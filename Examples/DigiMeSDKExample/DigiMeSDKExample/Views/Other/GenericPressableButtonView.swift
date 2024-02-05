//
//  GenericPressableButtonView.swift
//  DigiMeSDKExample
//
//  Created on 15/11/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct GenericPressableButtonView<Content: View>: View {
    @Binding var isPressed: Bool
    let content: Content
    let action: () -> Void

    init(isPressed: Binding<Bool>, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self._isPressed = isPressed
        self.action = action
        self.content = content()
    }

    var body: some View {
        content
            .cornerRadius(10)
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isPressed = true }
                                .onEnded { value in
                                    self.isPressed = false
                                    // Check if the drag ended inside the view
                                    let location = value.location
                                    let frame = geometry.frame(in: .local)
                                    if frame.contains(location) {
                                        self.action()
                                    }
                                }
                        )
                }
            )
    }
}

// MARK: - Preview

struct GenericPressableButtonViewPreview: View {
    @State private var isPressed = false

    var body: some View {
        GenericPressableButtonView(isPressed: $isPressed, action: {
            print("Button pressed")
        }) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(isPressed ? .white : .yellow)
                Text("Favorite")
                    .foregroundColor(isPressed ? .white : .primary)
            }
            .padding()
            .background(isPressed ? Color.accentColor : Color.gray)
        }
        .previewLayout(.sizeThatFits)
    }
}

#Preview {
    GenericPressableButtonViewPreview()
}
