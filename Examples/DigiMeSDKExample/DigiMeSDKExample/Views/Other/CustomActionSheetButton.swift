//
//  CustomActionSheetButton.swift
//  DigiMeSDKExample
//
//  Created on 20/01/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI

struct CustomActionSheetButton: View {
    let title: String
    let subtitle: String?
    let isDestructive = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 3) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(CustomActionSheetButtonStyle(backgroundColor: Color(.tertiarySystemGroupedBackground), foregroundColor: isDestructive ? .accentColor : .primary))
    }
}

struct CustomActionSheetButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .white : foregroundColor)
            .background(configuration.isPressed ? .accentColor : backgroundColor)
            .cornerRadius(10)
    }
}

#Preview {
    CustomActionSheetButton(title: "Test Title", subtitle: "Test Subtitle") {}
}
