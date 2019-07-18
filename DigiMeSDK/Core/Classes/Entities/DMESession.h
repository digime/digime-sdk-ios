//
//  DMESession.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kCARequestSessionKey;
extern NSString * const kDMEResponse;
extern NSString * const kCARequestRegisteredAppID;
extern NSString * const kCARequestPostboxId;
extern NSString * const kCARequestPostboxPublicKey;
extern NSString * const kCARequest3dPartyAppName;
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

@class DMESessionManager;
@protocol DMEDataRequest;

@interface DMESession : NSObject

/**
 -init unavailable. Use -initWithSessionKey:expiryDate:sessionManager:
 
 @return instancetype
 */
- (instancetype)init NS_UNAVAILABLE;


/**
 Designated object initializer.
 
 @param sessionKey NSString
 @param exchangeToken NSString
 @param expiryDate NSDate
 @param sessionManager DMESessionManager
 @return instancetype
 */
- (instancetype)initWithSessionKey:(NSString *)sessionKey exchangeToken:(NSString *)exchangeToken expiryDate:(NSDate *)expiryDate sessionManager:(DMESessionManager *)sessionManager NS_DESIGNATED_INITIALIZER;


/**
 Session Key.
 */
@property (nonatomic, strong, readonly) NSString *sessionKey;

/**
 Session key exchange token.
 */
@property (nonatomic, strong, readonly) NSString *sessionExchangeToken;

/**
 Date when session will expire.
 */
@property (nonatomic, strong, readonly) NSDate *expiryDate;


/**
 Session manager attached to the session.
 */
@property (nonatomic, strong, readonly) DMESessionManager *sessionManager;


/**
 Date session was created.
 */
@property (nonatomic, strong, readonly) NSDate *createdDate;


/**
 Session Identifier - this is currently set to a contract identifier.
 */
@property (nonatomic, strong, readonly) NSString *sessionId;


/**
 Session Scope - this is the limiting scope object used to create session.
 */
@property (nonatomic, strong, readonly, nullable) id<DMEDataRequest> scope;


/**
 Session metadata. Contains additional debug information collected during the session lifetime.
 */
@property (strong, nonatomic, readonly, nonnull) NSDictionary<NSString *, id> *metadata;

@end

NS_ASSUME_NONNULL_END
