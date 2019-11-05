//
//  DMEOperationTests.swift
//  DigiMeSDKExample_Tests
//
//  Created on 04/11/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import DigiMeSDK

class DMEOperationTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOperationCanBeCancelled() {
        
        let expectation = XCTestExpectation(description: "Queue operations list should be empty")
        
        let configuration = DMEPullConfiguration(appId: "test_app", contractId: "test_contract", privateKeyHex: "test_key_hex")
        configuration.maxConcurrentRequests = 1
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = configuration.maxConcurrentRequests
        
        queue.addOperation(cancellableWaitingOperation(configuration: configuration))
        queue.addOperation(cancellableWaitingOperation(configuration: configuration))
        queue.addOperation(cancellableWaitingOperation(configuration: configuration))
        queue.addOperation(cancellableWaitingOperation(configuration: configuration))
        queue.addOperation(cancellableWaitingOperation(configuration: configuration))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            queue.cancelAllOperations()
            
            //allow queue opportunity to call `cancel` on all operations.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                XCTAssertTrue(queue.operationCount == 0, "Expected tere to be 0 operations, but there are \(queue.operationCount)")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    // this operation will complete in 3 seconds. It ust be cancelled before that happens or it will fail the test.
    func cancellableWaitingOperation(configuration: DMEClientConfiguration) -> DMEOperation {
        let operation = DMEOperation(configuration: configuration)
        operation.workBlock = { [unowned operation] in
            var count = 0
            
            while count < 30 {
                guard !operation.isCancelled else {
                    operation.finishDoingWork()
                    return
                }
                
                //do work
                Thread.sleep(forTimeInterval: 0.1)
                
                guard !operation.isCancelled else {
                    operation.finishDoingWork()
                    return
                }
                
                count += 1
            }
            
            operation.finishDoingWork()
            XCTFail("Cancellable operation was not cancelled in time.")
        }
        
        return operation
    }
}
