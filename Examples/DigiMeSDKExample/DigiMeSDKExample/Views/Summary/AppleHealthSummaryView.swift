//
//  AppleHealthSummaryView.swift
//  DigiMeSDKExample
//
//  Created on 25/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import SwiftUI

struct AppleHealthSummaryView: View {
	@ObservedObject var viewModel: AppleHealthSummaryViewModel
	@State private var allowScoping = false
	@State private var showModal = false
	@State private var showTime = false
	@State private var selectedScopeIndex = 0
	@State private var scopeStartDateString = ScopeView.datePlaceholder
	@State private var scopeEndDateString = ScopeView.datePlaceholder
	@State private var scopeStartDate: Date?
	@State private var scopeEndDate: Date?
	@State private var readOptions: ReadOptions?
	@State private var formatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter
	}()
	
	private let scopeTemplates: [ScopeTemplate] = TestScopingTemplates.defaultScopes
	private let contract = Contracts.appleHealth
	private var fromDate: Date {
		return Calendar.current.date(byAdding: .month, value: -1, to: Date())!
	}

	init?() {
		guard let config = try? Configuration(appId: AppInfo.appId, contractId: contract.identifier, privateKey: contract.privateKey, authUsingExternalBrowser: true) else {
			return nil
		}
		
		viewModel = AppleHealthSummaryViewModel(config: config)
	}
	
	var body: some View {
		let scopeFooterText = !allowScoping ? Text("Turn on the toggle to set the scope of mapped data using time ranges and narrow down the results.") : Text("To revert to the default contract's time range, turn off the scoping option and execute the query again.")
		let footerText = !allowScoping ? Text("You can try turning the Scoping option On to narrow down your next request.") : Text("")
		ZStack {
			List {
				Section(header: Text("Scope"), footer: scopeFooterText) {
					HStack {
						Image(systemName: "scope")
							.frame(width: 30, height: 30, alignment: .center)
						Text("Limit your query")
						Spacer()
						Toggle("", isOn: $allowScoping)
							.onChange(of: allowScoping) { value in
								if !value {
									self.reset()
								}
							}
					}
					
					if allowScoping {
						Button {
							self.showModal = true
						} label: {
							HStack(spacing: 40) {
								VStack(alignment: .leading, spacing: 10) {
									Text("Your Scope time range. ")
										.foregroundColor(.primary)
										.font(.footnote) +
									Text("Tap to change:")
										.foregroundColor(.blue)
										.font(.footnote)
									
									Text("\(scopeStartDateString) - \(scopeEndDateString)")
										.foregroundColor(.gray)
										.font(.footnote)
										.onChange(of: scopeStartDate) { newValue in
											scopeStartDateString = newValue == nil ? ScopeView.datePlaceholder : formatter.string(from: newValue!)
										}
										.onChange(of: scopeEndDate) { newValue in
											scopeEndDateString = newValue == nil ? ScopeView.datePlaceholder : formatter.string(from: newValue!)
										}
								}
								.padding(.vertical, 10)
							}
						}
					}
				}
				
				Section(header: Text("Access Your Records"), footer: Text("When you query for the first time, you will be prompted for Apple Health permissions.\n\nIf you blocked or ignored the permission request, you may need to open the iOS Settings and manually allow access to approve sharing data with the SDK Example App.")) {
					Button {
						queryData()
					} label: {
						HStack {
							Text("Read Apple Health Data")
							Spacer()
							if viewModel.isLoading {
								ActivityIndicator()
									.frame(width: 20, height: 20)
									.foregroundColor(.gray)
							}
						}
					}
				}
				
				if viewModel.dataFetched && viewModel.errorMessage == nil {
					Section(header: Text("Result"), footer: footerText) {
						HStack {
							Image(systemName: "calendar.badge.clock")
								.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
								.frame(width: 30, height: 30, alignment: .center)
							Text("Start:")
							Spacer()
							Text(viewModel.startDateString)
								.foregroundColor(.gray)
						}
						HStack {
							Image(systemName: "calendar.badge.clock")
								.frame(width: 30, height: 30, alignment: .center)
							Text("End:")
							Spacer()
							Text(viewModel.endDateString)
								.foregroundColor(.gray)
						}
						HStack {
							Image(systemName: "figure.walk")
								.frame(width: 30, height: 30, alignment: .center)
							Text("Steps:")
							Spacer()
							Text(viewModel.steps)
								.foregroundColor(.gray)
						}
						HStack {
							Image(systemName: "figure.walk.motion")
								.frame(width: 30, height: 30, alignment: .center)
							Text("Distance:")
							Spacer()
							Text(viewModel.distance)
								.foregroundColor(.gray)
						}
						HStack {
							Image(systemName: "bolt.ring.closed")
								.frame(width: 30, height: 30, alignment: .center)
							Text("Energy:")
							Spacer()
							Text(viewModel.calories)
								.foregroundColor(.gray)
						}
					}
				}
				else if viewModel.errorMessage != nil {
					errorBanner
				}
				else if viewModel.infoMessage != nil {
					infoBanner
				}
			}
			.navigationBarTitle("Apple Health", displayMode: .inline)
			.listStyle(InsetGroupedListStyle())
			.toolbar {
#if targetEnvironment(simulator)
				Button {
					viewModel.addTestData()
				} label: {
					Image(systemName: "plus.square.on.square")
				}
#endif
			}
			.sheet(isPresented: $showModal) {
				ScopeView(scopeTemplates: .constant(scopeTemplates), showModalDateSelector: $showModal, showTimeOption: $showTime, startDate: $scopeStartDate, endDate: $scopeEndDate, formatter: $formatter, selectedScopeIndex: $selectedScopeIndex, startDateString: $scopeStartDateString, endDateString: $scopeEndDateString)
			}
		}
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
	
	private var infoBanner: some View {
		VStack(alignment: .leading, spacing: 2) {
			Text("Info")
				.font(.headline)
			Text(viewModel.infoMessage ?? "Info...")
				.font(.callout)
		}
	}
	
	private func queryData() {
		viewModel.errorMessage = nil
		viewModel.infoMessage = nil
		viewModel.isLoading = true
		configureReadOptions()
		viewModel.fetchData(readOptions: readOptions)
	}
	
	private func configureReadOptions() {
		guard allowScoping else {
			readOptions = nil
			return
		}
		
		var timeRange: TimeRange!
		if let start = scopeStartDate, let end = scopeEndDate {
			timeRange = TimeRange.between(from: start, to: end)
		}
		else if let start = scopeStartDate {
			timeRange = TimeRange.after(from: start)
		}
		else if let end = scopeEndDate {
			timeRange = TimeRange.before(to: end)
		}
		else {
			readOptions = nil
			return
		}
		
		let scope = Scope(timeRanges: [timeRange])
		readOptions = ReadOptions(scope: scope)
	}
	
	private func reset() {
		readOptions = nil
		scopeStartDateString = ScopeView.datePlaceholder
		scopeEndDateString = ScopeView.datePlaceholder
		selectedScopeIndex = 0
		scopeStartDate = nil
		scopeEndDate = nil
	}
}

struct AppleHealthSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        AppleHealthSummaryView()
    }
}
