//
//  DMESession.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kDMESessionKey;
extern NSString * const kDMEResponse;
extern NSString * const kDMERegisteredAppID;
extern NSString * const kDMEPostboxId;
extern NSString * const kDMEPostboxPublicKey;
extern NSString * const kDME3dPartyAppName;
extern NSString * const kDMETimingDataGetAllFiles;
extern NSString * const kDMETimingDataGetFile;
extern NSString * const kDMETimingFetchContractPermission;
extern NSString * const kDMETimingFetchDataGetAccount;
extern NSString * const kDMETimingFetchDataGetFileList;
extern NSString * const kDMETimingFetchSessionKey;
extern NSString * const kDMETimingTotal;
extern NSString * const kDMEDataRequest;
extern NSString * const kDMEFetchContractDetails;
extern NSString * const kDMEUpdateContractPermission;
extern NSString * const kDMEDebugAppId;
extern NSString * const kDMEDebugBundleVersion;
extern NSString * const kDMEDebugPlatform;
extern NSString * const kDMEContractId;
extern NSString * const kDMEContractType;
extern NSString * const kDMEDeviceId;
extern NSString * const kDMEDigiMeVersion;
extern NSString * const kDMEUserId;
extern NSString * const kDMELibraryId;
extern NSString * const kDMEPCloudType;

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
@property (nonatomic, weak, readonly) DMESessionManager *sessionManager;


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
