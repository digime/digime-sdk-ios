//
//  Sample.swift
//  DigiMeHealthKit
//
//  Created on 14.09.20.
//

import Foundation

public protocol Sample: Codable {
    var startTimestamp: Double { get }
    var endTimestamp: Double { get }
}
