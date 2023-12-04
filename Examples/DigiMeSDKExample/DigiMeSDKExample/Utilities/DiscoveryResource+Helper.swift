//
//  DiscoveryResource+Helper.swift
//  DigiMeSDKExample
//
//  Created on 29/11/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation
import DigiMeCore
import UIKit

func optimalResource(for givenSize: CGSize, from resources: [DiscoveryResource]) -> DiscoveryResource? {
    let retinaMultiplier = UIScreen.main.scale
    let adjustedSize = CGSize(width: givenSize.width * retinaMultiplier, height: givenSize.height * retinaMultiplier)
    
    return resources.reduce(nil) { cumulative, resource -> DiscoveryResource? in
        guard
            let resourceHeight = resource.height,
            let resourceWidth = resource.width else {
            return cumulative
        }
        
        guard
            let cumulativeHeight = cumulative?.height,
            let cumulativeWidth = cumulative?.width else {
            return resource
        }
        
        // Dimentional difference to requested size
        let dWidthRes = abs(adjustedSize.width - resourceWidth)
        let dHeightRes = abs(adjustedSize.height - resourceHeight)
        let dWidthCum = abs(adjustedSize.width - cumulativeWidth)
        let dHeightCum = abs(adjustedSize.height - cumulativeHeight)
        
        // Size difference to given original, based on closest matching width or height
        let dResSize = Swift.min(dWidthRes, dHeightRes)
        let dCumSize = Swift.min(dWidthCum, dHeightCum)
        
        //if current resource size is further away from given size then cumulative
        if dResSize >= dCumSize {
            return cumulative
        }
        else {
            return resource
        }
    }
}

