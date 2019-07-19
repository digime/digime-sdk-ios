//
//  DMESession.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMESession.h"
#import "DMESessionManager.h"
#import "DMEClient.h"
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

@interface DMESession()
@property (nonatomic, strong) NSDictionary<NSString *, id> *metadata;
@end

@implementation DMESession

#pragma mark - Initialization

-(instancetype)initWithSessionKey:(NSString *)sessionKey exchangeToken:(NSString *)exchangeToken expiryDate:(NSDate *)expiryDate sessionManager:(nonnull DMESessionManager *)sessionManager
{
    self = [super init];
    if (self)
    {
        _sessionKey = sessionKey;
        _sessionExchangeToken = exchangeToken;
        _expiryDate = expiryDate;
        _sessionManager = sessionManager;
        _sessionId = sessionManager.client.contractId;
        _createdDate = [NSDate date];
        _scope = sessionManager.scope;
        _metadata = [NSDictionary new];
    }
    
    return self;
}

@end
