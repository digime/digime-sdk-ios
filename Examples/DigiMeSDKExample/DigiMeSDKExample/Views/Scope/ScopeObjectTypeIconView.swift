//
//  ScopeObjectTypeIconView.swift
//  DigiMeSDKExample
//
//  Created on 05/05/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct ScopeObjectTypeIconView: View {
    let name: String
    let size: CGFloat
        
    var body: some View {
        Text(initials())
            .font(.system(size: fontSize()))
            .foregroundColor(.black)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(randomColor())
            )
            .overlay(
                Circle()
                    .stroke(Color.gray, lineWidth: 0.5)
            )
    }
    
    private func fontSize() -> CGFloat {
        let adjustedFontSize = size * 0.35
        return adjustedFontSize
    }
    
    private func randomColor() -> Color {
        let pastelColorRange: ClosedRange<Double> = 0.6...1.0
        let red = Double.random(in: pastelColorRange)
        let green = Double.random(in: pastelColorRange)
        let blue = Double.random(in: pastelColorRange)
        return Color(red: red, green: green, blue: blue)
    }
    
    private func initials() -> String {
        let components = name.split(separator: " ")
        let initials = components.map { String($0.prefix(1)) }

        if initials.count > 3 {
            let firstThreeInitials = initials.prefix(3)
            return firstThreeInitials.joined() + "."
        }
        else {
            return initials.joined()
        }
    }
}

struct ObjectTypeIconView_Previews: PreviewProvider {
    static var previews: some View {
        ScopeObjectTypeIconView(name: "Activity Summary", size: 35)
    }
}
