//
//  SingleSelectionView.swift
//  DigiMeSDKExample
//
//  Created on 14/06/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import SwiftUI

struct SingleSelectionView: View {
    @Binding var selectedItem: AggregationMethod
    var items: [AggregationMethod]

    var body: some View {
        VStack {
            ForEach(items) { item in
                HStack {
                    Text(item.rawValue)
                    Spacer()
                    if item == selectedItem {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(item == selectedItem ? Color.blue.opacity(0.2) : Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(item == selectedItem ? Color.accentColor : Color(.systemGray6), lineWidth: 2)
                        .padding(1)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedItem = item
                }
            }
        }
        .cornerRadius(10)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("pickerItemColor"), lineWidth: 2)
                .padding(2)
        )
    }
}

struct SingleSelectionViewPreview: View {
    @State private var selectedAggregationMethod: AggregationMethod = AggregationMethod.allCases.first!

    var body: some View {
        SingleSelectionView(selectedItem: $selectedAggregationMethod, items: AggregationMethod.allCases)
    }
}

#Preview {
    SingleSelectionViewPreview()
        .padding()
}
