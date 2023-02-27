//
//  ChartStatementView.swift
//  DigiMeSDKExample
//
//  Created on 22/06/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import SwiftUI

struct ChartStatementView: View {
	@Binding var showModal: Bool
	var data: [FitnessActivitySummary]
	
	private var formatter: DateFormatter {
		let fm = DateFormatter()
		fm.dateStyle = .full
		fm.timeStyle = .none
		return fm
	}
	
	var body: some View {
		NavigationStack {
			List(data) { activity in
				let start = formatter.string(from: activity.startDate)
				let steps = String(format: "%.f", activity.steps)
				let distance = DistanceFormatter.stringFormatForDistance(km: activity.distances.first?.distance ?? 0)
				let calories = CaloriesFormatter.stringForCaloriesValue(activity.calories)
				
				VStack(alignment: .leading, spacing: 4) {
					Text(start)
						.font(.callout)
						.padding(.bottom, 5)
					Row(iconName: "figure.walk", title: "steps", titleFont: .caption, titleColor: .secondary, value: steps, valueFont: .caption, valueColor: .secondary)
					Row(iconName: "figure.walk.motion", title: "walking & running distance", titleFont: .caption, titleColor: .secondary, value: distance, valueFont: .caption, valueColor: .secondary)
					Row(iconName: "bolt.ring.closed", title: "active energy burned", titleFont: .caption, titleColor: .secondary, value: calories, valueFont: .caption, valueColor: .secondary)
				}
			}
			.navigationBarTitle("Statement", displayMode: .inline)
			.toolbar {
				Button("Close") {
					showModal.toggle()
				}
			}
		}
	}
	
	private struct Row: View {
		var iconName: String
		var title: String
		var titleFont: Font
		var titleColor: Color
		var value: String
		var valueFont: Font
		var valueColor: Color
		
		var body: some View {
			HStack {
				Image(systemName: iconName)
					.foregroundColor(.gray)
					.font(.caption2)
					.frame(width: 10, height: 10, alignment: .center)
				Text(title).font(titleFont)
					.foregroundColor(titleColor)
				Text(value).font(valueFont)
					.foregroundColor(valueColor)
			}
		}
	}
}

struct ChartStatementView_Previews: PreviewProvider {
	static var endDate = Date()
	static var startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)!
	static var distance = FitnessActivitySummary.Distances(activity: "activity", distance: 888.0)
	static var data = [FitnessActivitySummary(identifier: "id", entityId: "entityId", accountEntityId: "accountId", steps: 100.0, distances: [distance], calories: 1000, activity: 500, createdDate: startDate, startDate: startDate, endDate: endDate)]
	
    static var previews: some View {
		ChartStatementView(showModal: .constant(true), data: data)
    }
}
