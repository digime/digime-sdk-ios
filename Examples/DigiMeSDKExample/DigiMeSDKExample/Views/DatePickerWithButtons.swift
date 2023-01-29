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
	@Binding var date: Date
	
	var body: some View {
		ZStack {
			Color.black.opacity(0.3)
				.edgesIgnoringSafeArea(.all)
			VStack {
				let picker = DatePicker("Test", selection: $date, displayedComponents: [.date, .hourAndMinute])
				
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
			.background(
				Color.white
					.cornerRadius(30)
			)
			.padding(.horizontal, 20)
		}
	}
}

struct DatePickerWithButtons_Previews: PreviewProvider {
	@State static var date = Date()
	static var previews: some View {
		DatePickerWithButtons(showDatePicker: .constant(true), date: $date)
	}
}
