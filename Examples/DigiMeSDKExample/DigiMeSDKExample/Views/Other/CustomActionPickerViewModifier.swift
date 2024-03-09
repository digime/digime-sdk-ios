//
//  CustomActionPickerViewModifier.swift
//  DigiMeSDKExample
//
//  Created on 19/01/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI

struct CustomActionPickerViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    @State private var proceed = false
    @State private var cancel = false
    @State private var selectedItem: CustomActionPickerViewButtonData?

    let title: String
    let message: String?

    var buttons: [CustomActionPickerViewButtonData] = []

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isPresented)
                .overlay(isPresented ? Color.black.opacity(0.2) : Color.clear)

            if isPresented {
                VStack {
                    Spacer()
                    actionSheetContent
                }
                .transition(.move(edge: .bottom))
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
            }
        }
        .onAppear {
            updateSelectedItemIfNeeded()
        }
        .onChange(of: buttons) { _, _ in
            updateSelectedItemIfNeeded()
        }
        .onTapGesture {
            dismiss()
        }
    }

    private var actionSheetContent: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack {
                Text(title)
                    .font(.headline)

                if let subtitle = message {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))

            Picker("", selection: $selectedItem) {
                ForEach(buttons, id: \.title) { value in
                    Text(value.title).tag(value as CustomActionPickerViewButtonData?)
                }
                .frame(minHeight: 60)
            }
            .pickerStyle(.wheel)
            .frame(height: 100)
            .padding(.horizontal)

            if let subtitle = selectedItem?.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.leading)
            }

            SectionView {
                makeCustomButton(isPressed: $proceed, destructive: true, buttonText: "Proceed", backgroundColor: Color(.secondarySystemGroupedBackground)) {
                    selectedItem?.action()
                    self.isPresented = false
                }
                makeCustomButton(isPressed: $cancel, destructive: false, buttonText: "Cancel", backgroundColor: Color(.secondarySystemGroupedBackground)) {
                    self.isPresented = false
                }
            }
        }
        .background(Color(.systemBackground))
        .mask(RoundedRectangle(cornerRadius: 20))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(.horizontal, 20)
    }

    private func updateSelectedItemIfNeeded() {
        if
            selectedItem == nil,
            let firstItem = buttons.first {

            selectedItem = firstItem
        }
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
            isPresented = false
        }
    }
}

extension CustomActionPickerViewModifier {
    @ViewBuilder
    func makeCustomButton(isPressed: Binding<Bool>, destructive: Bool, buttonText: String, backgroundColor: Color, action: @escaping () -> Void) -> some View {
        GenericPressableButtonView(isPressed: isPressed) {
            action()
        } content: {
            HStack {
                Text(buttonText)
                    .foregroundColor(isPressed.wrappedValue ? .white : .accentColor)
                    .fontWeight(destructive ? .bold : .regular)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isPressed.wrappedValue ? .accentColor : backgroundColor)
        }
    }
}

extension View {
    func customActionPickerView(isPresented: Binding<Bool>, title: String, message: String, buttons: [CustomActionPickerViewButtonData]) -> some View {
        self.modifier(CustomActionPickerViewModifier(isPresented: isPresented, title: title, message: message, buttons: buttons))
    }
}

struct CustomPickerPreview: View {
    @State private var showingActionSheet = false

    var body: some View {
        ZStack {
            Button("Show Action Sheet") {
                showDialog()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .customActionPickerView(isPresented: $showingActionSheet, title: "Actions", message: "Please choose an option", buttons: [
                CustomActionPickerViewButtonData(title: "Dataset 1", subtitle: nil) {
                    dismiss()
                },
                CustomActionPickerViewButtonData(title: "Dataset 2", subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.") {
                    dismiss()
                },
                CustomActionPickerViewButtonData(title: "Dataset 3", subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.") {
                    dismiss()
                },
            ])
        }
    }

    private func showDialog() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
            showingActionSheet = true
        }
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
            showingActionSheet = false
        }
    }
}

#Preview {
    CustomPickerPreview()
}
