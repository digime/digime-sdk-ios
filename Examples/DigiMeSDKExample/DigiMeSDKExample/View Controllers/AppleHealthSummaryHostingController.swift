//
//  AppleHealthSummaryHostingController.swift
//  DigiMeSDKExample
//
//  Created on 25/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI
import UIKit

class AppleHealthSummaryHostingController: UIHostingController<AppleHealthSummaryView> {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder, rootView: AppleHealthSummaryView())
	}
}
