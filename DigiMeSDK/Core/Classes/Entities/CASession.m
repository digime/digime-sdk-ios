//
//  CASession.m
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "CASession.h"
#import "CASessionManager.h"
#import "DMEClient.h"
#import "CADataRequest.h"

NSString * const kCARequestSessionKey = @"CARequestSessionKey";
NSString * const kCADigimeResponse = @"CADigimeResponse";
NSString * const kCARequestRegisteredAppID = @"CARequestRegisteredAppID";
NSString * const kCARequestPostboxId = @"CARequestPostboxId";
NSString * const kCARequestPostboxPublicKey = @"CARequestPostboxPublicKey";

NSString * const kContractId = @"CARequestContractId";

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
NSString * const kContractType = @"debugContractType";
NSString * const kDeviceId = @"debugDeviceId";
NSString * const kDigiMeVersion = @"debugDigiMeVersion";
NSString * const kUserId = @"debugUserId";
NSString * const kLibraryId = @"debugLibraryId";
NSString * const kPCloudType = @"debugPCloudType";

@interface CASession()
@property (nonatomic, strong) NSDictionary<NSString *, id> *metadata;
@end

@implementation CASession

#pragma mark - Initialization

-(instancetype)initWithSessionKey:(NSString *)sessionKey expiryDate:(NSDate *)expiryDate sessionManager:(nonnull CASessionManager *)sessionManager
{
    self = [super init];
    if (self)
    {
        _sessionKey = sessionKey;
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
