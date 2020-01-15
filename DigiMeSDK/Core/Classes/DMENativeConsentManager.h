//
//  DMENativeConsentManager.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientCallbacks.h"
#import "DMEAppCommunicator+Private.h"

NS_ASSUME_NONNULL_BEGIN

/**
DMEOngoingAccessAuthCodeExchangeCompletion - executed when CA request returned to SDK after user has given consent.
 
@param session The session if authorization is successful, nil if not.
@param accessCode this code is part of OAuth authorization flow. SDK initiates request to get pre-authorization code and digi.me client exchanges it for an access code.
@param error nil if authorization is successful, otherwise an error specifying what went wrong.
*/
typedef void (^DMEOngoingAccessAuthCodeExchangeCompletion) (DMESession * _Nullable session, NSString * _Nullable accessCode, NSError * _Nullable error);


@class DMESessionManager;

@interface DMENativeConsentManager : NSObject <DMEAppCallbackHandler>

- (instancetype)initWithSessionManager:(DMESessionManager *)sessionManager appId:(NSString *)appId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Initiates contract authorization launching digi.me App if there is a valid active session.
 
 @param completion AuthorizationCompletionBlock
 */
- (void)beginAuthorizationWithCompletion:(DMEAuthorizationCompletion)completion;

/**
 Initiates contract authorization, with Ongoing Access, launching digi.me App if there is a valid active session. Should not be used with One-Off contracts.
 
 @param preAuthorizationCode NSString -  pre-authorization code that is passed to digi.me app in exchange for an authorization code.
 @param completion Ongoing Access  AuthorizationCompletionBlock
 */
- (void)beginOngoingAccessAuthorizationWithPreAuthCode:(NSString *)preAuthorizationCode completion:(DMEOngoingAccessAuthCodeExchangeCompletion)completion;

@end

NS_ASSUME_NONNULL_END
