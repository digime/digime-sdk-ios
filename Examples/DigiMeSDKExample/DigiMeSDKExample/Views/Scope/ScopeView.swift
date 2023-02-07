//
//  ScopeView.swift
//  DigiMeSDKExample
//
//  Created on 23/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct ScopeView: View {
	@Binding var showModal: Bool
	@Binding var showTime: Bool
	@Binding var startDate: Date?
	@Binding var endDate: Date?
	@Binding var formatter: DateFormatter
	
	@State private var showStartDatePicker = false
	@State private var showEndDatePicker = false
	
	var body: some View {
		ZStack {
			NavigationView {
				List {
					Section(header: Text("Date Range")) {
						Button {
							self.showStartDatePicker.toggle()
						} label: {
							HStack {
								Image(systemName: "calendar.badge.clock")
									.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
								Text("Start")
								Spacer()
								if let date = startDate {
									Text(formatter.string(from: date))
										.foregroundColor(.gray)
								}
								else {
									Text("__ . __ . ____")
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
								Text("End")
								Spacer()
								if let date = endDate {
									Text(formatter.string(from: date))
										.foregroundColor(.gray)
								}
								else {
									Text("__ . __ . ____")
										.foregroundColor(.gray)
								}
								Image(systemName: "chevron.right")
									.foregroundColor(.gray)
							}
						}
						.foregroundColor(.primary)
					}
				}
				.listStyle(InsetGroupedListStyle())
				.navigationBarTitle("Scope", displayMode: .inline)
				.navigationBarItems(leading: resetButton, trailing: doneButton)
			}
			.navigationViewStyle(StackNavigationViewStyle())
			
			if showStartDatePicker {
				withAnimation(.easeOut) {
					DatePickerWithButtons(showDatePicker: $showStartDatePicker, showTime: $showTime, date: $startDate.toUnwrapped(defaultValue: Date()))
						.transition(.opacity)
				}
			}
			
			if showEndDatePicker {
				withAnimation(.easeOut) {
					DatePickerWithButtons(showDatePicker: $showEndDatePicker, showTime: $showTime, date: $endDate.toUnwrapped(defaultValue: Date()))
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
		} label: {
			Text("Reset")
		}
	}
	
	private func done() {
		self.showModal = false
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
		ScopeView(showModal: .constant(true), showTime: .constant(true), startDate: $date, endDate: $date, formatter: $formatter)
    }
}
