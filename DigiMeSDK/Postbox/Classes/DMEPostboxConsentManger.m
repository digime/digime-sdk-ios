//
//  DMEPostboxConsentManger.m
//  DigiMeSDK
//
//  Created on 26/06/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEPostboxConsentManger.h"
#import "DMESessionManager.h"
#import "DMEClient.h"
#import "DMEPostbox.h"
#import "DMESession+Private.h"

@interface DMEPostboxConsentManger()

@property (nonatomic, strong, readonly) DMESession *session;
@property (nonatomic, strong, readonly) DMESessionManager *sessionManager;
@property (nonatomic, weak, readonly) DMEAppCommunicator *appCommunicator;
@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, nullable) DMEPostboxCreationCompletion postboxCompletionBlock;

@end

@implementation DMEPostboxConsentManger

- (instancetype)initWithSessionManager:(DMESessionManager *)sessionManager appId:(NSString *)appId
{
    self = [super init];
    if (self)
    {
        _appCommunicator = [DMEAppCommunicator shared];
        _sessionManager = sessionManager;
        _appId = appId;
    }
    
    return self;
}

#pragma mark - DMEAppCallbackHandler Conformance

- (BOOL)canHandleAction:(DMEOpenAction *)action
{
    return [action isEqualToString:@"postbox"];
}

- (void)handleAction:(DMEOpenAction *)action withParameters:(NSDictionary<NSString *,id> *)parameters
{
    NSString *result = parameters[kDMEResponse];
    NSString *sessionKey = parameters[kDMESessionKey];
    NSString *postboxId = parameters[kDMEPostboxId];
    NSString *postboxPublicKey = parameters[kDMEPostboxPublicKey];
    
    [self filterMetadata: parameters];
    
    NSError *err;
    DMEPostbox *postbox;
    
    if (![self.sessionManager isSessionKeyValid:sessionKey])
    {
        err = [NSError authError:AuthErrorInvalidSessionKey];
    }
    else if ([result isEqualToString:kDMEResultValueCancel])
    {
        err = [NSError authError:AuthErrorCancelled];
    }
    else if ([result isEqualToString:kDMEResultValueError] || !postboxId.length)
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
    
    [self.appCommunicator removeCallbackHandler:self];
}

- (void)requestPostboxWithCompletion:(DMEPostboxCreationCompletion)completion
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
                             kDMESessionKey: self.session.sessionKey,
                             kDMERegisteredAppID: self.appId,
                             };
    
    [self.appCommunicator addCallbackHandler:self];
    [self.appCommunicator openDigiMeAppWithAction:action parameters:params];
}

#pragma mark - Convenience

- (DMESession *)session
{
    return self.sessionManager.currentSession;
}

- (void)filterMetadata:(NSDictionary<NSString *,id> *)metadata
{
    NSMutableArray *allowedKeys = @[kDMEResponse, kDMESessionKey, kDMEPostboxId, kDMEPostboxPublicKey, kDMERegisteredAppID].mutableCopy;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self IN %@", allowedKeys];
    NSDictionary *whiteDictionary = [metadata dictionaryWithValuesForKeys:[metadata.allKeys filteredArrayUsingPredicate:predicate]];
    self.session.metadata = whiteDictionary;
}

@end
