//
//  DMESessionManager.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientCallbacks.h"
#import "DMESession.h"

NS_ASSUME_NONNULL_BEGIN

@class DMEAPIClient;
@class DMEClient;

@interface DMESessionManager : NSObject

@property (nonatomic, strong, nullable, readonly) DMESession *currentSession;

@property (nonatomic, strong, nullable, readonly) id<DMEDataRequest> scope;

- (instancetype)initWithApiClient:(DMEAPIClient *)apiClient contractId:(NSString *)contractId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Will return session object. Either existing session will be re-used, or new session will be created.

 @param scope optional DMEDataRequest that sets scope filter for the session.
 @param completion DMEAuthorizationCompletion
 */
- (void)sessionWithScope:(nullable id<DMEDataRequest>)scope completion:(DMEAuthorizationCompletion)completion;


/**
 This will return true if there is an active session and it has not expired

 @return YES if valid and not expired, NO otherwise.
 */
- (BOOL)isSessionValid;


/**
 Session key validation

 @param sessionKey NSString
 @return YES is passes validation, otherwise NO.
 */
- (BOOL)isSessionKeyValid:(NSString *)sessionKey;

@end

NS_ASSUME_NONNULL_END
