//
//  HealthKitData.swift
//  DigiMeSDK
//
//  Created on 02/04/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation
import UIKit

struct HealthKitAccountData {
    let metadata = LogEventMeta(service: ["applehealth"], servicegroup: ["health & fitness"], appname: Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
    
    var sourceAccount: SourceAccount {
        let service = AccountServiceDescriptor(name: "AppleHealth", logo: "https://digimedownloads.blob.core.windows.net/ios/sdkexample/apple-health-icon.png")
        let account = SourceAccount(identifier: "28_applehealth", name: "Apple Health", service: service, number: NSUserName())
        return account
    }
    
    var sourceAccountData: SourceAccountData {
        let accessTokenStatus = SourceAccountData.AccessTokenStatus(authorized: true, expiresAt: Calendar.current.date(byAdding: .year, value: 1, to: Date())!.timeIntervalSince1970)
        let account = SourceAccountData(identifier: UUID(),
                                        id: "28_applehealth",
                                        reference: "applehealth",
                                        type: .user,
                                        createdDate: Date().timeIntervalSince1970,
                                        serviceGroupId: 4,
                                        serviceGroupName: "health & fitness",
                                        serviceTypeId: 28,
                                        serviceTypeName: "Apple Health",
                                        serviceTypeReference: "Apple Health",
                                        sourceId: 260,
                                        updatedDate: Date().timeIntervalSince1970,
                                        accessTokenStatus: accessTokenStatus,
                                        providerFavIcon: nil,
                                        providerLogo: "https://digimedownloads.blob.core.windows.net/ios/sdkexample/apple-health-icon.png",
                                        serviceProviderId: nil,
                                        serviceProviderName: nil,
                                        serviceProviderReference: nil,
                                        username: nil)
        return account
    }
}
