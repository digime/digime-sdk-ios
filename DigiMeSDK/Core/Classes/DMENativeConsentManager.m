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
@property (nonatomic, copy, nullable) DMEOngoingAccessAuthCodeExchangeCompletion ongoingAccessAuthCompletionBlock;

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
    NSString *result = parameters[kDMEResponse];
    NSString *sessionKey = parameters[kDMESessionKey];
    NSString *reference = parameters[kDMEErrorReference];
    NSString *authorizationCode = parameters[kDMEAuthorizationCode];
    
    [self filterMetadata: parameters];
    
    NSError *error;
    
    if(![self.sessionManager isSessionKeyValid:sessionKey])
    {
        error = [NSError authError:AuthErrorInvalidSessionKey];
    }
    else if ([result isEqualToString:kDMEResultValueCancel])
    {
        error = [NSError authError:AuthErrorCancelled];
    }
    else if ([result isEqualToString:kDMEResultValueError])
    {
        error = [NSError authError:AuthErrorGeneral reference:reference];
    }
    
    if (self.authCompletionBlock)
    {
        // Need to know if we succeeded.
        DMESession *session = error == nil ? self.session : nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.authCompletionBlock(session, error);
        });
    }
    else if (self.ongoingAccessAuthCompletionBlock)
    {
        // Need to know if we succeeded.
        DMESession *session = error == nil ? self.session : nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ongoingAccessAuthCompletionBlock(session, authorizationCode, error);
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

- (void)beginOngoingAccessAuthorizationWithPreAuthCode:(NSString *)preAuthorizationCode completion:(DMEOngoingAccessAuthCodeExchangeCompletion)completion
{
    if (![self.sessionManager isSessionValid])
    {
        completion(nil, nil, [NSError authError:AuthErrorInvalidSession]);
        return;
    }
    
    self.ongoingAccessAuthCompletionBlock = completion;
    
    DMEOpenAction *action = @"authorize";
    NSDictionary *params = @{
                             kDMESessionKey: self.session.sessionKey,
                             kDMERegisteredAppID: self.appId,
                             kDMEPreAuthorizationCode: preAuthorizationCode,
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
    [allowedKeys addObjectsFromArray:@[kDMETimingDataGetAllFiles, kDMETimingDataGetFile, kDMETimingFetchContractPermission, kDMETimingFetchDataGetAccount, kDMETimingFetchDataGetFileList, kDMETimingFetchSessionKey, kDMEDataRequest, kDMEFetchContractDetails, kDMEUpdateContractPermission, kDMETimingTotal, kDMETimingRequestAuthorizationCode]];
    // timing debug keys
    [allowedKeys addObjectsFromArray:@[kDMEDebugAppId, kDMEDebugBundleVersion, kDMEDebugPlatform, kDMEContractType, kDMEDeviceId, kDMEDigiMeVersion, kDMEUserId, kDMELibraryId, kDMEPCloudType, kDMEContractId, kDME3dPartyAppName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self IN %@", allowedKeys];
    NSDictionary *whiteDictionary = [metadata dictionaryWithValuesForKeys:[metadata.allKeys filteredArrayUsingPredicate:predicate]];
    self.session.metadata = whiteDictionary;
}

@end
