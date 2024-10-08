//
//  HealthDataPermissionView.swift
//  DigiMeSDKExample
//
//  Created on 10/06/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

#if canImport(SwiftData)
import DigiMeCore
import DigiMeHealthKit
import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct HealthDataPermissionView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var viewModel: HealthDataViewModel
    @State private var navigationPath = NavigationPath()
    @State private var updateToggleState = false
    @State private var allToggled: Bool = true

    init(viewModel: HealthDataViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(!viewModel.allToggled ? "turnOnAll".localized() : "turnOffAll".localized(), isOn: Binding(
                        get: { viewModel.allToggled },
                        set: { _ in viewModel.toggleAllHealthDataTypes() }
                    ))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.systemGray6))
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
                    .padding(.vertical, 15)

                    Text("appleHealthDataTypes".localized())
                        .foregroundColor(.gray)
                        .textCase(.uppercase)

                    ForEach(viewModel.healthDataTypes.indices, id: \.self) { index in
                        HealthDataToggleView(
                            healthDataType: viewModel.healthDataTypes[index],
                            onToggle: {
                                viewModel.toggleSingleHealthDataType(at: index)
                            }
                        )
                    }

                    footer
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var footer: some View {
        Text("allowImportAppleHealthData".localized())
            .padding(.horizontal, 20)
            .font(.footnote)
            .foregroundColor(.gray)
    }

    private func updateAllToggledState() {
        allToggled = viewModel.healthDataTypes.allSatisfy { $0.isToggled }
    }
}

@available(iOS 17.0, *)
#Preview {
    return NavigationStack {
        let previewer = try? Previewer()
        let viewModel = HealthDataViewModel(modelContainer: previewer!.container, cloudId: "CloudId", onComplete: nil)
        HealthDataPermissionView(viewModel: viewModel)
            .navigationBarItems(trailing: Text("Cancel").foregroundColor(.accentColor))
            .preferredColorScheme(.dark)
            .environmentObject(viewModel)
    }
}
#endif
