//
//  CustomActionSheetViewModifier.swift
//  DigiMeSDKExample
//
//  Created on 09/11/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct CustomActionSheetViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    let buttons: [CustomActionSheetButton]
    let title: String
    let message: String?

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
        .onTapGesture {
            dismiss()
        }
    }
    
    private var actionSheetContent: some View {
        VStack(spacing: 5) {
            VStack(alignment: .center, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.systemGray))
                
                if let subtitle = message {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .center)
            .contentShape(Rectangle())
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
            
            ForEach(0..<buttons.count, id: \.self) { index in
                buttons[index]
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(10)
                    .shadow(radius: 1)
            }
            
            CustomActionSheetButton(title: "Cancel", subtitle: nil) {
                dismiss()
            }
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(10)
            .shadow(radius: 3)
        }
        .padding(20)
    }
    
    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
            self.isPresented = false
        }
    }
}

extension View {
    func customActionSheet(isPresented: Binding<Bool>, title: String, message: String, buttons: [CustomActionSheetButton]) -> some View {
        self.modifier(CustomActionSheetViewModifier(isPresented: isPresented, buttons: buttons, title: title, message: message))
    }
}

// MARK: - Preview

struct CustomActionSheetPreview: View {
    @State private var showingActionSheet = false
    
    var body: some View {
        ZStack {
            Button("Show Action Sheet") {
                showDialog()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .customActionSheet(isPresented: $showingActionSheet, title: "Actions", message: "Please choose an option", buttons: [
                CustomActionSheetButton(title: "Dataset 1", subtitle: nil) {
                    dismiss()
                },
                CustomActionSheetButton(title: "Dataset 2", subtitle: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.") {
                    dismiss()
                },
                CustomActionSheetButton(title: "Dataset 3", subtitle: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.") {
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
    CustomActionSheetPreview()
        .environment(\.colorScheme, .dark)
}
