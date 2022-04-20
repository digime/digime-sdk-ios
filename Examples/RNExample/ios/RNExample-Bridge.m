//
//  RNExample-Bridge.m
//  RNExample
//
//  Created by Alex Hamilton on 18/04/2022.
//  Copyright © 2022 digi.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTBridge.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(RNExampleEvent, RCTEventEmitter)

RCT_EXTERN_METHOD(supportedEvents)

@end

@interface RCT_EXTERN_MODULE(RNExampleClient, NSObject)

RCT_EXTERN_METHOD(retrieveData)

RCT_EXTERN_METHOD(retrieveDataWithEventsFrom:(NSTimeInterval)from
                  to:(NSTimeInterval)to)

RCT_EXTERN_METHOD(retrieveDataWithCompletionFrom:(NSTimeInterval)from
                  to:(NSTimeInterval)to
                  resultCompletion:(RCTResponseSenderBlock)resultCompletion
                  errorCompletion:(RCTResponseErrorBlock)errorCompletion)

RCT_EXTERN_METHOD(retrieveDataWithPromisesFrom:(NSTimeInterval)from
                  to:(NSTimeInterval)to
                  successCallback:(RCTPromiseResolveBlock)successCallback
                  errorCallback:(RCTPromiseRejectBlock)errorCallback)

RCT_EXTERN_METHOD(deleteUser)

#if TARGET_IPHONE_SIMULATOR
RCT_EXTERN_METHOD(addTestData)
#endif

@end
