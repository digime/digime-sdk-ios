//
//  HealthKitAccountDataProviderProtocol.swift
//  DigiMeCore
//
//  Created on 28/07/2021.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

public protocol HealthKitAccountDataProviderProtocol {
    init()
    var sourceAccount: SourceAccount { get }
    var sourceAccountData: SourceAccountData { get }
}
