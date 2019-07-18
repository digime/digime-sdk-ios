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

NSString * const kCARequestSessionKey = @"CARequestSessionKey";
NSString * const kDMEResponse = @"CADigimeResponse";
NSString * const kCARequestRegisteredAppID = @"CARequestRegisteredAppID";
NSString * const kCARequestPostboxId = @"CARequestPostboxId";
NSString * const kCARequestPostboxPublicKey = @"CARequestPostboxPublicKey";
NSString * const kCARequest3dPartyAppName = @"CARequest3dPartyAppName";
NSString * const kTimingDataGetAllFiles = @"timingDataGetAllFiles";
NSString * const kTimingDataGetFile = @"timingDataGetFile";
NSString * const kTimingFetchContractPermission = @"timingFetchContractPermission";
NSString * const kTimingFetchDataGetAccount = @"timingFetchDataGetAccount";
NSString * const kTimingFetchDataGetFileList = @"timingFetchDataGetFileList";
NSString * const kTimingFetchSessionKey = @"timingFetchSessionKey";
NSString * const kDataRequest = @"timingDataRequest";
NSString * const kFetchContractDetails = @"timingFetchContractDetails";
NSString * const kUpdateContractPermission = @"timingUpdateContractPermission";
NSString * const kTimingTotal = @"timingTotal";
NSString * const kDebugAppId = @"debugAppId";
NSString * const kDebugBundleVersion = @"debugBundleVersion";
NSString * const kDebugPlatform = @"debugPlatform";
NSString * const kContractId = @"CARequestContractId";
NSString * const kContractType = @"debugContractType";
NSString * const kDeviceId = @"debugDeviceId";
NSString * const kDigiMeVersion = @"debugDigiMeVersion";
NSString * const kUserId = @"debugUserId";
NSString * const kLibraryId = @"debugLibraryId";
NSString * const kPCloudType = @"debugPCloudType";

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
