//
//  EditableTextAndActionView.swift
//  DigiMeSDKExample
//
//  Created on 23/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI

struct EditableTextAndActionView: View {
    @Binding var text: String
    @Binding var disabled: Bool

    var placeholderText: String
    
    var actionTitle: String
    var action: (() -> Void)?

    var action2Title: String?
    var action2: (() -> Void)?

    var action3Title: String?
    var action3: (() -> Void)?

    var action4Title: String?
    var action4: (() -> Void)?

    var action5Title: String?
    var action5: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            TextField(placeholderText, text: $text)
                .font(.caption2)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .disabled(disabled)

            actionButton(actionTitle: actionTitle, action: action)

            if 
                let additionalAction2Title = action2Title,
                let additionalAction2 = action2 {
                actionButton(actionTitle: additionalAction2Title, action: additionalAction2)
            }

            if 
                let additionalAction3Title = action3Title,
                let additionalAction3 = action3 {
                actionButton(actionTitle: additionalAction3Title, action: additionalAction3)
            }

            if
                let additionalAction4Title = action4Title,
                let additionalAction4 = action4 {
                actionButton(actionTitle: additionalAction4Title, action: additionalAction4)
            }

            if
                let additionalAction5Title = action5Title,
                let additionalAction5 = action5 {
                actionButton(actionTitle: additionalAction5Title, action: additionalAction5)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func actionButton(actionTitle: String, action: (() -> Void)?) -> some View {
        Button {
            action?()
        } label: {
            HStack {
                Text(actionTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            .foregroundColor(.white)
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(disabled ? .gray : Color.accentColor)
            )
        }
        .frame(maxWidth: .infinity)
        .disabled(disabled)
    }
}

struct EditableTextAndActionPreview: View {
    @State private var text = "This text is editable and selectable."
    @State private var disabled: Bool = false

    var body: some View {
        ZStack {
            Color.gray

            VStack {
                EditableTextAndActionView(
                    text: $text,
                    disabled: $disabled,
                    placeholderText: "Enter some text here...",
                    actionTitle: "Action",
                    action: { print("Main action triggered") },
                    action2Title: "Action 2",
                    action2: { print("Action 2 triggered") },
                    action3Title: "Action 3",
                    action3: { print("Action 3 triggered") }
                )
            }
            .padding()
        }
    }
}

#Preview {
    EditableTextAndActionPreview()
}
