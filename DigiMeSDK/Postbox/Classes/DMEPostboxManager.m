//
//  DMEPostboxManager.m
//  DigiMeSDK
//
//  Created on 26/06/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEPostboxManager.h"
#import "DMESessionManager.h"
#import "DMEClient.h"
#import "DMEPostbox.h"
#import "DMESession+Private.h"

@interface DMEPostboxManager()

@property (nonatomic, strong, readonly) DMESession *session;
@property (nonatomic, strong, readonly) DMESessionManager *sessionManager;
@property (nonatomic, copy, nullable) PostboxCreationCompletionBlock postboxCompletionBlock;

@end

@implementation DMEPostboxManager

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
    return [action isEqualToString:@"postbox"];
}

- (void)handleAction:(DMEOpenAction *)action withParameters:(NSDictionary<NSString *,id> *)parameters
{
    BOOL success = [parameters[kDMEResponse] boolValue];
    NSString *sessionKey = parameters[kCARequestSessionKey];
    NSString *postboxId = parameters[kCARequestPostboxId];
    NSString *postboxPublicKey = parameters[kCARequestPostboxPublicKey];
    
    [self filterMetadata: parameters];
    
    NSError *err;
    DMEPostbox *postbox;
    
    if (![self.sessionManager isSessionKeyValid:sessionKey])
    {
        err = [NSError authError:AuthErrorInvalidSessionKey];
    }
    else if (!success || !postboxId.length)
    {
        err = [NSError authError:AuthErrorGeneral];
    }
    else
    {
        postbox = [[DMEPostbox alloc] initWithSessionKey:sessionKey andPostboxId:postboxId];
        postbox.postboxRSAPublicKey = postboxPublicKey;
    }
    
    if (self.postboxCompletionBlock)
    {
        // Need to know if we succeeded.
        dispatch_async(dispatch_get_main_queue(), ^{
            self.postboxCompletionBlock(postbox, err);
        });
    }
}

- (void)requestPostboxWithCompletion:(PostboxCreationCompletionBlock)completion
{
    if (![NSThread currentThread].isMainThread)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestPostboxWithCompletion:completion];
        });
        return;
    }
    
    if (![self.sessionManager isSessionValid])
    {
        completion(nil, nil);
        return;
    }
    
    self.postboxCompletionBlock = completion;
    
    DMEOpenAction *action = @"postbox";
    NSDictionary *params = @{
                             kCARequestSessionKey: self.session.sessionKey,
                             kCARequestRegisteredAppID: self.sessionManager.client.appId,
                             };
    
    [self.appCommunicator openDigiMeAppWithAction:action parameters:params];
}

#pragma mark - Convenience

- (DMESession *)session
{
    return self.sessionManager.currentSession;
}

- (DMESessionManager *)sessionManager
{
    return [DMEClient sharedClient].sessionManager;
}

- (void)filterMetadata:(NSDictionary<NSString *,id> *)metadata
{
    NSMutableArray *allowedKeys = @[kDMEResponse, kCARequestSessionKey, kCARequestPostboxId, kCARequestPostboxPublicKey, kCARequestRegisteredAppID].mutableCopy;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self IN %@", allowedKeys];
    NSDictionary *whiteDictionary = [metadata dictionaryWithValuesForKeys:[metadata.allKeys filteredArrayUsingPredicate:predicate]];
    self.session.metadata = whiteDictionary;
}

@end
