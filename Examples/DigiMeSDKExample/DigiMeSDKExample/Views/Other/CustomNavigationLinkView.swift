//
//  CustomNavigationLinkView.swift
//  DigiMeSDKExample
//
//  Created on 19/11/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct CustomNavigationLinkView<Content: View, Destination: View>: View {
    @State private var isPressed = false
    
    let destination: Destination
    let content: Content
    let action: () -> Void

    init(destination: Destination, @ViewBuilder content: () -> Content, action: @escaping () -> Void = {}) {
        self.destination = destination
        self.content = content()
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            content
                .foregroundColor(isPressed ? .white : .primary) // Change text color on press
                .background(isPressed ? Color.blue : Color.clear) // Change background color on press
        }
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in
            isPressed = true
        }.onEnded { _ in
            isPressed = false
        })
        .background(
            NavigationLink(destination: destination) {
                EmptyView()
            }
            .hidden()
        )
    }
}

#Preview {
    CustomNavigationLinkView(destination: Text("Destination View")) {
        Text("Navigate")
    }
}
