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
 Your rsa public key hex. 
 */
@property (nonatomic, copy, nullable) NSString *publicKeyHex;

/**
 Your rsa private key hex. This property MUST be set before you can call authorize.
 */
@property (nonatomic, copy) NSString *privateKeyHex;

/**
 Enables one-time sharing in the authorization flow. Defaults to YES.
 */
@property (nonatomic) BOOL guestEnabled;

/**
 Determines interval between fileList fetches when using `getSessionData` or `getSessionFileList`.
 Defaults to 3 seconds.
 */
@property (nonatomic) NSTimeInterval pollInterval;

/**
 Determines max number of retries before `getSessionData` or `getSessionFileList` times out.
 Time out condition is reached when there have been no updates to the `DMEFileList` during specified number of polls.
 Defaults to 100. This is affected by `pollInterval`. Using default values these would result in 100 * 3 = 300 seconds (5 minutes).
 */
@property (nonatomic) NSInteger maxStalePolls;

/**
 Determines whether the user is automatically forwarded
 to digi.me app when the `DMEOAuthToken` could not be refreshed by the SDK.
 Default to YES.
 Setting this to NO will in stead return a `AuthErrorOAuthTokenExpired` error.
 */
@property (nonatomic) BOOL autoRecoverExpiredCredentials;

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
