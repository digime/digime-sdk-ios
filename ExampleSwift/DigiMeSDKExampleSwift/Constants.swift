//
//  Constants.swift
//  DigiMeSDKExampleSwift
//
//  Copyright © 2019 digi.me. All rights reserved.
//

import Foundation

struct Constants {
    
    #error("REPLACE 'YOUR_APP_ID' with your App ID. Also don't forget to set the app id in CFBundleURLSchemes.")
    static let appId = "YOUR_APP_ID"
    
    #error("REPLACE 'YOUR_CA_CONTRACT_ID' with your Consent Access contract ID.")
    static let CAContractId = "YOUR_CA_CONTRACT_ID"
    
    #error("REPLACE 'YOUR_POSTBOX_CONTRACT_ID' with your Postbox contract ID.")
    static let postboxContractId = "YOUR_POSTBOX_CONTRACT_ID"
    
    #error("REPLACE 'YOUR_P12_PASSWORD' with password provided by digi.me Ltd.")
    static let p12Password = "YOUR_P12_PASSWORD"
    
    #error("REPLACE 'YOUR_P12_FILE_NAME' with .p12 file name (without the .p12 extension) provided by digi.me Ltd.")
    static let p12FileName = "YOUR_P12_FILE_NAME"
}
