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
	@Binding var startDate: Date?
	@Binding var endDate: Date?
	
	@State private var showStartDatePicker = false
	@State private var showEndDatePicker = false
	
	var dateFormatter: DateFormatter = {
		var formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter
	}()
	
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
									Text(dateFormatter.string(from: date))
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
						.foregroundColor(.black)
						Button {
							self.showEndDatePicker.toggle()
						} label: {
							HStack {
								Image(systemName: "calendar.badge.clock")
								Text("End")
								Spacer()
								if let date = endDate {
									Text(dateFormatter.string(from: date))
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
						.foregroundColor(.black)
					}
				}
				.listStyle(InsetGroupedListStyle())
				.navigationBarTitle("Scope", displayMode: .inline)
				.navigationBarItems(leading: resetButton, trailing: doneButton)
			}
			.navigationViewStyle(StackNavigationViewStyle())
			
			if showStartDatePicker {
				withAnimation(.easeOut) {
					DatePickerWithButtons(showDatePicker: $showStartDatePicker, date: $startDate.toUnwrapped(defaultValue: Date()))
						.transition(.opacity)
				}
			}
			
			if showEndDatePicker {
				withAnimation(.easeOut) {
					DatePickerWithButtons(showDatePicker: $showEndDatePicker, date: $endDate.toUnwrapped(defaultValue: Date()))
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
	
    static var previews: some View {
		ScopeView(showModal: .constant(true), startDate: $date, endDate: $date)
    }
}
