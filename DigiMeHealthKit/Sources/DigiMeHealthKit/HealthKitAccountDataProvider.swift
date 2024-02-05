//
//  HealthKitData.swift
//  DigiMeSDK
//
//  Created on 02/04/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

public class HealthKitAccountDataProvider: AccountDataProvider, HealthKitAccountDataProviderProtocol {
    public var metadata: LogEventMeta {
        LogEventMeta(service: ["applehealth"],
                     servicegroup: ["health & fitness"],
                     appname: Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
    }

    public var sourceAccount: SourceAccount {
        let service = AccountServiceDescriptor(name: "AppleHealth",
                                               logo: "https://digimedownloads.blob.core.windows.net/ios/sdkexample/apple-health-icon.png")
        return SourceAccount(identifier: "28_applehealth",
                             name: "Apple Health",
                             service: service,
                             number: NSUserName())
    }
    
    public var sourceAccountData: SourceAccountData {
        let accessTokenStatus = SourceAccountData.AccessTokenStatus(authorized: true,
                                                                    expiresAt: Calendar.current.date(byAdding: .year, value: 1, to: Date())!.timeIntervalSince1970)
        return SourceAccountData(identifier: UUID(),
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
                                 username: nil, 
                                 sample: false)
    }
    
    public required init() {
    }
}
