//
//  SourcesInfo.swift
//  DigiMeSDK
//
//  Created on 07/11/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.

import Foundation

public struct SourcesInfo: Codable {
    public var data: [Source]
    public var limit: Int
    public var offset: Int
    public var total: Int
}
