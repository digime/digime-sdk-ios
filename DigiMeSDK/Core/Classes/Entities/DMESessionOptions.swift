//
//  DMESessionOptions.swift
//  DigiMeSDK
//
//  Created on 22/06/2020.
//  Copyright © 2020 digi.me Limited. All rights reserved.
//

import UIKit

@objcMembers
/// Options used to configure session parameters for data sharing
public class DMESessionOptions: NSObject {
    
    // Custom scope that will be applied to available data.
    public var scope: DMEDataRequest?

    //Limits object for configuring a session
    public var limits: DMELimits?
}
