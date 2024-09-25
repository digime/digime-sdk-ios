//
//  CombinedBloodPressureStats.swift
//  DigiMePlugin
////
//  Created on 03/09/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import CryptoKit
import DigiMeHealthKit
import Foundation

struct CombinedBloodPressureStats: PayloadIdentifiable {
    let id: String
    let identifier: String
    let startDate: Date
    let endDate: Date
    let systolic: DigiMeHealthKit.Statistics
    let diastolic: DigiMeHealthKit.Statistics

    init(identifier: String, startDate: Date, endDate: Date, systolic: DigiMeHealthKit.Statistics, diastolic: DigiMeHealthKit.Statistics) {
        self.identifier = identifier
        self.startDate = startDate
        self.endDate = endDate
        self.systolic = systolic
        self.diastolic = diastolic
        self.id = Self.generateHashId(
            identifier: identifier,
            startDate: startDate,
            endDate: endDate,
            systolicId: systolic.id,
            diastolicId: diastolic.id
        )
    }

    private static func generateHashId(identifier: String, startDate: Date, endDate: Date, systolicId: String, diastolicId: String) -> String {
        let idString = "\(identifier)_\(startDate.timeIntervalSince1970)_\(endDate.timeIntervalSince1970)_\(systolicId)_\(diastolicId)"
        let inputData = Data(idString.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

        return String(format: "%@-%@-%@-%@-%@",
                      String(hashString.prefix(8)),
                      String(hashString.dropFirst(8).prefix(4)),
                      String(hashString.dropFirst(12).prefix(4)),
                      String(hashString.dropFirst(16).prefix(4)),
                      String(hashString.dropFirst(20).prefix(12))
        )
    }
}
