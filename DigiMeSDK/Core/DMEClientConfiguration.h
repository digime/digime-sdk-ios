//
//  DMEClientConfiguration.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMEClientConfiguration : NSObject

/**
 Connection time out in seconds. Defaults to 25.
 */
@property (nonatomic) NSTimeInterval globalTimeout;


/**
 Controls API retries. Default to YES.
 */
@property (nonatomic) BOOL retryOnFail;


/**
 Delay in milliseconds before retrying failed request. Defaults to 750.
 */
@property (nonatomic) NSInteger retryDelay;


/**
 Controls whether retries occur with delay. Defaults to YES.
 */
@property (nonatomic) BOOL retryWithExponentialBackOff;


/**
 Maximum number of retries before failing. Defaults to 5.
 */
@property (nonatomic) NSInteger maxRetryCount;


/**
 Maximum concurrent network operations. Defaults to 5.
 */
@property (nonatomic) NSInteger maxConcurrentRequests;


/**
 Determines whether additional SDK DEBUG logging is enabled. Defaults to NO.
 */
@property (nonatomic) BOOL debugLogEnabled;

@end
