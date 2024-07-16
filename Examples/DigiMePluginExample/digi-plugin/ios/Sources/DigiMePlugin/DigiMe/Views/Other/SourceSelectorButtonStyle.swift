//
//  SourceSelectorButtonStyle.swift
//  DigiMeSDKExample
//
//  Created on 03/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftUI

struct SourceSelectorButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    var padding: CGFloat
    var strokeColor: Color

    init(backgroundColor: Color, foregroundColor: Color, padding: CGFloat, strokeColor: Color = .clear) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.padding = padding
        self.strokeColor = strokeColor
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(padding)
            .foregroundColor(configuration.isPressed ? .white : foregroundColor)
            .background(configuration.isPressed ? .accentColor : backgroundColor)
            .cornerRadius(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(strokeColor, lineWidth: configuration.isPressed ? 0 : 2)
            }
    }
}
