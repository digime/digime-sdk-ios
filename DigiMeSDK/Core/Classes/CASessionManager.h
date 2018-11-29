//
//  CASessionManager.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientCallbacks.h"
#import "CASession.h"

NS_ASSUME_NONNULL_BEGIN

@class DMEAPIClient;
@class DMEClient;

@interface CASessionManager : NSObject

@property (nonatomic, strong, nullable, readonly) CASession *currentSession;

@property (nonatomic, strong, nullable, readonly) id<CADataRequest> scope;

@property (nonatomic, strong, readonly) DMEClient *client;

- (instancetype)initWithApiClient:(DMEAPIClient *)apiClient;

/**
 Will return session object. Either existing session will be re-used, or new session will be created.

 @param scope optional CADataRequest that sets scope filter for the session.
 @param completion AuthorizationCompletionBlock
 */
- (void)sessionWithScope:(nullable id<CADataRequest>)scope completion:(AuthorizationCompletionBlock)completion;


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
