//
//  Date+Helper.swift
//  DigiMeSDKExample
//
//  Created on 18/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

extension Date {
	static func date(year: Int, month: Int, day: Int = 1) -> Date {
		Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
	}
}
