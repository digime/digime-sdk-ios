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

    @State private var tempDate: Date
    private var minDate: Date?
    private var maxDate: Date?

    init(showDatePicker: Binding<Bool>, showTime: Binding<Bool>, date: Binding<Date>, minDate: Date? = nil, maxDate: Date? = nil) {
        self._showDatePicker = showDatePicker
        self._showTime = showTime
        self._date = date
        self.minDate = minDate
        self.maxDate = maxDate
        self._tempDate = State(initialValue: date.wrappedValue)
    }

	var body: some View {
		ZStack {
            VStack(alignment: .center) {
                picker
                    .datePickerStyle(.graphical)
                    .frame(width: 330)

				Divider()

                HStack(alignment: .top) {
					Button {
                        withAnimation {
                            showDatePicker = false
                        }
					} label: {
						Text("Cancel")
                            .foregroundColor(.accentColor)
					}

					Spacer()

					Button {
                        date = tempDate
                        withAnimation {
                            showDatePicker = false
                        }
					} label: {
						Text("Save".uppercased())
							.bold()
                            .foregroundColor(.accentColor)
					}
				}
                .padding(20)
			}
			.background(
				Color(UIColor.tertiarySystemBackground)
					.cornerRadius(30)
			)
		}
        .frame(maxWidth: 380, maxHeight: .infinity, alignment: .center)
        .onAppear {
            tempDate = date
        }
	}

    private var picker: some View {
        let components: DatePickerComponents = showTime ? [.date, .hourAndMinute] : [.date]
        return Group {
            if let minDate = minDate, let maxDate = maxDate {
                DatePicker("Pick Date", selection: $tempDate, in: minDate...maxDate, displayedComponents: components)
            } 
            else if let minDate = minDate {
                DatePicker("Pick Date", selection: $tempDate, in: minDate..., displayedComponents: components)
            } 
            else if let maxDate = maxDate {
                DatePicker("Pick Date", selection: $tempDate, in: ...maxDate, displayedComponents: components)
            } 
            else {
                DatePicker("Pick Date", selection: $tempDate, displayedComponents: components)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.4)
            .edgesIgnoringSafeArea(.all)

        DatePickerWithButtons(showDatePicker: .constant(true), showTime: .constant(true), date: .constant(Date()))
//            .preferredColorScheme(.dark)
    }
}
