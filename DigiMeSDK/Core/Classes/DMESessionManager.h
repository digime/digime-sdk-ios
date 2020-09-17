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
@class DMESessionOptions;

@interface DMESessionManager : NSObject

@property (nonatomic, strong, nullable, readonly) DMESession *currentSession;

@property (nonatomic, strong, nullable, readonly) DMESessionOptions *options;

- (instancetype)initWithApiClient:(DMEAPIClient *)apiClient contractId:(NSString *)contractId NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Will return session object. Either existing session will be re-used, or new session will be created.

 @param options optional DMESessionOptions that specifies additional configuration for the session.
 @param completion DMEAuthorizationCompletion
 */
- (void)sessionWithOptions:(DMESessionOptions * _Nullable)options completion:(DMEAuthorizationCompletion)completion NS_SWIFT_NAME(session(options:completion:));


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
