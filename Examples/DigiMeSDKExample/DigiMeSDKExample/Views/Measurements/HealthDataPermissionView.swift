//
//  HealthDataPermissionView.swift
//  DigiMeSDKExample
//
//  Created on 02/04/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeHealthKit
import SwiftUI

struct HealthDataPermissionView: View {
    @Binding var navigationPath: NavigationPath
    var onProceed: (([QuantityType]?) -> Void)?

    @StateObject private var height = HealthDataType(type: QuantityType.height)
    @StateObject private var bodyMass = HealthDataType(type: QuantityType.bodyMass)
    @StateObject private var bodyTemperature = HealthDataType(type: QuantityType.bodyTemperature)
    @StateObject private var bloodGlucose = HealthDataType(type: QuantityType.bloodGlucose)
    @StateObject private var oxygenSaturation = HealthDataType(type: QuantityType.oxygenSaturation)
    @StateObject private var respiratoryRate = HealthDataType(type: QuantityType.respiratoryRate)
    @StateObject private var heartRate = HealthDataType(type: QuantityType.heartRate)
    @StateObject private var bloodPressureSystolic = HealthDataType(type: QuantityType.bloodPressureSystolic)
    @StateObject private var bloodPressureDiastolic = HealthDataType(type: QuantityType.bloodPressureDiastolic)

    @State private var healthDataTypes: [HealthDataType] = []
    @State private var updateToggleState = false
    @State private var toggled = true

    private var footer: some View {
        Text("Allow this app to import your Apple Health data. On the next step you will be prompted to choose the time range.")
            .padding(.horizontal, 20)
            .font(.footnote)
            .foregroundColor(.gray)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Toggle(toggled ? "Turn Off All" : "Turn On All", isOn: $toggled)
                    .onChange(of: toggled) { _, newValue in
                        toggleHealthDataTypes(newValue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.systemGray6))
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
                    .padding(.vertical, 15)

                Text("Apple Health Data Types")
                    .foregroundColor(.gray)
                    .textCase(.uppercase)

                ForEach($healthDataTypes.indices, id: \.self) { index in
                    HealthDataToggleView(healthDataType: $healthDataTypes[index]) {
                        updateToggleState.toggle()
                    }
                }

                Button {
                    proceed()
                } label: {
                    HStack {
                        Text("Next")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.white)
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(canProceed ? Color.accentColor : .gray)
                    )
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .disabled(!canProceed)

                footer
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            initDefault()
            toggleHealthDataTypes(toggled)
        }
        .scrollIndicators(.hidden)
        .navigationBarTitle("Sources", displayMode: .large)
    }

    private func initDefault() {
        healthDataTypes = [
            height, bodyMass, bodyTemperature, bloodGlucose, oxygenSaturation, respiratoryRate, heartRate, bloodPressureSystolic, bloodPressureDiastolic
        ]
    }
    
    private func toggleHealthDataTypes(_ isToggled: Bool) {
        healthDataTypes.forEach { $0.isToggled = isToggled }
    }

    private var canProceed: Bool {
        return healthDataTypes.contains { $0.isToggled }
    }

    private func proceed() {
        let selected = healthDataTypes.filter { $0.isToggled }.compactMap { $0.type as? QuantityType }
        onProceed?(selected)
        navigationPath.append(HealthDataNavigationDestination.dateRange)
    }
}

fileprivate struct HealthDataToggleView: View {
    @Binding var healthDataType: HealthDataType
    var onUpdate: () -> Void

    var body: some View {
        HStack {
            Image(systemName: healthDataType.systemIcon)
                .renderingMode(.original)
                .foregroundColor(healthDataType.iconColor)
                .frame(width: 30, height: 30)
            Text(healthDataType.name)
            Spacer()
            Toggle("", isOn: $healthDataType.isToggled)
                .onChange(of: healthDataType.isToggled) { _, _ in
                    onUpdate()
                }
                .labelsHidden()
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
    }
}

#Preview {
    NavigationStack {
        HealthDataPermissionView(navigationPath: .constant(NavigationPath()))
            .navigationBarItems(trailing: Text("Cancel").foregroundColor(.accentColor))
            .preferredColorScheme(.dark)
    }
}
