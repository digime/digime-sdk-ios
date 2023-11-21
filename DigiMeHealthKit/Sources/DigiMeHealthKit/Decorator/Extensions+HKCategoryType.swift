//
//  Extensions+HKCategoryType.swift
//  DigiMeSDK
//
//  Created on 27.01.21.
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
