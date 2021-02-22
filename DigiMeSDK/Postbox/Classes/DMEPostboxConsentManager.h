//
//  DMEPostboxConsentManager.h
//  DigiMeSDK
//
//  Created on 26/06/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEAppCommunicator+Private.h"
#import "DMEClientCallbacks.h"

NS_ASSUME_NONNULL_BEGIN

/**
 DMEOngoingPostboxAuthCodeExchangeCompletion - executed when ongoing Postbox request returned to SDK after user has given consent.
 
@param postbox A Postbox if authorization is successful, nil if not.
@param accessCode this code is part of OAuth authorization flow. SDK initiates request to get pre-authorization code and digi.me client exchanges it for an access code.
@param error nil if authorization is successful, otherwise an error specifying what went wrong.
*/
typedef void (^DMEOngoingPostboxAuthCodeExchangeCompletion) (DMEPostbox * _Nullable postbox, NSString * _Nullable accessCode, NSError * _Nullable error);

@class DMESessionManager;

@interface DMEPostboxConsentManager : NSObject <DMEAppCallbackHandler>

- (instancetype)initWithSessionManager:(DMESessionManager *)sessionManager appId:(NSString *)appId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)requestPostboxWithCompletion:(DMEPostboxCreationCompletion)completion;
- (void)requestOngoingPostboxWithPreAuthCode:(NSString *)preAuthorizationCode completion:(DMEOngoingPostboxAuthCodeExchangeCompletion)completion;

@end

NS_ASSUME_NONNULL_END
