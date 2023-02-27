//
//  AppleHealthBarChartView.swift
//  DigiMeSDKExample
//
//  Created on 02/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Charts
import DigiMeSDK
import SwiftUI

struct AppleHealthBarChartView: View {
	@ObservedObject var viewModel: AppleHealthChartViewModel
	@State private var timeRange: ChartTimeRange = .last30Days
	@State private var showAverageLine = false
	@State private var readOptions: ReadOptions?
	@State private var showModal = false
	
	private let contract = Contracts.appleHealth
	
	init?() {
		guard let config = try? Configuration(appId: AppInfo.appId, contractId: contract.identifier, privateKey: contract.privateKey, authUsingExternalBrowser: true) else {
			return nil
		}
		
		viewModel = AppleHealthChartViewModel(config: config)
	}
	
	var body: some View {
		List {
			if !viewModel.result.isEmpty {
				VStack(alignment: .leading) {
					ChartTimeRangePicker(value: $timeRange)
						.background(.clear)
						.padding(.bottom)
					switch timeRange {
					case .last30Days:
						if !$viewModel.result30days.isEmpty {
							getBarTitleView(data: viewModel.result30days, dataType: .stepCount, title: "Steps", unit: "steps")
							DailyActivityChart(data: $viewModel.result30days, showAverageLine: $showAverageLine, dataAverage: .constant(dataAverage(dataType: .stepCount)), dataType: .stepCount, barColor: .blue)
								.frame(height: 240)
							
							getBarTitleView(data: viewModel.result30days, dataType: .stepCount, title: "Distance Walking or Runnin", unit: "km")
							DailyActivityChart(data: $viewModel.result30days, showAverageLine: $showAverageLine, dataAverage: .constant(dataAverage(dataType: .distanceWalkingRunning)), dataType: .distanceWalkingRunning, barColor: .indigo)
								.frame(height: 240)
							
							getBarTitleView(data: viewModel.result30days, dataType: .activeEnergyBurned, title: "Active Energy Burned", unit: "cal")
							DailyActivityChart(data: $viewModel.result30days, showAverageLine: $showAverageLine, dataAverage: .constant(dataAverage(dataType: .activeEnergyBurned)), dataType: .activeEnergyBurned, barColor: .teal)
								.frame(height: 240)
						}
					case .allTime:
						getBarTitleView(data: viewModel.result, dataType: .stepCount, title: "Steps", unit: "steps")
						MonthlyActivityChart(data: $viewModel.result, dataType: .stepCount, barColor: .blue)
							.frame(height: 240)
						
						getBarTitleView(data: viewModel.result, dataType: .distanceWalkingRunning, title: "Distance Walking or Running", unit: "km")
						MonthlyActivityChart(data: $viewModel.result, dataType: .distanceWalkingRunning, barColor: .indigo)
							.frame(height: 240)
						
						getBarTitleView(data: viewModel.result, dataType: .activeEnergyBurned, title: "Active Energy Burned", unit: "cal")
						MonthlyActivityChart(data: $viewModel.result, dataType: .activeEnergyBurned, barColor: .teal)
							.frame(height: 240)
					}
				}
				
				if timeRange == .last30Days {
					Section("Options") {
						Toggle("Show Daily Average", isOn: $showAverageLine)
					}
					.background(.clear)
				}
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
				.listRowSeparator(.hidden)
				.buttonStyle(PlainButtonStyle())
				.background(.clear)
			}
			.background(.clear)
			
			if viewModel.result.isEmpty {
				Section {
					VStack(alignment: .center) {
						Text("Press this button to download you Apple Health data.")
							.background(.clear)
							.frame(maxWidth: .infinity, alignment: .center)
							.font(.caption)
							.foregroundColor(.secondary)
						Image(systemName: "chart.bar.xaxis")
							.background(.clear)
							.foregroundColor(.secondary).opacity(0.1)
							.font(.largeTitle)
							.padding(.top, 30)
							.scaleEffect(3)
					}
					.listRowSeparator(.hidden)
					.background(.clear)
				}
				.background(.clear)
			}
			
			if viewModel.errorMessage != nil {
				Section {
					errorBanner
				}
				.background(.clear)
			}
		}
		.listStyle(.plain).background(.clear)
		.navigationBarTitle("Activity", displayMode: .inline)
		.toolbar {
			if !viewModel.result.isEmpty {
				Button {
					showModal.toggle()
				} label: {
					Image(systemName: "list.bullet.rectangle.portrait").imageScale(.large)
				}
				.background(.clear)
			}
		}
		.sheet(isPresented: $showModal) {
			let data = timeRange == .allTime ? viewModel.result : viewModel.result30days
			ChartStatementView(showModal: $showModal, data: data)
		}
	}
	
	// MARK: - views
	private var errorBanner: some View {
		VStack(alignment: .leading, spacing: 2) {
			Text("Error")
				.font(.headline)
				.background(.clear)
			Text(viewModel.errorMessage ?? "Error...")
				.font(.callout)
				.background(.clear)
		}
		.foregroundColor(.red)
		.background(.clear)
	}
	
	private func getBarTitleView(data: [FitnessActivitySummary], dataType: QuantityType, title: String, unit: String) -> some View {
		VStack(alignment: .leading) {
			Text("Total \(title)")
				.background(.clear)
				.font(.callout)
				.foregroundStyle(.secondary)
			Text("\(getTotal(data: data, dataType: dataType), format: .number) \(unit)")
				.background(.clear)
				.font(.title2.bold())
				.foregroundColor(.primary)
		}
		.background(.clear)
		.padding(.top, 20)
	}
	
	// MARK: - Data wrappers
	private func getTotal(data: [FitnessActivitySummary], dataType: QuantityType) -> Int {
		data.map { activity in
			switch dataType {
			case .stepCount:
				return Int(activity.steps)
			case .distanceWalkingRunning:
				return Int(activity.distances.first?.distance ?? 0)
			case .activeEnergyBurned:
				return Int(activity.calories)
			default:
				return 0
			}
		}.reduce(0, +)
	}

	private func dataAverage(dataType: QuantityType) -> Double {
		guard !viewModel.result30days.isEmpty else {
			return 0.0
		}

		let total = viewModel.result30days.map { activity in
			switch dataType {
			case .stepCount:
				return Int(activity.steps)
			case .distanceWalkingRunning:
				return Int(activity.distances.first?.distance ?? 0)
			case .activeEnergyBurned:
				return Int(activity.calories)
			default:
				return 0
			}
		}.reduce(0, +)
		return Double(total / viewModel.result30days.count)
	}
		
	// MARK: - Actions
	private func queryData() {
		viewModel.isLoading = true
		viewModel.fetchData(readOptions: readOptions)
	}
}

struct AppleHealthChartView_Previews: PreviewProvider {
	static var previews: some View {
		AppleHealthBarChartView()
	}
}
