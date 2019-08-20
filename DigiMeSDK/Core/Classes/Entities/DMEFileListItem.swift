//
//  DMEFileListItem.swift
//  DigiMeSDK
//
//  Created on 13/08/2019.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import UIKit

@objcMembers
public class DMEFileListItem: NSObject {

    var name: String
    var updateDate: Date
    
    public init(name: String, updateDate: Date) {
        self.name = name
        self.updateDate = updateDate
        
    }
}
