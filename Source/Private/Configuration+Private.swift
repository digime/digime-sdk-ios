//
//  Configuration+Private.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

internal extension Configuration {
    
    var clientId: String {
        "\(appId)_\(contractId)"
    }
    
    var redirectUri: String {
        "digime-ca-\(appId)://"
    }
}
