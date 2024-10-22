//
//  AccountDataProvider.swift
//  DigiMeCore
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public protocol AccountDataProvider {
    var metadata: LogEventMeta { get }
    var sourceAccount: SourceAccount { get }
    var sourceAccountData: SourceAccountData { get }
}
