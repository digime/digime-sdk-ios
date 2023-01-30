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
	@ObservedObject var viewModel = AppleHealthSummaryViewModel()
	@State private var allowScoping = false
	@State private var showModal = false
	@State private var scopeStartDate: Date?
	@State private var scopeEndDate: Date?
	@State private var readOptions: ReadOptions?
	
	static let datePlaceholder = "__ . __ . ____"
	private let contract = Contracts.appleHealth
	private var scopeStartDateString: String {
		scopeStartDate == nil ? AppleHealthSummaryView.datePlaceholder : formatter.string(from: scopeStartDate!)
	}
	private var scopeEndDateString: String {
		scopeEndDate == nil ? AppleHealthSummaryView.datePlaceholder : formatter.string(from: scopeEndDate!)
	}
	private var fromDate: Date {
		return Calendar.current.date(byAdding: .month, value: -1, to: Date())!
	}
	private var formatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter
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
						Text("Scope")
						Spacer()
						Toggle("", isOn: $allowScoping)
							.onChange(of: allowScoping) { value in
								self.showModal = value
							}
					}
					if allowScoping {
						Button {
							self.showModal = true
						} label: {
							HStack(spacing: 40) {
								VStack(alignment: .leading, spacing: 10) {
									Text( "Scope time range:")
										.foregroundColor(.black)
										.font(.footnote)
									
									Text("\(scopeStartDateString) - \(scopeEndDateString)")
										.foregroundColor(.gray)
										.font(.footnote)
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
								ProgressView()
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
			}
			.navigationBarTitle("Apple Health", displayMode: .inline)
			.listStyle(InsetGroupedListStyle())
			.sheet(isPresented: $showModal) {
				ScopeView(showModal: self.$showModal, startDate: $scopeStartDate, endDate: $scopeEndDate)
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
	
	private func queryData() {
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
}

struct AppleHealthSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        AppleHealthSummaryView()
    }
}
