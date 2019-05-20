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
@protocol CADataRequest;

@interface DMEAPIClient : NSObject


/**
 -init unavailable. Use -initWithConfig:

 @return instancetype
 */
- (instancetype)init NS_UNAVAILABLE;


/**
 Designated object initializer.

 @param config DMEClientConfiguration
 @return instancetype
 */
- (instancetype)initWithConfig:(DMEClientConfiguration *)config NS_DESIGNATED_INITIALIZER;


/**
 Initiates session key request.

 @param scope optional CADataRequest scope filter
 @param success completion block receiving NSData
 @param failure failure block receiving NSError
 */
- (void)requestSessionWithScope:(nullable id<CADataRequest>)scope success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;


/**
 Initiates file list request.

 @param success completion block receiving NSData
 @param failure failure block receiving NSError
 */
- (void)requestFileListWithSuccess:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;


/**
 Initiates file request for a fileId. Note: this will add the request to an internal queue.

 @param fileId NSString
 @param success completion block receiving NSData
 @param failure failure block receiving NSError
 */
- (void)requestFileWithId:(NSString *)fileId success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;

/**
 Push data to Postbox, to a user's library.
 
 @param postboxId NSString
 @param sessionKey NSString
 @param publicKey NSString
 @param metadata NSData
 @param data NSData
 @param completion PostboxDataPushCompletionBlock
 */
- (void)pushDataToPostboxWithPostboxId:(NSString *)postboxId
                            sessionKey:(NSString *)sessionKey
                   postboxRSAPublicKey:(NSString *)publicKey
                        metadataToPush:(NSData *)metadata
                            dataToPush:(NSData *)data
                            completion:(void(^)(NSError * _Nullable error))completion;

/**
 DMEClientConfiguration object set on the DMEClient. This should not be modified directly.
 */
@property (nonatomic, strong) DMEClientConfiguration *config;

/**
 Base url used for all API calls.
 */
@property (nonatomic, strong, readonly) NSString *baseUrl;

@end

NS_ASSUME_NONNULL_END
