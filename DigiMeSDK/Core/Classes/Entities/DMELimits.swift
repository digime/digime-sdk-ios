//
//  DMELimits.swift
//  DigiMeSDK
//
//  Created on 22/06/2020.
//  Copyright © 2020 digi.me Limited. All rights reserved.
//

import UIKit

@objcMembers
public class DMELimits: NSObject {
    //Duration configuration
    private(set) public var duration: DMEDuration

    //Convenience initializer specifying `sourceFetchDuration`.
    public init(sourceFetchDuration: Int) {
        duration = DMEDuration(sourceFetch: sourceFetchDuration)
    }
}
