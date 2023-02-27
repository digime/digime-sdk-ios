//
//  DailyActivityChart.swift
//  DigiMeSDKExample
//
//  Created on 05/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Charts
import DigiMeSDK
import SwiftUI

struct DailyActivityChart: View {
	@Binding var data: [FitnessActivitySummary]
	@Binding var showAverageLine: Bool
	@Binding var dataAverage: Double
	
	var dataType: QuantityType
	var barColor: Color

	var body: some View {
		Chart {
			ForEach(data, id: \.id) { activity in
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
					x: .value("Day", activity.startDate, unit: .day),
					y: .value("Steps", yValue)
				)
			}
			.foregroundStyle(showAverageLine ? .gray.opacity(0.3) : barColor)
			
			if showAverageLine {
				RuleMark(
					y: .value("Average", dataAverage)
				)
				.lineStyle(StrokeStyle(lineWidth: 3))
				.annotation(position: .top, alignment: .leading) {
					Text("Average: \(dataAverage, format: .number)")
						.font(.body.bold())
				}
			}
		}
		.foregroundColor(barColor)
	}
}

struct DailyStepsChart_Previews: PreviewProvider {
	@State static var data = TestDailyActivity.last30Days
	static var dataType = QuantityType.stepCount
	
    static var previews: some View {
		DailyActivityChart(data: $data, showAverageLine: .constant(false), dataAverage: .constant(0), dataType: dataType, barColor: .blue)
    }
}
