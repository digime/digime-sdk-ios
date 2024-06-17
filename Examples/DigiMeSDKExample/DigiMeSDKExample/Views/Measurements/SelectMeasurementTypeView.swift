//
//  SelectMeasurementTypeView.swift
//  DigiMeSDKExample
//
//  Created on 13/06/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct SelectMeasurementTypeView: View {
    @Binding var selection: SelfMeasurementType
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        
        VStack(alignment: .leading, spacing: 15) {
            Text("Measurement Type")
                .fontWeight(.black)
                .font(.title)
                .padding(.bottom, 14)
            
            Button {
                selection = .heartRate
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    mode.wrappedValue.dismiss()
                }
            } label: {
                HStack {
                    Text(SelfMeasurementType.heartRate.description)
                    Spacer()
                    if selection == .heartRate {
                        Image(systemName: "checkmark")
                    }
                }
                .foregroundColor(.primary)
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selection == .heartRate ? Color.blue.opacity(0.2) : Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(selection == .heartRate ? Color.blue : Color.clear, lineWidth: 2)
                )
            }
            
            Button {
                selection = .weight
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    mode.wrappedValue.dismiss()
                }
            } label: {
                HStack {
                    Text(SelfMeasurementType.weight.description)
                    Spacer()
                    if selection == .weight {
                        Image(systemName: "checkmark")
                    }
                }
                .foregroundColor(.primary)
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selection == .weight ? Color.blue.opacity(0.2) : Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(selection == .weight ? Color.blue : Color.clear, lineWidth: 2)
                )
            }
            
            Button {
                selection = .height
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    mode.wrappedValue.dismiss()
                }
            } label: {
                HStack {
                    Text(SelfMeasurementType.height.description)
                    Spacer()
                    if selection == .height {
                        Image(systemName: "checkmark")
                    }
                }
                .foregroundColor(.primary)
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selection == .height ? Color.blue.opacity(0.2) : Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(selection == .height ? Color.blue : Color.clear, lineWidth: 2)
                )
            }
            
            Button {
                selection = .bloodPressure
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    mode.wrappedValue.dismiss()
                }
            } label: {
                HStack {
                    Text(SelfMeasurementType.bloodPressure.description)
                    Spacer()
                    if selection == .bloodPressure {
                        Image(systemName: "checkmark")
                    }
                }
                .foregroundColor(.primary)
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selection == .bloodPressure ? Color.blue.opacity(0.2) : Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(selection == .bloodPressure ? Color.blue : Color.clear, lineWidth: 2)
                )
            }
            
            Button {
                selection = .bloodGlucose
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    mode.wrappedValue.dismiss()
                }
            } label: {
                HStack {
                    Text(SelfMeasurementType.bloodGlucose.description)
                    Spacer()
                    if selection == .bloodGlucose {
                        Image(systemName: "checkmark")
                    }
                }
                .foregroundColor(.primary)
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selection == .bloodGlucose ? Color.blue.opacity(0.2) : Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(selection == .bloodGlucose ? Color.blue : Color.clear, lineWidth: 2)
                )
            }
        }
        .navigationBarTitle("Add a measurement", displayMode: .inline)
        .padding(20)
        
        Spacer()
    }
}

#Preview {
    SelectMeasurementTypeView(selection: .constant(SelfMeasurementType.heartRate))
}
