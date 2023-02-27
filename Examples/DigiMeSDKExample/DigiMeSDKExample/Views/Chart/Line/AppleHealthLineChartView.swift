//
//  AppleHealthLineChartView.swift
//  DigiMeSDKExample
//
//  Created on 02/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Charts
import DigiMeSDK
import SwiftUI

struct AppleHealthLineChartView: View {
	@ObservedObject var viewModel: AppleHealthChartViewModel
    @State private var timeRange: ChartTimeRange = .last30Days

	init?() {
		guard let config = try? Configuration(appId: AppInfo.appId, contractId: Contracts.appleHealth.identifier, privateKey: Contracts.appleHealth.privateKey) else {
			return nil
		}
		
		viewModel = AppleHealthChartViewModel(config: config)
	}
	
    var body: some View {
		
        List {
			if !viewModel.result.isEmpty {
				VStack(alignment: .leading) {
					ChartTimeRangePicker(value: $timeRange)
						.padding(.bottom)
					
					Text("Steps & Calories")
						.font(.callout)
						.foregroundStyle(.secondary)
					
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
				.listRowSeparator(.hidden)
			}
			
			Section {
				Button {
					queryData()
				} label: {
					HStack(alignment: .center, spacing: 20) {
						Text("Request New Data")
						if viewModel.isLoading {
							ActivityIndicator()
								.frame(width: 20, height: 20)
								.foregroundColor(.white)
						}
					}
					.listRowSeparator(.hidden)
					.frame(minWidth: 0, maxWidth: .infinity)
					.font(.headline).foregroundColor(.white)
					.padding(10)
					.background(
						RoundedRectangle(cornerRadius: 10, style: .continuous)
							.fill(.blue)
					)
				}
				.padding(.top, 20)
				.buttonStyle(PlainButtonStyle())
				.listRowSeparator(.hidden)
			}
			
			if viewModel.result.isEmpty {
				VStack(alignment: .center) {
					Text("Press this button to download you Apple Health data.")
						.frame(maxWidth: .infinity, alignment: .center)
						.font(.caption)
						.foregroundColor(.secondary)
					Image(systemName: "chart.xyaxis.line")
						.foregroundColor(.secondary).opacity(0.1)
						.font(.largeTitle)
						.padding(.top, 30)
						.scaleEffect(3)
				}
				.listRowSeparator(.hidden)
			}
			
			if viewModel.errorMessage != nil {
				Section {
					errorBanner
				}
			}
        }
        .listStyle(.plain)
        .navigationBarTitle("Activity", displayMode: .inline)
    }
	
	private var errorBanner: some View {
		VStack(alignment: .leading, spacing: 2) {
			Text("Error")
				.font(.headline)
			Text(viewModel.errorMessage ?? "Error...")
				.font(.callout)
		}
		.foregroundColor(Color.red)
	}
	
	private func queryData() {
		viewModel.isLoading = true
		viewModel.fetchData(readOptions: nil)
	}
}

struct AppleHealthLineChartView_Previews: PreviewProvider {
    static var previews: some View {
		AppleHealthLineChartView()
    }
}
