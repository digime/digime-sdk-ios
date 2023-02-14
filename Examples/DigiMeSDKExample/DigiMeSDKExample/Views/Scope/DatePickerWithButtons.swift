//
//  DatePickerWithButtons.swift
//  DigiMeSDKExample
//
//  Created on 24/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct DatePickerWithButtons: View {
	@Binding var showDatePicker: Bool
	@Binding var showTime: Bool
	@Binding var date: Date
	
	var body: some View {
		ZStack {
			VStack {
				let components: DatePickerComponents = showTime ? [.date, .hourAndMinute] : [.date]
				let picker = DatePicker("Pick Date", selection: $date, displayedComponents: components)
				
				if #available(iOS 14.0, *) {
					picker.datePickerStyle(GraphicalDatePickerStyle())
				}
				else {
					picker.datePickerStyle(WheelDatePickerStyle())
				}

				Divider()
				HStack {
					Button {
						showDatePicker = false
					} label: {
						Text("Cancel")
					}
					Spacer()
					Button {
						showDatePicker = false
					} label: {
						Text("Save".uppercased())
							.bold()
					}
				}
				.padding(.horizontal)
				.padding(.bottom, 20)
			}
			.padding(.horizontal)
			.foregroundColor(.primary)
			.background(
				Color(UIColor.tertiarySystemBackground)
					.cornerRadius(30)
			)
			.padding(.horizontal, 20)
			.cornerRadius(30)
		}
	}
}

struct DatePickerWithButtons_Previews: PreviewProvider {
	@State static var date = Date()
	static var previews: some View {
		Group {
			DatePickerWithButtons(showDatePicker: .constant(true), showTime: .constant(true), date: $date)
				.preferredColorScheme(.light)
			DatePickerWithButtons(showDatePicker: .constant(true), showTime: .constant(true), date: $date)
				.preferredColorScheme(.dark)
		}
	}
}
