//
//  DMESession.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMESession+Private.h"
#import "DMESessionManager.h"
#import "DMEDataRequest.h"

NSString * const kDMESessionKey = @"sessionKey";
NSString * const kDMEResponse = @"result";
NSString * const kDMERegisteredAppID = @"appId";
NSString * const kDMEPostboxId = @"postboxId";
NSString * const kDMEPostboxPublicKey = @"publicKey";
NSString * const kDME3dPartyAppName = @"appName";
NSString * const kDMETimingDataGetAllFiles = @"timingGetAllFiles";
NSString * const kDMETimingDataGetFile = @"timingGetFile";
NSString * const kDMETimingFetchContractPermission = @"timingFetchContractPermission";
NSString * const kDMETimingFetchDataGetAccount = @"timingFetchAccount";
NSString * const kDMETimingFetchDataGetFileList = @"timingFetchFileList";
NSString * const kDMETimingFetchSessionKey = @"timingFetchSessionKey";
NSString * const kDMETimingRequestAuthorizationCode = @"timingRequestAuthorizationCode";
NSString * const kDMEDataRequest = @"timingDataRequest";
NSString * const kDMEFetchContractDetails = @"timingFetchContractDetails";
NSString * const kDMEUpdateContractPermission = @"timingUpdateContractPermission";
NSString * const kDMETimingTotal = @"timingTotal";
NSString * const kDMEDebugAppId = @"debugAppId";
NSString * const kDMEDebugBundleVersion = @"debugBundleVersion";
NSString * const kDMEDebugPlatform = @"debugPlatform";
NSString * const kDMEContractId = @"contractId";
NSString * const kDMEContractType = @"debugContractType";
NSString * const kDMEDeviceId = @"debugDeviceId";
NSString * const kDMEDigiMeVersion = @"debugDigiMeVersion";
NSString * const kDMEUserId = @"debugUserId";
NSString * const kDMELibraryId = @"debugLibraryId";
NSString * const kDMEPCloudType = @"debugPcloudType";
NSString * const kDMEResultValueSuccess = @"SUCCESS";
NSString * const kDMEResultValueError = @"ERROR";
NSString * const kDMEResultValueCancel = @"CANCEL";
NSString * const kDMEErrorReference = @"reference";
NSString * const kDMEPreAuthorizationCode = @"preAuthorizationCode";
NSString * const kDMEAuthorizationCode = @"authorizationCode";

@implementation DMESession

#pragma mark - Initialization

- (instancetype)initWithSessionKey:(NSString *)sessionKey exchangeToken:(NSString *)exchangeToken expiryDate:(NSDate *)expiryDate contractId:(NSString *)contractId sessionManager:(nonnull DMESessionManager *)sessionManager
{
    self = [super init];
    if (self)
    {
        _sessionKey = sessionKey;
        _sessionExchangeToken = exchangeToken;
        _expiryDate = expiryDate;
        _sessionManager = sessionManager;
        _sessionId = contractId;
        _createdDate = [NSDate date];
        _scope = sessionManager.scope;
        _metadata = [NSDictionary new];
    }
    
    return self;
}

@end
