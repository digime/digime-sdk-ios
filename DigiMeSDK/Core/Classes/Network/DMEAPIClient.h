//
//  DMEAPIClient.h
//  DigiMeSDK
//
//  Created on 26/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientConfiguration.h"
#import "DMEClientCallbacks.h"

NS_ASSUME_NONNULL_BEGIN

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

 @param success completion block receiving NSData
 @param failure failure block receiving NSError
 */
- (void)requestSessionWithSuccess:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;


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
 DMEClientConfiguration object set on the DMEClient. This should not be modified directly.
 */
@property (nonatomic, strong) DMEClientConfiguration *config;

@end

NS_ASSUME_NONNULL_END
