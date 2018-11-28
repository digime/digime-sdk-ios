//
//  DMEAuthorizationManager.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMEAuthorizationManager.h"
#import "CASessionManager.h"
#import "DMEClient.h"

#import "NSError+Auth.h"
#import "UIViewController+DMEExtension.h"

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

static NSString * const kCARequestSessionKey = @"CARequestSessionKey";
static NSString * const kCADigimeResponse = @"CADigimeResponse";
static NSString * const kCARequestRegisteredAppID = @"CARequestRegisteredAppID";

@interface DMEAuthorizationManager()

@property (nonatomic, strong, readonly) CASession *session;
@property (nonatomic, strong, readonly) CASessionManager *sessionManager;
@property (nonatomic, copy, nullable) AuthorizationCompletionBlock authCompletionBlock;

@end

@implementation DMEAuthorizationManager

#pragma mark - CallbackHandler Conformance

@synthesize appCommunicator = _appCommunicator;

- (instancetype)initWithAppCommunicator:(DMEAppCommunicator *__weak)appCommunicator
{
    self = [super init];
    if (self)
    {
        _appCommunicator = appCommunicator;
    }
    return self;
}

- (BOOL)canHandleAction:(DMEOpenAction *)action
{
    return [action isEqualToString:@"data"];
}

- (void)handleAction:(DMEOpenAction *)action withParameters:(NSDictionary<NSString *,id> *)parameters
{
    BOOL result = [parameters[kCADigimeResponse] boolValue];
    NSString *sessionKey = parameters[kCARequestSessionKey];
    
    NSError *err;
    
    if(![self.sessionManager isSessionKeyValid:sessionKey])
    {
        err = [NSError authError:AuthErrorInvalidSessionKey];
    }
    else if(!result)
    {
        err = [NSError authError:AuthErrorCancelled];
    }
    
    if (self.authCompletionBlock)
    {
        // Need to know if we succeeded.
        dispatch_async(dispatch_get_main_queue(), ^{
            self.authCompletionBlock(self.session, err);
        });
    }
}

#pragma mark - Authorization

-(void)beginAuthorizationWithCompletion:(AuthorizationCompletionBlock)completion
{
    if (![self.sessionManager isSessionValid])
    {
        completion(nil, [NSError authError:AuthErrorInvalidSession]);
        return;
    }
    self.authCompletionBlock = completion;
    
    DMEOpenAction *action = @"data";
    NSDictionary *params = @{
                             kCARequestSessionKey: self.session.sessionKey,
                             kCARequestRegisteredAppID: self.sessionManager.client.appId,
                             };
    
    [self.appCommunicator openDigiMeAppWithAction:action parameters:params];
}

#pragma mark - Convenience

- (CASession *)session
{
    return self.sessionManager.currentSession;
}

-(CASessionManager *)sessionManager
{
    return [DMEClient sharedClient].sessionManager;
}

@end
