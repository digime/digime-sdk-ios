//
//  DMENativeConsentManager.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMENativeConsentManager.h"
#import "DMESessionManager.h"
#import "DMESession+Private.h"

#import "NSError+Auth.h"

@interface DMENativeConsentManager()

@property (nonatomic, strong, readonly) DMESession *session;
@property (nonatomic, strong, readonly) DMESessionManager *sessionManager;
@property (nonatomic, weak, readonly) DMEAppCommunicator *appCommunicator;
@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, nullable) DMEAuthorizationCompletion authCompletionBlock;

@end

@implementation DMENativeConsentManager

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
    return [action isEqualToString:@"data"];
}

- (void)handleAction:(DMEOpenAction *)action withParameters:(NSDictionary<NSString *,id> *)parameters
{
    BOOL result = [parameters[kDMEResponse] boolValue];
    NSString *sessionKey = parameters[kDMESessionKey];
    
    [self filterMetadata: parameters];
    
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
    
    [self.appCommunicator removeCallbackHandler:self];
}

#pragma mark - Authorization

- (void)beginAuthorizationWithCompletion:(DMEAuthorizationCompletion)completion
{
    if (![self.sessionManager isSessionValid])
    {
        completion(nil, [NSError authError:AuthErrorInvalidSession]);
        return;
    }
    
    self.authCompletionBlock = completion;
    
    DMEOpenAction *action = @"data";
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
    // default legacy keys
    NSMutableArray *allowedKeys = @[kDMESessionKey, kDMEResponse, kDMERegisteredAppID].mutableCopy;
    // timing keys
    [allowedKeys addObjectsFromArray:@[kDMETimingDataGetAllFiles, kDMETimingDataGetFile, kDMETimingFetchContractPermission, kDMETimingFetchDataGetAccount, kDMETimingFetchDataGetFileList, kDMETimingFetchSessionKey, kDMEDataRequest, kDMEFetchContractDetails, kDMEUpdateContractPermission, kDMETimingTotal]];
    // timing debug keys
    [allowedKeys addObjectsFromArray:@[kDMEDebugAppId, kDMEDebugBundleVersion, kDMEDebugPlatform, kDMEContractType, kDMEDeviceId, kDMEDigiMeVersion, kDMEUserId, kDMELibraryId, kDMEPCloudType, kDMEContractId, kDME3dPartyAppName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self IN %@", allowedKeys];
    NSDictionary *whiteDictionary = [metadata dictionaryWithValuesForKeys:[metadata.allKeys filteredArrayUsingPredicate:predicate]];
    self.session.metadata = whiteDictionary;
}

@end
