//
//  Binding+Helper.swift
//  DigiMeSDKExample
//
//  Created on 26/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

extension Binding {
	func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == T? {
		Binding<T>(
			get: { self.wrappedValue ?? defaultValue },
			set: { self.wrappedValue = $0 }
		)
	}
}
