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

@class DMEClient;

@interface CASessionManager : NSObject

@property (nonatomic, strong, readonly) CASession *currentSession;

@property (nonatomic, strong, readonly) DMEClient *client;

/**
 Will return session object. Either existing session will be re-used, or new session will be created.

 @param completion AuthorizationCompletionBlock
 */
- (void)sessionWithCompletion:(AuthorizationCompletionBlock)completion;


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
