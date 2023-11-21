//
//  RetryingOperation.swift
//  DigiMeSDK
//
//  Created on 28/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class RetryingOperation: AsyncOperation {

    var exponentialBackoffFactor = 1.5
    var retryCount = 0
    var retryDelay = 750 // Initial delay in milliseconds
    var maxRetryCount = 5
    private let retryQueue = DispatchQueue(label: "Queue for Syncing Retries (for One Retrying Operation)", qos: .utility)
    
    var canRetry: Bool {
        retryCount < maxRetryCount
    }
    
    func retry() {
        guard canRetry else {
            return
        }
        
        let delay = Int(Double(retryDelay) * pow(exponentialBackoffFactor, Double(retryCount)))
        retryCount += 1
        retryQueue.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            self.main()
        }
    }
}
