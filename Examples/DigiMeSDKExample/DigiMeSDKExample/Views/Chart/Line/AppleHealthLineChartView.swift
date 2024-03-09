//
//  AppleHealthLineChartView.swift
//  DigiMeSDKExample
//
//  Created on 02/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Charts
import DigiMeCore
import DigiMeSDK
import SwiftUI

struct AppleHealthLineChartView: View {
	@ObservedObject var viewModel: AppleHealthChartViewModel
    @State private var timeRange: ChartTimeRange = .last30Days
    
    private let contract = Contracts.prodAppleHealth
    
	init?() {
		guard let config = try? Configuration(appId: contract.appId, contractId: contract.identifier, privateKey: contract.privateKey) else {
			return nil
		}
		
		viewModel = AppleHealthChartViewModel(config: config)
	}
	
    var body: some View {
        ScrollView {
            if !viewModel.result.isEmpty {
                SectionView(header: "Steps & Calories") {
                    VStack(alignment: .leading) {
                        ChartTimeRangePicker(value: $timeRange)
                            .padding(.bottom)
                        
                        Text("Fitness Activity Summary")
                            .font(.title2.bold())
                        
                        switch timeRange {
                        case .last30Days:
                            LineChartView(timeRange: $timeRange, data: $viewModel.data30InSeries)
                                .frame(height: 240)
                        case .allTime:
                            LineChartView(timeRange: $timeRange, data: $viewModel.dataMonthsInSeries)
                                .frame(height: 240)
                        }
                    }
                    .padding()
                }
            }
            
            SectionView(footer: viewModel.result.isEmpty ? "Press this button to download you Apple Health data." : nil) {
                StyledPressableButtonView(text: "Read Apple Health Data",
                                          iconSystemName: "heart.circle",
                                          iconForegroundColor: viewModel.isLoadingData ? .gray : .red,
                                          textForegroundColor: viewModel.isLoadingData ? .gray : .accentColor,
                                          backgroundColor: Color(.secondarySystemGroupedBackground)) {
                    queryData()
                }
                .disabled(viewModel.isLoadingData)
            }
            
            if let error = viewModel.errorMessage {
                SectionView(header: "Error") {
                    InfoMessageView(message: error, foregroundColor: .red)
                }
            }
        }
        .navigationBarTitle("Activity", displayMode: .inline)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            if viewModel.isLoadingData {
                ActivityIndicator()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            }
        }
    }
	
	private func queryData() {
		viewModel.fetchData(readOptions: nil)
	}
}

struct AppleHealthLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppleHealthLineChartView()
            // .environment(\.colorScheme, .dark)
        }
    }
}
