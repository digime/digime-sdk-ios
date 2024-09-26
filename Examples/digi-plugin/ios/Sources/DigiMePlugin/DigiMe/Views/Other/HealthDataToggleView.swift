//
//  HealthDataToggleView.swift
//  DigiMeSDKExample
//
//  Created on 06/09/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI
import DigiMeHealthKit

struct HealthDataToggleView: View {
    let healthDataType: HealthDataType
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Image(systemName: healthDataType.systemIcon)
                .renderingMode(.original)
                .foregroundColor(healthDataType.iconColor)
                .frame(width: 30, height: 30)
            Text(healthDataType.name)
            Spacer()
            Toggle("", isOn: Binding(
                get: { healthDataType.isToggled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }
}

#Preview {
    HealthDataToggleView(healthDataType: HealthDataType(type: DigiMeHealthKit.QuantityType.height, isToggled: true), onToggle: {})
}
