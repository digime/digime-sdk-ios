//
//  ScopeServiceObjectTypesRow.swift
//  DigiMeSDKExample
//
//  Created on 11/05/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct ScopeServiceObjectTypesRow: View {
    @ObservedObject var viewModel: ScopeViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "doc.on.doc")
                .frame(width: 30, height: 30, alignment: .center)
            Text("Service Object Types")
            Spacer()
        }

        if $viewModel.objectTypes.isEmpty {
            Text("No service selected")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        else {
            VStack(alignment: .leading) {
                ForEach(Array(zip(viewModel.objectTypes.indices, viewModel.objectTypes)), id: \.1.id) { index, template in
                    VStack {
                        HStack {
                            ScopeObjectTypeIconView(name: template.name ?? "X", size: 35)
                                .padding(.trailing, 5)

                            Text(template.name ?? "none")
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if viewModel.selectedObjectTypes.contains(template.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }

                            Spacer()
                        }
                        .frame(minHeight: 40)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if viewModel.isObjectTypeEditingAllowed {
                                if viewModel.selectedObjectTypes.contains(template.id) {
                                    viewModel.selectedObjectTypes.remove(template.id)
                                }
                                else {
                                    viewModel.selectedObjectTypes.insert(template.id)
                                }
                            }
                        }

                        if index != viewModel.objectTypes.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ScopeServiceObjectTypesRow(viewModel: ScopeViewModel())
}
