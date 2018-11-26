//
//  DMEQuarkManager.m
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 me.digi. All rights reserved.
//

#import "DMEQuarkManager.h"
#import "CASessionManager.h"
#import "DMEClient.h"
#import "DMEAppCommunicator+Quark.h"

static NSString * const kCADigimeResponse = @"CADigimeResponse";
static NSString * const kCARequestSessionKey = @"CARequestSessionKey";
static NSString * const kCARequestRegisteredAppID = @"CARequestRegisteredAppID";
static NSString * const kDMEAPIClientBaseUrl = @"DMEAPIClientBaseUrl";

@interface DMEQuarkManager()

@property (nonatomic, strong, readonly) CASession *session;
@property (nonatomic, strong, readonly) CASessionManager *sessionManager;
@property (nonatomic, copy, nullable) AuthorizationCompletionBlock quarkCompletionBlock;

@end

@implementation DMEQuarkManager

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
    return [action isEqualToString:@"quark-return"];
}

- (void)handleAction:(DMEOpenAction *)action withParameters:(NSDictionary<NSString *,id> *)parameters
{
    NSError *err = [self.appCommunicator handleQuarkCallbackWithParameters:parameters];

    if (self.quarkCompletionBlock)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.quarkCompletionBlock(self.session, err);
        });
    }
}

- (void)requestQuarkWithBaseUrl:(NSString *)baseUrl withCompletion:(AuthorizationCompletionBlock)completion
{
    
    if (![NSThread currentThread].isMainThread)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestQuarkWithBaseUrl:baseUrl withCompletion:completion];
        });
        return;
    }
    
    if (![self.sessionManager isSessionValid])
    {
        completion(nil, nil);
        return;
    }
    
    self.quarkCompletionBlock = completion;
    
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
