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

@interface DMEAPIClient : NSObject

/**
 Base url used for all API calls.
 */
@property (nonatomic, strong, readonly) NSString *baseUrl;

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

@end

NS_ASSUME_NONNULL_END
