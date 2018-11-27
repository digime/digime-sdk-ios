//
//  DMEGuestConsentManager.m
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 me.digi. All rights reserved.
//

#import "DMEGuestConsentManager.h"
#import "CASessionManager.h"
#import "DMEClient.h"
#import "DMEAppCommunicator+GuestConsent.h"

static NSString * const kCADigimeResponse = @"CADigimeResponse";
static NSString * const kCARequestSessionKey = @"CARequestSessionKey";
static NSString * const kCARequestRegisteredAppID = @"CARequestRegisteredAppID";
static NSString * const kDMEAPIClientBaseUrl = @"DMEAPIClientBaseUrl";

@interface DMEGuestConsentManager()

@property (nonatomic, strong, readonly) CASession *session;
@property (nonatomic, strong, readonly) CASessionManager *sessionManager;
@property (nonatomic, copy, nullable) AuthorizationCompletionBlock guestConsentCompletionBlock;

@end

@implementation DMEGuestConsentManager

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
    return [action isEqualToString:@"guestConsent-return"];
}

- (void)handleAction:(DMEOpenAction *)action withParameters:(NSDictionary<NSString *,id> *)parameters
{
    NSError *err = [self.appCommunicator handleGuestConsentCallbackWithParameters:parameters];

    if (self.guestConsentCompletionBlock)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.guestConsentCompletionBlock(self.session, err);
        });
    }
}

- (void)requestGuestConsentWithBaseUrl:(NSString *)baseUrl withCompletion:(AuthorizationCompletionBlock)completion
{
    
    if (![NSThread currentThread].isMainThread)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestGuestConsentWithBaseUrl:baseUrl withCompletion:completion];
        });
        return;
    }
    
    if (![self.sessionManager isSessionValid])
    {
        completion(nil, nil);
        return;
    }
    
    self.guestConsentCompletionBlock = completion;
    
    NSDictionary *params = @{
                             kDMEAPIClientBaseUrl: baseUrl,
                             kCARequestSessionKey: self.session.sessionKey,
                             kCARequestRegisteredAppID: self.sessionManager.client.appId,
                             };
    
    [self.appCommunicator openBrowserWithParameters:params];
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
