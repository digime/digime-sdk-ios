//
//  ModalDialogView.swift
//  DigiMeSDKExample
//
//  Created on 15/08/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI

struct ModalDialogView: View {
    @Binding var isPresented: Bool

    let title: String
    let message: String
    let cancelButtonTitle: String
    let proceedButtonTitle: String
    let cancelAction: () -> Void
    let proceedAction: () -> Void

    @State private var offset: CGFloat = 1000
    @State private var contentHeight: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        dismissModal()
                    }

                VStack(spacing: 20) {
                    Text(title)
                        .font(.headline)
                        .padding(.top)

                    ScrollView {
                        Text(message)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .background(GeometryReader { textGeometry in
                                Color.clear.preference(key: ContentHeightPreferenceKey.self, value: textGeometry.size.height)
                            })
                    }
                    .frame(maxHeight: min(contentHeight, geometry.size.height * 0.5))

                    HStack(spacing: 10) {
                        Button(cancelButtonTitle) {
                            dismissModal()
                            cancelAction()
                        }
                        .buttonStyle(ModalButtonStyle(isDestructive: true))
                        .frame(maxWidth: .infinity)

                        Button(proceedButtonTitle) {
                            dismissModal()
                            proceedAction()
                        }
                        .buttonStyle(ModalButtonStyle())
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(20)
                .shadow(radius: 20)
                .frame(width: min(geometry.size.width * 0.9, 300))
                .frame(maxHeight: geometry.size.height * 0.8)
                .offset(y: offset)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        .opacity(isPresented ? 1 : 0)
        .animation(.spring(), value: offset)
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                withAnimation {
                    offset = 0
                }
            }
        }
        .onPreferenceChange(ContentHeightPreferenceKey.self) { height in
            self.contentHeight = height
        }
    }

    private func dismissModal() {
        withAnimation {
            offset = 1000
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct ModalButtonStyle: ButtonStyle {
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(isDestructive ? Color.gray.opacity(0.2) : Color.blue)
            .foregroundColor(isDestructive ? .primary: .white)
            .fontWeight(isDestructive ? .regular : .bold)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct ModalDialogView_Preview: View {
    @State private var showModal = false
    @State private var messageType: MessageType = .short

    enum MessageType {
        case short, medium, long, veryLong
    }

    var message: String {
        switch messageType {
        case .short:
            return "This is a short message."
        case .medium:
            return "This is a medium-length message that spans a couple of lines to demonstrate how the dialog adapts."
        case .long:
            return "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        case .veryLong:
            return String(repeating: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ", count: 20)
        }
    }

    var body: some View {
        VStack {
            Button("Show Modal") {
                showModal = true
            }
            Picker("Message Length", selection: $messageType) {
                Text("Short").tag(MessageType.short)
                Text("Medium").tag(MessageType.medium)
                Text("Long").tag(MessageType.long)
                Text("Very Long").tag(MessageType.veryLong)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            ModalDialogView(
                isPresented: $showModal,
                title: "Confirmation",
                message: message,
                cancelButtonTitle: "Cancel",
                proceedButtonTitle: "Proceed",
                cancelAction: {
                    print("Cancelled")
                },
                proceedAction: {
                    print("Proceeded")
                }
            )
            .opacity(showModal ? 1 : 0)
        )
    }
}

#Preview {
    ModalDialogView_Preview()
}
