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
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? DMEFileListItem else {
            return false
        }
        
        guard self !== object else {
            return true
        }
        
        return name == object.name && updateDate.timeIntervalSince1970 == object.updateDate.timeIntervalSince1970
    }
    
    public override var hash: Int {
        return name.hashValue ^ updateDate.hashValue
    }
}
