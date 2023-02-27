//
//  ScopeView.swift
//  DigiMeSDKExample
//
//  Created on 23/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import SwiftUI

struct ScopeTemplate: Identifiable {
	var id = UUID()
	var name: String
	var scope: Scope
}

struct ScopeView: View {
	static let datePlaceholder = "__ . __ . ____"
	
	@Binding var scopeTemplates: [ScopeTemplate]
	@Binding var showModalDateSelector: Bool
	@Binding var showTimeOption: Bool
	@Binding var startDate: Date?
	@Binding var endDate: Date?
	@Binding var formatter: DateFormatter
	@Binding var selectedScopeIndex: Int
	@Binding var startDateString: String
	@Binding var endDateString: String
	
	@State private var showStartDatePicker = false
	@State private var showEndDatePicker = false
//	@State private var startDateString = ScopeView.datePlaceholder
//	@State private var endDateString = ScopeView.datePlaceholder
	private var showCustomDateOptions: Bool {
		guard !scopeTemplates.isEmpty else {
			return true
		}
		
		return selectedScopeIndex == (scopeTemplates.count - 1)
	}
	
	var body: some View {
		ZStack {
			NavigationView {
				List {
					Section(footer: Text("Please select a date range for the data query. When you select the appropriate option from the list the sample date range will be displayed.")) {
						HStack {
							Image(systemName: "book")
								.frame(width: 30, height: 30, alignment: .center)
							Text("Scope Templates")
							Spacer()
						}
						
						VStack {
							Picker(selection: $selectedScopeIndex, label: Text("")) {
								ForEach(0 ..< scopeTemplates.count, id: \.self) {
									Text(self.scopeTemplates[$0].name)
										.font(.callout)
								}
							}
							.frame(maxWidth: .infinity, maxHeight: 130, alignment: .center)
							.pickerStyle(WheelPickerStyle())
							.onAppear {
								self.updateValues()
							}
							.onChange(of: selectedScopeIndex) { _ in
								self.updateValues()
							}
							
							if !showCustomDateOptions {
								Text("Your selected scope: ")
									.font(.footnote)
									.foregroundColor(.secondary)
								
								Text("\(startDateString) - \(endDateString)")
									.font(.footnote)
									.foregroundColor(.primary)
									.padding(.top, 1)
							}
						}
						.padding()
						
						if showCustomDateOptions {
							Button {
								self.showStartDatePicker.toggle()
							} label: {
								HStack {
									Image(systemName: "calendar.badge.clock")
										.frame(width: 30, height: 30, alignment: .center)
										.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
									Text("Start")
									Spacer()
									if let date = startDate {
										Text(formatter.string(from: date))
											.foregroundColor(.gray)
									}
									else {
										Text(ScopeView.datePlaceholder)
											.foregroundColor(.gray)
									}
									Image(systemName: "chevron.right")
										.foregroundColor(.gray)
								}
							}
							.foregroundColor(.primary)
							
							Button {
								self.showEndDatePicker.toggle()
							} label: {
								HStack {
									Image(systemName: "calendar.badge.clock")
										.frame(width: 30, height: 30, alignment: .center)
									Text("End")
									Spacer()
									if let date = endDate {
										Text(formatter.string(from: date))
											.foregroundColor(.gray)
									}
									else {
										Text(ScopeView.datePlaceholder)
											.foregroundColor(.gray)
									}
									Image(systemName: "chevron.right")
										.foregroundColor(.gray)
								}
							}
							.foregroundColor(.primary)
						}
					}
				}
				.listStyle(InsetGroupedListStyle())
				.navigationBarTitle("Limit Your Query", displayMode: .inline)
				.navigationBarItems(leading: resetButton, trailing: doneButton)
			}
			.navigationViewStyle(StackNavigationViewStyle())
			
			if showStartDatePicker {
				withAnimation(.easeOut) {
					DatePickerWithButtons(showDatePicker: $showStartDatePicker, showTime: $showTimeOption, date: $startDate.toUnwrapped(defaultValue: Date()))
						.transition(.opacity)
				}
			}
			
			if showEndDatePicker {
				withAnimation(.easeOut) {
					DatePickerWithButtons(showDatePicker: $showEndDatePicker, showTime: $showTimeOption, date: $endDate.toUnwrapped(defaultValue: Date()))
						.transition(.opacity)
				}
			}
		}
	}
	
	var doneButton: some View {
		Button {
			self.done()
		} label: {
			Text("Done")
				.font(.headline)
		}
	}
	
	var resetButton: some View {
		Button {
			self.startDate = nil
			self.endDate = nil
			self.selectedScopeIndex = 0
		} label: {
			Text("Reset")
		}
	}
	
	private func updateValues() {
		if let range = scopeTemplates[selectedScopeIndex].scope.timeRanges?.first {
			switch range {
			case .after(let from):
				startDateString = formatter.string(from: from)
				endDateString = formatter.string(from: Date())
			case let .between(from, to):
				startDateString = formatter.string(from: from)
				endDateString = formatter.string(from: to)
			case .before(let to):
				startDateString = formatter.string(from: Date(timeIntervalSince1970: 0))
				endDateString = formatter.string(from: to)
			case let .last(amount, unit):
				startDateString = formatter.string(from: Calendar.current.date(byAdding: unit.calendarUnit, value: -amount, to: Date())!)
				endDateString = formatter.string(from: Date())
			}
		}
	}

	private func done() {
		if
			!showCustomDateOptions,
			let range = scopeTemplates[selectedScopeIndex].scope.timeRanges?.first {
			
			switch range {
			case .after(let from):
				startDate = from
				endDate = Date()
			case let .between(from, to):
				startDate = from
				endDate = to
			case .before(let to):
				startDate = Date(timeIntervalSince1970: 0)
				endDate = to
			case let .last(amount, unit):
				startDate = Calendar.current.date(byAdding: unit.calendarUnit, value: -amount, to: Date())
				endDate = Date()
			}
		}
		
		self.showModalDateSelector = false
	}
}

struct ScopeView_Previews: PreviewProvider {
	@State static var date: Date?
	@State static var formatter: DateFormatter = {
		let fm = DateFormatter()
		fm.dateStyle = .medium
		fm.timeStyle = .short
		return fm
	}()
	
    static var previews: some View {
		ScopeView(scopeTemplates: .constant(TestScopingTemplates.defaultScopes), showModalDateSelector: .constant(true), showTimeOption: .constant(false), startDate: $date, endDate: $date, formatter: $formatter, selectedScopeIndex: .constant(0), startDateString: .constant(ScopeView.datePlaceholder), endDateString: .constant(ScopeView.datePlaceholder))
    }
}
