//
//  HealthKitServiceProtocol.swift
//  DigiMeSDK
//
//  Created on 28/07/2021.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

public protocol ReadableObjectType {
}

public protocol WritableSampleType {
}

public protocol HealthKitServiceProtocol {
    init()
    func requestAuthorization(typesToRead: [ReadableObjectType], typesToWrite: [WritableSampleType], completion: @escaping (Bool, Error?) -> Void)
    func reportErrorLog(error: Error?)
#if targetEnvironment(simulator)
    func addTestData(completion: @escaping (_ success: Bool, _ error: Error?) -> Void)
#endif
}
