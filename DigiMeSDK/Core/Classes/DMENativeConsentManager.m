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
#import "DMEClient.h"

#import "NSError+Auth.h"
#import "UIViewController+DMEExtension.h"

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface DMENativeConsentManager()

@property (nonatomic, strong, readonly) DMESession *session;
@property (nonatomic, strong, readonly) DMESessionManager *sessionManager;
@property (nonatomic, copy, nullable) DMEAuthorizationCompletion authCompletionBlock;

@end

@implementation DMENativeConsentManager

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
    NSString *result = parameters[kDMEResponse];
    NSString *sessionKey = parameters[kDMESessionKey];
    
    [self filterMetadata: parameters];
    
    NSError *err;
    
    if(![self.sessionManager isSessionKeyValid:sessionKey])
    {
        err = [NSError authError:AuthErrorInvalidSessionKey];
    }
    else if ([result isEqualToString:kDMEResultValueCancel])
    {
        err = [NSError authError:AuthErrorCancelled];
    }
    else if ([result isEqualToString:kDMEResultValueError])
    {
        err = [NSError authError:AuthErrorGeneral];
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
                             kDMERegisteredAppID: self.sessionManager.client.appId,
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
