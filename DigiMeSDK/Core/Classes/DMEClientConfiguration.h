//
//  DMEClientConfiguration.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#pragma once

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol for base client configuration properties.
 */
@protocol DMEClientConfiguration <NSObject>

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

/**
 Base URL for all outgoing Network operations.
 */
@property (nonatomic, strong, readonly) NSString *baseUrl;

/**
 Your application Id. This property MUST be set before you can call authorize.
 */
@property (nonatomic, copy, readonly) NSString *appId;

/**
 Your contract Id. This property MUST be set before you can call authorize.
 */
@property (nonatomic, copy) NSString *contractId;

/**
 Your rsa private key hex. This property MUST be set before you can call authorize.
 */
@property (nonatomic, copy) NSString *privateKeyHex;

/**
 Determines whether the user is automatically forwarded
 to digi.me app when the `DMEOAuthToken` could not be refreshed by the SDK.
 Default to YES.
 Setting this to NO will instead return a `AuthErrorOAuthTokenExpired` error.
 */
@property (nonatomic) BOOL autoRecoverExpiredCredentials;

@end

NS_ASSUME_NONNULL_END
