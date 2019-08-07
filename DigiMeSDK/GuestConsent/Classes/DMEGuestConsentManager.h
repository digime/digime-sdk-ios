//
//  DMEGuestConsentManager.h
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEAppCommunicator+Private.h"
#import "DMEClientCallbacks.h"

@class DMEClientConfiguration;
@class DMESessionManager;

NS_ASSUME_NONNULL_BEGIN

@interface DMEGuestConsentManager : NSObject <DMEAppCallbackHandler>

- (instancetype)initWithSessionManager:(DMESessionManager *)sessionManager configuration:(DMEClientConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)requestGuestConsentWithCompletion:(DMEAuthorizationCompletion)completion;

@end

NS_ASSUME_NONNULL_END
