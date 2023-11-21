//
//  ContractVersion4.swift
//  DigiMeSDK
//
//  Created on 11/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

import Foundation

struct ContractVersion4: Decodable {
    let tpspAction: String?
    let tpspDataContext: String?
    let tpspLogo: String?
    let tpspName: String?
    let tpspPeriod: String?
    let tpspPurpose: String?
    let tpspPurposeCategory: String?
    let tpspRetention: String?
    let tpspTerms: String?
    let tpspURL: String?
    let tpspContent: Bool?
    let tpspDataLeavesDevice: Bool?
    let tpspShared: Bool?
    let tpspPurposeSubCategory: String?
    let tpspRTBF: Bool?
    let tpspRTBFString: String?
    let typeLabel: String?
    let contractTypeString: String?
    let headerColor: String?
    let pushFrequency: String?
    let pushContent: [String]?
    let dataRequest: String?
    let isDataRetained: Bool?
    let contractSchema: String?
    
    enum CodingKeys: String, CodingKey {
        case tpspAction
        case tpspDataContext = "tpspDC"
        case tpspLogo
        case tpspName
        case tpspPeriod
        case tpspPurpose
        case tpspPurposeCategory
        case tpspRetention
        case tpspTerms
        case tpspURL = "tpspUrl"
        case tpspContent
        case tpspDataLeavesDevice
        case tpspShared
        case tpspPurposeSubCategory
        case tpspRTBF
        case tpspRTBFString = "tpspRTBFText"
        case typeLabel
        case contractTypeString = "type"
        case headerColor
        case pushFrequency
        case pushContent
        case dataRequest
        case isDataRetained
        case contractSchema = "certificateContractSchemaVersion"
    }
    
    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        tpspAction = try container.decodeIfPresent(String.self, forKey: .tpspAction)
        tpspDataContext = try container.decodeIfPresent(String.self, forKey: .tpspDataContext)
        tpspLogo = try container.decodeIfPresent(String.self, forKey: .tpspLogo)
        tpspName = try container.decodeIfPresent(String.self, forKey: .tpspName)
        tpspPeriod = try container.decodeIfPresent(String.self, forKey: .tpspPeriod)
        tpspPurpose = try container.decodeIfPresent(String.self, forKey: .tpspPurpose)
        tpspPurposeCategory = try container.decodeIfPresent(String.self, forKey: .tpspPurposeCategory)
        tpspRetention = try container.decodeIfPresent(String.self, forKey: .tpspRetention)
        tpspTerms = try container.decodeIfPresent(String.self, forKey: .tpspTerms)
        tpspURL = try container.decodeIfPresent(String.self, forKey: .tpspURL)
        tpspContent = try container.decodeIfPresent(Bool.self, forKey: .tpspContent)
        tpspDataLeavesDevice = try container.decodeIfPresent(Bool.self, forKey: .tpspDataLeavesDevice)
        tpspShared = try container.decodeIfPresent(Bool.self, forKey: .tpspShared)
        tpspPurposeSubCategory = try container.decodeIfPresent(String.self, forKey: .tpspPurposeSubCategory)
        tpspRTBFString = try container.decodeIfPresent(String.self, forKey: .tpspRTBFString)
        typeLabel = try container.decodeIfPresent(String.self, forKey: .typeLabel)
        contractTypeString = try container.decodeIfPresent(String.self, forKey: .contractTypeString)
        headerColor = try container.decodeIfPresent(String.self, forKey: .headerColor)
        pushFrequency = try container.decodeIfPresent(String.self, forKey: .pushFrequency)
        pushContent = try container.decodeIfPresent([String].self, forKey: .pushContent)
        dataRequest = try container.decodeIfPresent(String.self, forKey: .dataRequest)
        isDataRetained = try container.decodeIfPresent(Bool.self, forKey: .isDataRetained)
        contractSchema = try container.decodeIfPresent(String.self, forKey: .contractSchema)
        
        // this specific value could be:
        // tpspRTBF = "Will be honored"; String
        // tpspRTBF = 1;                 Boolean
        // or not present at all
        do {
            tpspRTBF = try container.decodeIfPresent(Bool.self, forKey: .tpspRTBF)
        }
        catch {
            tpspRTBF = true
        }
    }
}

// MARK: - Convenience initializers
extension ContractVersion4 {
    init?(data: Data) {
        guard let contract = try? data.decoded() as ContractVersion4 else {
            return nil
        }
        
        self = contract
    }

    init?(_ json: [AnyHashable: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return nil
        }
        
        self.init(data: data)
    }
}
