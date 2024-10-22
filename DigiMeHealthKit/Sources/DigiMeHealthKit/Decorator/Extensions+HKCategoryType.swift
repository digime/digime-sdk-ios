//
//  Extensions+HKCategoryType.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeCore
import HealthKit

extension HKCategoryType {
    func parsed() throws -> CategoryType {
        for type in CategoryType.allCases {
            if type.identifier == identifier {
                return type
            }
        }
		
        throw SDKError.invalidType(
			message: "Unknown HKCategoryType with identifier:\(identifier)"
        )
    }
}
