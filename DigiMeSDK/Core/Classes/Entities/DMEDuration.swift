//
//  DMEDuration.swift
//  DigiMeSDK
//
//  Created on 22/06/2020.
//  Copyright © 2020 digi.me Limited. All rights reserved.
//

import UIKit

@objcMembers
public class DMEDuration: NSObject {
    // Period of time in seconds used for attempting to sync new data. In case sync is not completed within
    // specified duration, a partial account status will be reported in `DMEFileListAccount`,
    // with `SourceFetchDurationQuotaReached` error code. Defaults to `0`.
    private(set) public var sourceFetch: Int = 0
    
    init(sourceFetch: Int) {
        self.sourceFetch = sourceFetch
    }
}
