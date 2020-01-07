//
//  DMEAPIClient.h
//  DigiMeSDK
//
//  Created on 26/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientConfiguration.h"

NS_ASSUME_NONNULL_BEGIN
@protocol DMEDataRequest;

@protocol DMEAPIClientDelegate <NSObject>

@optional
- (void)didFinishAllDownloads;

@end

@interface DMEAPIClient : NSObject

/**
 Base url used for all API calls.
 */
@property (nonatomic, strong, readonly) NSString *baseUrl;

@property (nonatomic, weak, nullable) id<DMEAPIClientDelegate> delegate;

@property (nonatomic, readonly) BOOL isDownloadingFiles;

/**
 -init unavailable. Use -initWithConfig:

 @return instancetype
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Designated object initializer.

 @param configuration DMEClientConfiguration
 @return instancetype
 */
- (instancetype)initWithConfiguration:(id<DMEClientConfiguration>)configuration NS_DESIGNATED_INITIALIZER;


/**
 Initiates session key request.

 @param scope optional DMEDataRequest scope filter
 @param success completion block receiving NSData
 @param failure failure block receiving NSError
 */
- (void)requestSessionWithScope:(nullable id<DMEDataRequest>)scope success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;

/**
Initiates pre-authentication code request.

@param jwtBearer Signed PS512 JSON Web Token to request preauthentication code
@param success completion block receiving NSData
@param failure failure block receiving NSError
*/
- (void)requestPreauthenticationCodeWithBearer:(NSString *)jwtBearer success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;

/**
Request to get digi.me public key to verify pre-auth JWT token

@param success completion block receiving NSData
@param failure failure block receiving NSError
*/
- (void)requestValidationDataForPreauthenticationCodeWithSuccess:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;

/**
Initiates authentication code request.

@param jwtBearer Signed PS512 JSON Web Token to request access and refresh tokens
@param success completion block receiving NSData
@param failure failure block receiving NSError
*/
- (void)requestAuthenticationAndRefreshTokensWithBearer:(NSString *)jwtBearer success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;

/**
To access to the protected resources that are available using the issued access token.

@param jwtBearer Signed PS512 JSON Web Token to request renewal for access and refresh tokens
@param success completion block receiving NSData
@param failure failure block receiving NSError
*/
- (void)requestDataTriggerWithBearer:(NSString *)jwtBearer success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;

/**
 When the access token is detected as expired or invalid, the third party client app uses the refresh token to generate a new access token (accompanied with a new refresh token).
 
 @param jwtBearer Signed PS512 JSON Web Token to request renewal for access and refresh tokens
 @param success completion block receiving NSData
 @param failure failure block receiving NSError
 */
- (void)renewAccessTokenWithBearer:(NSString *)jwtBearer success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;

/**
 Initiates file list request.

 @param sessionKey key for session request relates to
 @param success completion block receiving NSData
 @param failure failure block receiving NSError
 */
- (void)requestFileListForSessionWithKey:(NSString *)sessionKey success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;


/**
 Initiates file request for a fileId. Note: this will add the request to an internal queue.

 @param fileId The identifier of the file to retrieve
 @param sessionKey key for session request relates to
 @param success completion block receiving NSData
 @param failure failure block receiving NSError
 */
- (void)requestFileWithId:(NSString *)fileId sessionKey:(NSString *)sessionKey success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;

/**
 Cancels and clears download queue.
 */
- (void)cancelQueuedDownloads;

@end

NS_ASSUME_NONNULL_END
