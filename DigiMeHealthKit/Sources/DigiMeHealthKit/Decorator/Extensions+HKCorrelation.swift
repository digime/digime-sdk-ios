//
//  Extensions+HKCorrelation.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

extension HKCorrelation: Harmonizable {
    typealias Harmonized = Correlation.Harmonized

    func harmonize() throws -> Harmonized {
        var quantityArray = [Quantity]()
        
		if let quantitySamples = objects as? Set<HKQuantitySample> {
            for element in quantitySamples {
                let quantity = try Quantity(quantitySample: element)
                quantityArray.append(quantity)
            }
        }
		
        var categoryArray = [Category]()
        if let categorySamples = objects as? Set<HKCategorySample> {
            for element in categorySamples {
                let category = try Category(categorySample: element)
                categoryArray.append(category)
            }
        }
		
        return Harmonized(quantitySamples: quantityArray,
						  categorySamples: categoryArray,
						  metadata: metadata?.asMetadata)
    }
}
