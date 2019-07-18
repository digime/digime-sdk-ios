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

NSString * const kCARequestSessionKey = @"sessionKey";
NSString * const kDMEResponse = @"result";
NSString * const kCARequestRegisteredAppID = @"appId";
NSString * const kCARequestPostboxId = @"postboxId";
NSString * const kCARequestPostboxPublicKey = @"publicKey";
NSString * const kCARequest3dPartyAppName = @"appName";
NSString * const kTimingDataGetAllFiles = @"timingGetAllFiles";
NSString * const kTimingDataGetFile = @"timingGetFile";
NSString * const kTimingFetchContractPermission = @"timingFetchContractPermission";
NSString * const kTimingFetchDataGetAccount = @"timingFetchAccount";
NSString * const kTimingFetchDataGetFileList = @"timingFetchFileList";
NSString * const kTimingFetchSessionKey = @"timingFetchSessionKey";
NSString * const kDataRequest = @"timingDataRequest";
NSString * const kFetchContractDetails = @"timingFetchContractDetails";
NSString * const kUpdateContractPermission = @"timingUpdateContractPermission";
NSString * const kTimingTotal = @"timingTotal";
NSString * const kDebugAppId = @"debugAppId";
NSString * const kDebugBundleVersion = @"debugBundleVersion";
NSString * const kDebugPlatform = @"debugPlatform";
NSString * const kContractId = @"contractId";
NSString * const kContractType = @"debugContractType";
NSString * const kDeviceId = @"debugDeviceId";
NSString * const kDigiMeVersion = @"debugDigiMeVersion";
NSString * const kUserId = @"debugUserId";
NSString * const kLibraryId = @"debugLibraryId";
NSString * const kPCloudType = @"debugPcloudType";

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
