//
//  DMEClientConfiguration.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kDMEClientSchemePrefix;

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

/**
 Base URL for all outgoing Network operations.
 */
@property (nonatomic, strong, readonly) NSString *baseUrl;

/**
 Your application Id. This property MUST be set before you can call authorize.
 */
@property (nonatomic, nullable, copy) NSString *appId;

/**
 Your contract Id. This property MUST be set before you can call authorize.
 */
@property (nonatomic, nullable, copy) NSString *contractId;

/**
 Your rsa private key hex. This property MUST be set before you can call authorize.
 */
@property (nonatomic, nullable, copy) NSString *privateKeyHex;

/**
 Designated Initializer
 
 @param appId application identifier
 @param contractId contract identifier
 @param privateKeyHex RSA private key string in HEX format
 @return instancetype
 */
- (instancetype)initWithAppId:(NSString *)appId contractId:(NSString *)contractId privateKeyHex:(NSString *)privateKeyHex;// NS_DESIGNATED_INITIALIZER;

/**
 Convinience Initializer
 
 @param appId application identifier
 @param contractId contract identifier
 @param p12FileName RSA private key file name from your application bundle
 @param p12Password p12 file password
 @return instancetype or nil if failed to extract private key from p12
 */
- (nullable instancetype)initWithAppId:(NSString *)appId contractId:(NSString *)contractId p12FileName:(NSString *)p12FileName p12Password:(NSString *)p12Password;

//- (instancetype)init NS_UNAVAILABLE;
//+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
