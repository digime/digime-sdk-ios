//
//  BlurView.swift
//  DigiMeSDKExample
//
//  Created on 29/03/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemUltraThinMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

extension View {
    func backgroundBlurEffect() -> some View {
        self.background(BlurView(style: .systemThinMaterialDark))
    }
}
