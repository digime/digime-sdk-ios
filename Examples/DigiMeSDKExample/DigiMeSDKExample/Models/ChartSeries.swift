//
//  ChartSeries.swift
//  DigiMeSDKExample
//
//  Created on 26/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

struct ChartSeries: Identifiable {
	let name: String
	let data: [(date: Date, value: Double)]
	var id: String { name }
}
