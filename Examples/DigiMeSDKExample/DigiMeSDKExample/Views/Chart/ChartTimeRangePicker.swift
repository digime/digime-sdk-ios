//
//  ChartTimeRangePicker.swift
//  DigiMeSDKExample
//
//  Created on 03/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

enum ChartTimeRange {
	case last30Days
	case allTime
}

struct ChartTimeRangePicker: View {
	@Binding var value: ChartTimeRange

	var body: some View {
		Picker("Time Range", selection: $value.animation(.easeInOut)) {
			Text("30 Days").tag(ChartTimeRange.last30Days)
			Text("All Data").tag(ChartTimeRange.allTime)
		}
		.pickerStyle(.segmented)
	}
}
