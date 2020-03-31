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
        // production environment
        let appId = "IfnN9Y27Jym3P1Fad3ks3sTlo22flUBb"
        let contractId = "xv1R4Rc63Od956kHtX5H3SSSAFc9WqpT"
        let p12FileName = "fJI8P5Z4cIhP3HawlXVvxWBrbyj5QkTF"
        let p12Password = "monkey periscope"
        
        let configuration = DMEPullConfiguration(appId: appId, contractId: contractId, p12FileName: p12FileName, p12Password: p12Password)
        
        guard let config = configuration else {
            print("ERROR: Configuration object not set")
            dmeClient = nil
            return
        }
        
        dmeClient = DMEPullClient(configuration: config)
    }
}
