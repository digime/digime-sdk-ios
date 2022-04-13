//
//  HealthDataAccount.swift
//  DigiMeSDK
//
//  Created on 02/04/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation
import UIKit

struct HealthDataAccount {
    var account: Account {
        let service = AccountServiceDescriptor(name: "AppleHealth", logo: "https://digimedownloads.blob.core.windows.net/ios/sdkexample/apple-health-icon.png")
        let account = Account(identifier: "28_\(UIDevice.current.identifierForVendor!.uuidString)", name: "Apple Health", service: service, number: NSUserName())
        return account
    }
}
