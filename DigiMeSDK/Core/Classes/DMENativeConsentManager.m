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
@property (nonatomic, copy, nullable) DMEOngoingAccessAuthCodeExchangeCompletion ongoingAccessExchangeCompletionBlock;

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
    return [action isEqualToString:@"data"] || [action isEqualToString:@"authorize"];
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
            self.authCompletionBlock = nil;
        });
    }
    else if (self.ongoingAccessExchangeCompletionBlock)
    {
        // Need to know if we succeeded.
        DMESession *session = error == nil ? self.session : nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ongoingAccessExchangeCompletionBlock(session, authorizationCode, error);
            self.ongoingAccessExchangeCompletionBlock = nil;
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
                             kDMECallbackUrl: [self callbackUrlString],
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
    
    self.ongoingAccessExchangeCompletionBlock = completion;
    
    DMEOpenAction *action = @"authorize";
    NSDictionary *params = @{
                             kDMECallbackUrl: [self callbackUrlString],
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
    // default keys
    NSMutableArray *allowedKeys = @[kDMESessionKey, kDMEResponse, kDMERegisteredAppID, kDMEDigiMeVersion].mutableCopy;
    // timing keys
    [allowedKeys addObjectsFromArray:@[kDMETimingDataGetAllFiles, kDMETimingDataGetFile, kDMETimingFetchContractPermission, kDMETimingFetchDataGetAccount, kDMETimingFetchDataGetFileList, kDMETimingFetchSessionKey, kDMEDataRequest, kDMEFetchContractDetails, kDMEUpdateContractPermission, kDMETimingTotal, kDMETimingRequestAuthorizationCode]];
    // timing debug keys
    [allowedKeys addObjectsFromArray:@[kDMEDebugAppId, kDMEDebugBundleVersion, kDMEDebugPlatform, kDMEContractType, kDMEDeviceId, kDMEDigiMeVersion, kDMEUserId, kDMELibraryId, kDMEPCloudType, kDMEContractId, kDME3dPartyAppName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self IN %@", allowedKeys];
    NSDictionary *whiteDictionary = [metadata dictionaryWithValuesForKeys:[metadata.allKeys filteredArrayUsingPredicate:predicate]];
    self.session.metadata = whiteDictionary;
}

- (NSString *)callbackUrlString
{
    NSURLComponents *domainComponents = [NSURLComponents new];
    domainComponents.scheme = [NSString stringWithFormat:@"%@%@", kDMEClientSchemePrefix, self.appId];
    domainComponents.host = @"data";
    NSDictionary *callbackParams = @{
                             kDMESessionKey: self.session.sessionKey,
                             kDMERegisteredAppID: self.appId,
                             };
    NSURLComponents *callbackComponents = [NSURLComponents componentsWithURL:domainComponents.URL resolvingAgainstBaseURL:NO];
    NSMutableArray *newQueryItems = [NSMutableArray arrayWithArray:callbackComponents.queryItems] ?: [NSMutableArray array];
    [callbackParams enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [newQueryItems addObject:[NSURLQueryItem queryItemWithName:key value:obj]];
    }];
    callbackComponents.queryItems = newQueryItems;
    NSURL *callbackURL = callbackComponents.URL;
    return [callbackURL absoluteString];
}

@end
