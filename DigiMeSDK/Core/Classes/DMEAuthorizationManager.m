//
//  DMEAuthorizationManager.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEAuthorizationManager.h"
#import "DMESessionManager.h"
#import "CASession+Private.h"
#import "DMEClient.h"

#import "NSError+Auth.h"
#import "UIViewController+DMEExtension.h"

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface DMEAuthorizationManager()

@property (nonatomic, strong, readonly) CASession *session;
@property (nonatomic, strong, readonly) DMESessionManager *sessionManager;
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

-(DMESessionManager *)sessionManager
{
    return [DMEClient sharedClient].sessionManager;
}

-(void)filterMetadata:(NSDictionary<NSString *,id> *)metadata
{
    // default legacy keys
    NSMutableArray *allowedKeys = @[kCARequestSessionKey, kCADigimeResponse, kCARequestRegisteredAppID].mutableCopy;
    // timing keys
    [allowedKeys addObjectsFromArray:@[kTimingDataGetAllFiles, kTimingDataGetFile, kTimingFetchContractPermission, kTimingFetchDataGetAccount, kTimingFetchDataGetFileList, kTimingFetchSessionKey, kDataRequest, kFetchContractDetails, kUpdateContractPermission, kTimingTotal]];
    // timing debug keys
    [allowedKeys addObjectsFromArray:@[kDebugAppId, kDebugBundleVersion, kDebugPlatform, kContractType, kDeviceId, kDigiMeVersion, kUserId, kLibraryId, kPCloudType, kContractId, kCARequest3dPartyAppName]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self IN %@", allowedKeys];
    NSDictionary *whiteDictionary = [metadata dictionaryWithValuesForKeys:[metadata.allKeys filteredArrayUsingPredicate:predicate]];
    self.session.metadata = whiteDictionary;
}

@end
