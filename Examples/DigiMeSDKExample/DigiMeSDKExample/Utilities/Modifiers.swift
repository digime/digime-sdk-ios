//
//  Modifiers.swift
//  DigiMeSDKExample
//
//  Created on 17/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation
import SwiftUI

extension Image {
	func listRowIcon(color: Color? = nil) -> some View {
		self
			.resizable()
			.aspectRatio(contentMode: .fit)
			.foregroundColor(color != nil ? color : .clear)
			.frame(width: 20, height: 20, alignment: .center)
	}
}
