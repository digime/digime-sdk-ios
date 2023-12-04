//
//  Square.swift
//  DigiMeSDKExample
//
//  Created on 06/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Charts
import Foundation
import SwiftUI

/// A square symbol for charts.
struct Square: ChartSymbolShape, InsettableShape {
	let inset: CGFloat

	init(inset: CGFloat = 0) {
		self.inset = inset
	}

	func path(in rect: CGRect) -> Path {
		let cornerRadius: CGFloat = 1
		let minDimension = min(rect.width, rect.height)
		return Path(
			roundedRect: .init(x: rect.midX - minDimension / 2, y: rect.midY - minDimension / 2, width: minDimension, height: minDimension),
			cornerRadius: cornerRadius
		)
	}

	func inset(by amount: CGFloat) -> Square {
		Square(inset: inset + amount)
	}

	var perceptualUnitRect: CGRect {
		// The width of the unit rectangle (square). Adjust this to
		// size the diamond symbol so it perceptually matches with
		// the circle.
		let scaleAdjustment: CGFloat = 0.75
		return CGRect(x: 0.5 - scaleAdjustment / 2, y: 0.5 - scaleAdjustment / 2, width: scaleAdjustment, height: scaleAdjustment)
	}
}
