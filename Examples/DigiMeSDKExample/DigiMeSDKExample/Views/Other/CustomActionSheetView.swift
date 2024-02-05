//
//  CustomActionSheetView.swift
//  DigiMeSDKExample
//
//  Created on 10/11/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct CustomActionSheetView: View {
    @Binding var isPresented: Bool
    let buttons: [CustomActionSheetButton]
    let title: String
    let message: String?

    var body: some View {
        ZStack {
            // Overlay to dismiss when tapping outside
            if isPresented {
                Color.black.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            self.isPresented = false
                        }
                    }
            }
            
            // Action Sheet Content
            if isPresented {
                VStack {
                    Spacer()
                    actionSheetContent
                }
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0))
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

            ForEach(buttons.indices, id: \.self) { index in
                buttons[index]
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(radius: 1)
            }

            CustomActionSheetButton(title: "Cancel", subtitle: nil, action: {
                withAnimation {
                    self.isPresented = false
                }
            })
            .background(Color(.tertiarySystemGroupedBackground))
            .cornerRadius(10)
            .shadow(radius: 3)
        }
        .padding(20)
    }
}

// MARK: - Preview

struct CustomActionSheetViewPreview: View {
    @State private var showingActionSheet = false
    
    var body: some View {
        ZStack {
            Button("Show Action Sheet") {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                    showingActionSheet = true
                }
            }
            
            if showingActionSheet {
                CustomActionSheetView(isPresented: $showingActionSheet,
                                      buttons: customActionSheetButtons(),
                                      title: "Sample Datasets",
                                      message: "Choose one to proceed")
                .transition(.move(edge: .bottom))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    func customActionSheetButtons() -> [CustomActionSheetButton] {
        let buttons = [
            CustomActionSheetButton(title: "Option 1", subtitle: nil, action: {
                dismiss()
            }),
            CustomActionSheetButton(title: "Option 2", subtitle: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.", action: {
                dismiss()
            }),
            CustomActionSheetButton(title: "Option 3", subtitle: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.", action: {
                dismiss()
            }),
        ]
        return buttons
    }
    
    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
            showingActionSheet = false
        }
    }
}

struct CustomActionSheetView_Preview: PreviewProvider {
    static var previews: some View {
        CustomActionSheetViewPreview()
//            .environment(\.colorScheme, .dark)
    }
}
