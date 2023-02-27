//
//  Section.swift
//  DigiMeSDKExample
//
//  Created on 26/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation

struct ServiceSection: Identifiable {
	let id = UUID()
	let serviceGroupId: Int
	let title: String
	let items: [Service]
	
	var iconName: String {
		switch serviceGroupId {
		case 1:
			return "socialIcon"
		case 2:
			return "healthIcon"
		case 3:
			return "financeIcon"
		case 4:
			return "healthIcon"
		case 5:
			return "entertainmentIcon"
			
		default:
			return ""
		}
	}
}
