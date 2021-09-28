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
        guard !isCancelled else {
            finish()
            return
        }

        isFinished = false
        isExecuting = true
        main()
    }

    // swiftlint:disable unavailable_function
    override func main() {
        // This is a deliberate use of `fatalError` to ensure that subclasses implement `main` function without calling `super`
        fatalError("Subclasses must implement `main` without calling super.")
    }
    // swiftlint:enable unavailable_function

    func finish() {
        isExecuting = false
        isFinished = true
    }
}
