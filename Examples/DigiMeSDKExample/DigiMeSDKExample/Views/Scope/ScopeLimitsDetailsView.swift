//
//  ScopeLimitsDetailsView.swift
//  DigiMeSDKExample
//
//  Created on 16/05/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import SwiftUI

struct ScopeLimitsDetailsView: View {
    @ObservedObject var viewModel: ScopeViewModel
    
    init(viewModel: ScopeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.durationOptions, id: \.sourceFetch) { item in
                    Button {
                        viewModel.selectedDuration = item
                    } label: {
                        HStack {
                            let sourceFetch = item.sourceFetch
                            Text(sourceFetch == 0 ? "unlimited" : (sourceFetch >= 60 ? "\(sourceFetch / 60) min" : "\(sourceFetch) sec"))
                            
                            Spacer()
                            
                            if item.sourceFetch == viewModel.selectedDuration.sourceFetch {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .buttonStyle(SourceSelectorButtonStyle(backgroundColor: Color("pickerItemColor"), foregroundColor: .primary, padding: 15))
                }
            }
            .padding()
        }
    }
}

#Preview {
    ScopeLimitsDetailsView(viewModel: ScopeViewModel())
}
