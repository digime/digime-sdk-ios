//
//  Extensions+HKCategoryValuePresence.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

@available(iOS 13.6, *)
extension HKCategoryValuePresence {
    public var description: String {
        String(describing: self)
    }
	
    public var detail: String {
        switch self {
        case .present:
            return "Present"
        case .notPresent:
            return "Not Present"
        @unknown default:
            return "Unknown"
        }
    }
}
