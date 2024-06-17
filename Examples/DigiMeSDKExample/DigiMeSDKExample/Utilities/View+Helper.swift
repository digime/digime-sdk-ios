//
//  View+Helper.swift
//  DigiMeSDKExample
//
//  Created on 05/03/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func makeCustomButton(imageName: String, buttonText: String, isPressed: Binding<Bool>, imageColor: Color, action: @escaping () -> Void) -> some View {
        GenericPressableButtonView(isPressed: isPressed, action: action) {
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(isPressed.wrappedValue ? .white : imageColor)
                    .frame(width: 30, height: 30, alignment: .center)
                Text(buttonText)
                    .foregroundColor(isPressed.wrappedValue ? .white : .accentColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundColor(isPressed.wrappedValue ? .white : .gray)
            }
            .padding(8)
            .padding(.horizontal, 10)
            .background(isPressed.wrappedValue ? .accentColor : Color(.secondarySystemGroupedBackground))
        }
    }

    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        }
        else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}
