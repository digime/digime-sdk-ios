//
//  MonthlyActivityChart.swift
//  DigiMeSDKExample
//
//  Created on 05/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Charts
import DigiMeCore
import DigiMeHealthKit
import DigiMeSDK
import SwiftUI

struct MonthlyActivityChart: View {
	@Binding var data: [FitnessActivitySummary]
	var dataType: QuantityType
	var barColor: Color
	
	var body: some View {
		Chart(data, id: \.id) { activity in
			let yValue: Double = {
				switch dataType {
				case .stepCount:
					return activity.steps
				case .distanceWalkingRunning:
					return activity.distances.first?.distance ?? 0.0
				case .activeEnergyBurned:
					return activity.calories
				default:
					return 0.0
				}
			}()
			
			BarMark(
				x: .value("Month", activity.startDate, unit: .month),
				y: .value("Value", yValue)
			)
		}
		.chartXAxis {
			AxisMarks(values: .stride(by: .month)) { _ in
				AxisGridLine()
				AxisTick()
				AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true)
			}
		}
		.foregroundColor(barColor)
		.background(.clear)
	}
}

#Preview {
    MonthlyActivityChart(data: .constant(TestDailyActivity.allTime), dataType: QuantityType.stepCount, barColor: .accentColor)
}
