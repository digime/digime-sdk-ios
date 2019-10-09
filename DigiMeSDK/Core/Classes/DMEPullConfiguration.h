//
//  DMEPullConfiguration.h
//  DigiMeSDK
//
//  Created on 08/08/2019
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEBaseConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Configuration object used by `DMEPullClient`.
 */
@interface DMEPullConfiguration : DMEBaseConfiguration

/**
 Your rsa private key hex. This property MUST be set before you can call authorize.
 */
@property (nonatomic, copy) NSString *privateKeyHex;

/**
 Enables one-time sharing in the authorization flow. Defaults to YES.
 */
@property (nonatomic) BOOL guestEnabled;

/**
 Designated Initializer
 
 @param appId application identifier
 @param contractId contract identifier
 @param privateKeyHex RSA private key string in HEX format
 @return instancetype
 */
- (instancetype)initWithAppId:(NSString *)appId contractId:(NSString *)contractId privateKeyHex:(NSString *)privateKeyHex NS_DESIGNATED_INITIALIZER;

/**
 Convinience Initializer
 
 @param appId application identifier
 @param contractId contract identifier
 @param p12FileName RSA private key file name from your application bundle
 @param p12Password p12 file password
 @return instancetype or nil if failed to extract private key from p12
 */
- (nullable instancetype)initWithAppId:(NSString *)appId contractId:(NSString *)contractId p12FileName:(NSString *)p12FileName p12Password:(NSString *)p12Password;

- (instancetype)initWithAppId:(NSString *)appId contractId:(NSString *)contractId NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
