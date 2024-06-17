//
//  ViewMeasurementsView.swift
//  DigiMeSDKExample
//
//  Created on 01/07/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftData
import SwiftUI

struct ViewMeasurementsView: View {
    @Binding var navigationPath: NavigationPath

    @EnvironmentObject private var viewModel: MeasurementsViewModel
    
    @State private var isEditViewPresented = false
    @State private var measurementToEdit: SelfMeasurement?

    @Query(sort: [
        SortDescriptor(\SelfMeasurement.createdDate, order: .reverse)
    ]) private var measurements: [SelfMeasurement]

    var body: some View {
        List {
            ForEach(measurements, id: \.self) { measurement in
                NavigationLink(destination: MeasurementDetailView(measurement: measurement)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 5) {
                                Text(measurement.typeDescription)
                                    .font(.headline)

                                if !measurement.components.isEmpty {

                                    // Extract the first component and check if it's valid
                                    if let firstComponent = measurement.components.first {
                                        let firstValue = firstComponent.measurementValue
                                        if measurement.components.count == 1 {
                                            Text("\(firstValue)")
                                                .font(.headline)

                                            if
                                                let unit = measurement.components.first?.display {

                                                Text(unit.lowercased())
                                                    .font(.headline)
                                            }
                                        }
                                        else if measurement.components.count > 1 {
                                            let secondComponent = measurement.components[1]
                                            let secondValue = secondComponent.measurementValue

                                            Text("\(firstValue) / \(secondValue) mmhg")
                                                .font(.headline)
                                        }
                                    }
                                }
                            }

                            Text("Recorded on \(dateFormatter.string(from: measurement.createdDate))")
                                .font(.caption)
                        }
                        Spacer()
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        measurementToEdit = measurement
                        isEditViewPresented = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.orange)

                    Button {
                        viewModel.delete(measurement: measurement)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
            .onDelete(perform: viewModel.deleteMeasurement)
        }
        .navigationBarTitle("Measurements", displayMode: .inline)
        .navigationBarItems(
            trailing: AnyView(editButton)
        )
        .sheet(item: $measurementToEdit) { measurement in
            EditMeasurementView(navigationPath: navigationPath, measurement: measurement)
                .environmentObject(viewModel)
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private var editButton: some View {
        EditButton()
    }
}

#Preview {
    let previewer = try? Previewer()
    let mockNavigationPath = NavigationPath()
    return NavigationStack {
        ViewMeasurementsView(navigationPath: .constant(mockNavigationPath))
            .environmentObject(MeasurementsViewModel(modelContainer: previewer!.container))
            .modelContainer(previewer!.container)
    }
}
