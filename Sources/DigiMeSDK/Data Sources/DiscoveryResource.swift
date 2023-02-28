//
//  DiscoveryResource.swift
//  DigiMeSDK
//
//  Created on 24/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
public class DiscoveryResource: Codable {

	public var mimeType: String
	public var resizeStrategy: String
	public var type: Int
	public var url: URL
	public var height: CGFloat?
	public var width: CGFloat?
	
	enum CodingKeys: String, CodingKey {
		case mimeType = "mimetype"
		case resizeStrategy = "resize"
		case type
		case url
		case height
		case width
	}
	
	public var aspectRatio: CGFloat {
		guard
			let height = height,
			height > 0,
			let width = width else {
				return 1
		}
		
		return width / height
	}
}

extension Array where Element == DiscoveryResource {
	public func svgResource() -> DiscoveryResource? {
		return self.filter { $0.mimeType == "image/svg+xml" }.first
	}
	
	public func optimalResource(for givenSize: CGSize) -> DiscoveryResource? {
		let retinaMultiplier = UIScreen.main.scale
		let adjustedSize = CGSize(width: givenSize.width * retinaMultiplier, height: givenSize.height * retinaMultiplier)
		
		return self.reduce(nil) { cumulative, resource -> DiscoveryResource? in
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
}
