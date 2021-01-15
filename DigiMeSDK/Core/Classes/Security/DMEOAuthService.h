//
//  DMEOAuthService.h
//  DigiMeSDK
//
//  Created on 14/01/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DMEAPIClient;
@protocol DMEClientConfiguration;
@class DMEOAuthToken;

NS_ASSUME_NONNULL_BEGIN

@interface DMEOAuthService : NSObject

- (instancetype)initWithConfiguration:(id<DMEClientConfiguration>)configuration apiClient:(DMEAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;

/**
 Requests the pre-authorization code for this contract
 
 @param publicKey Optional public key represented as hex string used to verify the JWT signature. If omitted, verification does not occur
 @param success Block called on success with pre-authorization code
 @param failure Block called if any error occurred
 */
- (void)requestPreAuthorizationCodeWithPublicKey:(nullable NSString *)publicKey success:(void(^)(NSString *preAuthCode))success failure:(void(^)(NSError *error))failure;

/**
 Converts an authorization code into an OAuth token
 
 @param authCode The authorization code to convert
 @param publicKey Optional public key represented as hex string used to verify the JWT signature. If omitted, verification does not occur
 @param success Block called on success with OAuth code
 @param failure Block called if any error occurred
 */
- (void)requestOAuthTokenForAuthCode:(NSString *)authCode publicKey:(nullable NSString *)publicKey success:(void (^)(DMEOAuthToken * _Nonnull oAuthToken))success failure:(void (^)(NSError * _Nonnull error))failure;

/**
 Renews an OAuth token's access token using its refresh token.
 
 @param oAuthToken The OAuth token containing the access and refresh tokens
 @param publicKey Optional public key represented as hex string used to verify the JWT signature. If omitted, verification does not occur.
 @param retryHandler Block called on refresh success with the new OAuth token
 @param reauthHandler Block called if renewing tokens failed and authorization is required again from digi.me app. This is not called if `autoRecoverExpiredCredentials` is set to `false` in the configuration
 @param errorHandler Block called if any error occurred
 */
- (void)renewAccessTokenWithOAuthToken:(DMEOAuthToken * _Nullable)oAuthToken publicKey:(nullable NSString *)publicKey retryHandler:(nonnull void(^)(DMEOAuthToken *oAuthToken))retryHandler reauthHandler:(nonnull void(^)(void))reauthHandler errorHandler:(nonnull void(^)(NSError *error))errorHandler;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
