//
//  AsyncOperation.swift
//  DigiMeSDK
//
//  Created on 28/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    private let lockQueue = DispatchQueue(label: "me.digi.sdk.asyncoperation", attributes: .concurrent)
    
    override var isAsynchronous: Bool {
        true
    }

    private var _isExecuting = false
    override private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished = false
    override private(set) var isFinished: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    override func start() {
        print("Starting")
        guard !isCancelled else {
            finish()
            return
        }

        isFinished = false
        isExecuting = true
        main()
    }

    override func main() {
        fatalError("Subclasses must implement `main` without overriding super.")
    }

    func finish() {
        isExecuting = false
        isFinished = true
    }
}

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
