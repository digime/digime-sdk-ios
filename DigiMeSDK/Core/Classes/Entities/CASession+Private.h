//
//  CASession+Private.h
//  DigiMeSDK
//
//  Created on 21/01/2019.
//

#import "CASession.h"

extern NSString * const kCARequestSessionKey;
extern NSString * const kCADigimeResponse;
extern NSString * const kCARequestRegisteredAppID;
extern NSString * const kCARequestPostboxId;
extern NSString * const kCARequestPostboxPublicKey;
extern NSString * const kCARequestRegisteredAppID;
extern NSString * const kTimingDataGetAllFiles;
extern NSString * const kTimingDataGetFile;
extern NSString * const kTimingFetchContractPermission;
extern NSString * const kTimingFetchDataGetAccount;
extern NSString * const kTimingFetchDataGetFileList;
extern NSString * const kTimingFetchSessionKey;
extern NSString * const kTimingTotal;
extern NSString * const kDataRequest;
extern NSString * const kFetchContractDetails;
extern NSString * const kUpdateContractPermission;
extern NSString * const kDebugAppId;
extern NSString * const kDebugBundleVersion;
extern NSString * const kDebugPlatform;
extern NSString * const kContractId;
extern NSString * const kContractType;
extern NSString * const kDeviceId;
extern NSString * const kDigiMeVersion;
extern NSString * const kUserId;
extern NSString * const kLibraryId;
extern NSString * const kPCloudType;

@interface CASession()

@property (strong, nonatomic) NSDictionary<NSString *, id> *metadata;

@end
