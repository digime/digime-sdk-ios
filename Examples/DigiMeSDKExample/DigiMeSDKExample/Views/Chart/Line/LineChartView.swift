//
//  LineChartView.swift
//  DigiMeSDKExample
//
//  Created on 17/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Charts

import SwiftUI

struct LineChartView: View {
	@Binding var timeRange: ChartTimeRange
	@Binding var data: [ChartSeries]
	
	var body: some View {
		Chart {
			ForEach(data) { series in
				ForEach(series.data, id: \.date) { element in
					LineMark(
						x: .value("date", element.date, unit: .day),
						y: .value("value", element.value)
					)
				}
				.foregroundStyle(by: .value("name", series.name))
				.symbol(by: .value("name", series.name))
			}
			.interpolationMethod(.catmullRom)
			.lineStyle(StrokeStyle(lineWidth: 2))
		}
		.chartForegroundStyleScale([
			"Steps": .purple,
			"Calories": .green,
		])
		.chartSymbolScale([
			"Steps": Circle().strokeBorder(lineWidth: 2),
			"Calories": Square().strokeBorder(lineWidth: 2),
		])
		.chartXAxis {
			if timeRange == .last30Days {
				AxisMarks(values: .stride(by: .day)) { _ in
					AxisTick()
					AxisGridLine()
					AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
				}
			}
			else {
				AxisMarks(values: .stride(by: .month)) { _ in
					AxisTick()
					AxisGridLine()
					AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true)
				}
			}
		}
		.chartLegend(position: .top)
		.chartYAxis(.hidden)
		.chartYScale(range: .plotDimension(endPadding: 8))
	}
}

struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
		LineChartView(timeRange: .constant(.last30Days), data: .constant([]))
    }
}
