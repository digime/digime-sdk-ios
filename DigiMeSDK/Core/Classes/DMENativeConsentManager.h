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
 Initiates ongoing contract authorization using cyclic CA flow and launching digi.me App if there is a valid active session.
 
 @param preAuthorizationCode NSString -  pre- authorization code that we will pass to digi.me to exchange for authorization code
 @param completion Cyclic CA  AuthorizationCompletionBlock
 */
- (void)beginOngoingAccessAuthorizationWithPreAuthCode:(NSString *)preAuthorizationCode completion:(DMEOngoingAccessAuthCodeExchangeCompletion)completion;

@end

NS_ASSUME_NONNULL_END
