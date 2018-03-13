//
//  DMERequestFactory.h
//  DigiMeSDK
//
//  Created on 30/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMERequestFactory : NSObject

/**
 -init unavailable. Use -initWithConfiguration:

 @return instancetype
 */
- (instancetype)init NS_UNAVAILABLE;


/**
 Designated object initializer

 @param configuration DMClientConfiguration
 @return instancetype
 */
- (instancetype)initWithConfiguration:(DMEClientConfiguration *)configuration NS_DESIGNATED_INITIALIZER;


/**
 Creates NSURLRequest for creating a new session.

 @param appId NSString
 @param contractId NSString
 @return NSURLRequest
 */
- (NSURLRequest *)sessionRequestWithAppId:(NSString *)appId contractId:(NSString *)contractId;


/**
 Creates NSURLRequest for fetching file list available for contract.

 @param sessionKey NSString
 @return NSURLRequest
 */
- (NSURLRequest *)fileListRequestWithSessionKey:(NSString *)sessionKey;


/**
 Creates NSURLRequest for fetching file content.

 @param fileId NSString
 @param sessionKey NSString
 @return NSURLRequest
 */
- (NSURLRequest *)fileRequestWithId:(NSString *)fileId sessionKey:(NSString *)sessionKey;


/**
 Base url used for all API calls. You can override this with DMEConfig.plist
 */
@property (nonatomic, strong, readonly) NSString *baseUrl;


/**
 DMEClientConfiguration object.
 */
@property (nonatomic, strong, readonly) DMEClientConfiguration *config;

@end

NS_ASSUME_NONNULL_END
