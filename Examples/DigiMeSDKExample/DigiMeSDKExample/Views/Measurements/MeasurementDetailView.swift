//
//  MeasurementDetailView.swift
//  DigiMeSDKExample
//
//  Created on 16/08/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct MeasurementDetailView: View {
    @Bindable var measurement: SelfMeasurement

    private var receiptsArray: [SelfMeasurementReceipt] {
        let unsortedReceipts: [SelfMeasurementReceipt] = measurement.receipts
        return unsortedReceipts.sorted { lhs, rhs in
            return lhs > rhs
        }
    }
    
    private var commentRows: [(placeholder: String, text: String)] {
        var rows = [(placeholder: String, text: String)]()
        
        if let comment = measurement.comment {
            rows.append((placeholder: "Comment:", text: comment))
        }
        
        if let name = measurement.commentName {
            rows.append((placeholder: "Name:", text: name))
        }
        
        if let code = measurement.commentCode {
            rows.append((placeholder: "Code:", text: code))
        }
        
        if let timing = measurement.commentTiming {
            rows.append((placeholder: "Timing:", text: timing))
        }
        
        return rows
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    VStack(alignment: .center, spacing: 10) {
                        Text(measurement.typeDescription)
                            .font(.title)
                        
                        HStack(alignment: .center, spacing: 5) {
                            if let component = measurement.components.first {
                                let value = component.measurementValue
                                
                                Text("\(value)")
                                    .font(.headline)
                                
                                Text(component.display.lowercased())
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        if measurement.components.count > 1 {
                            HStack(alignment: .center, spacing: 5) {
                                let component = measurement.components[1]
                                let value = component.measurementValue
                                
                                Text("\(value)")
                                    .font(.headline)
                                
                                Text(component.display.lowercased())
                                    .font(.headline)
                            }
                        }
                        
                        Text("Recorded on \(dateFormatter.string(from: measurement.createdDate))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 10)
                    }
                    
                    ForEach(commentRows, id: \.placeholder) { row in
                        getRow(placeholder: row.placeholder, text: row.text)
                    }
                    
                    if !receiptsArray.isEmpty {
                        Section(header: Text("Shared with:")) {
                            ForEach(receiptsArray, id: \.self) { receipt in
                                HStack {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(receipt.providerName)
                                            .font(.headline)
                                        
                                        Text(dateFormatter.string(from: receipt.shareDate))
                                            .font(.caption)
                                    }
                                    .padding(15)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color(.secondarySystemBackground))
                                    )
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
                .navigationBarTitle("Details", displayMode: .inline)
            }
        }
    }
    
    private func getRow(placeholder: String, text: String) -> some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(placeholder)
                    Spacer()
                }
                
                Text(text)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(5)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
            }
            .foregroundColor(.primary)
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    let button = Text("Cancel")
        .font(.headline)
        .foregroundColor(.accentColor)
    let previwer = try? Previewer()
    return NavigationView {
        MeasurementDetailView(measurement: previwer!.measurement)
            .modelContainer(previwer!.container)
            .navigationBarItems(trailing: button)
            .environment(\.colorScheme, .light)
    }
}
