//
//  HealthKitFilesDataServiceProtocol.swift
//  DigiMeCore
//
//  Created on 28/07/2021.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

public protocol HealthKitFilesDataServiceProtocol {
    init(account: SourceAccount, healthKitService: HealthKitServiceProtocol)
    func queryData(from startDate: Date, to endDate: Date, downloadHandler: ((Result<File, SDKError>) -> Void)?, completion: ((Result<[FileListItem], SDKError>) -> Void)?)
}
