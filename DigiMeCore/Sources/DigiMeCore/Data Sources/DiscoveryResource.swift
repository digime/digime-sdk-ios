//
//  DiscoveryResource.swift
//  DigiMeSDK
//
//  Created on 24/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

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
