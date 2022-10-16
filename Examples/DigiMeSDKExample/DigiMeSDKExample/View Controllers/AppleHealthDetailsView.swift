//
//  AppleHealthDetailsView.swift
//  DigiMeSDKExample
//
//  Created on 22/06/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import SwiftUI

struct AppleHealthDetailsView: View {
	var data: [FitnessActivitySummary]
		
	init(_ fitnessData: [FitnessActivitySummary]) {
		data = fitnessData
	}
	
	var body: some View {
		
		List(data) { activity in
			VStack(alignment: .leading, spacing: 8) {
				Text("Start: \(activity.startDate.description(with: .current))").font(.system(size: 14, weight: .medium))
				Text("End: \(activity.endDate.description(with: .current))").font(.system(size: 14, weight: .medium))
                Text("Steps: \(String(format: "%.f", activity.steps))").font(.system(size: 10))
                Text("Distance: \(DistanceFormatter.stringFormatForDistance(km: activity.distances.first?.distance ?? 0))").font(.system(size: 10))
                Text("Active energy burned: \(CaloriesFormatter.stringForCaloriesValue(activity.calories))").font(.system(size: 10))
			}
		}
	}
}

struct AppleHealthDetailsView_Previews: PreviewProvider {
    static var previews: some View {
		AppleHealthDetailsView([FitnessActivitySummary]())
    }
}
