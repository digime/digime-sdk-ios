//
//  DigiMeSDKExampleApp.swift
//  DigiMeSDKExample
//
//  Created on 26/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

@main
struct DigiMeSDKExampleApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
	
	var body: some Scene {
		WindowGroup {
			HomeView()
		}
	}
}
