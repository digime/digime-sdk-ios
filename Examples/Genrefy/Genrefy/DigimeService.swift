//
//  DigimeService.swift
//  Genrefy
//
//  Copyright © 2019 digi.me. All rights reserved.
//

import Foundation
import DigiMeSDK

class DigimeService {
    
    static let sharedInstance = DigimeService()
    
    let dmeClient: DMEPullClient?
    
    init() {
        let appId = "qgEUV8iJENRiUkuYF5lLpdsOv7Hp0biy"
        let contractId = "yrg1LktWk2gldVk8atD5Pf7Um4c1LnMs"
        let p12FileName = "yrg1LktWk2gldVk8atD5Pf7Um4c1LnMs"
        let p12Password = "digime"
        
        let configuration = DMEPullConfiguration(appId: appId, contractId: contractId, p12FileName: p12FileName, p12Password: p12Password)
        configuration?.debugLogEnabled = true

        guard let config = configuration else {
            print("ERROR: Configuration object not set")
            dmeClient = nil
            return
        }
        
        dmeClient = DMEPullClient(configuration: config)
    }
}
