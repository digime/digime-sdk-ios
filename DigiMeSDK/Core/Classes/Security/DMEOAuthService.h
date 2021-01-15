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

- (void)latestVerificationPublicKeyWithSuccess:(void(^)(NSString *publicKey))success failure:(void(^)(NSError *error))failure;

- (void)requestOAuthTokenForAuthCode:(NSString *)authCode publicKey:(nullable NSString *)publicKey success:(void (^)(DMEOAuthToken * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure;

- (void)renewAccessTokenWithOAuthToken:(DMEOAuthToken * _Nullable)oAuthToken publicKey:(nullable NSString *)publicKey retryHandler:(nonnull void(^)(DMEOAuthToken *oAuthToken))retryHandler reauthHandler:(nonnull void(^)(void))reauthHandler errorHandler:(nonnull void(^)(NSError *error))errorHandler;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
