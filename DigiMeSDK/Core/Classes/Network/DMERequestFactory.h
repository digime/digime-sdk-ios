//
//  DMERequestFactory.h
//  DigiMeSDK
//
//  Created on 30/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DMEClientConfiguration;
@protocol DMEDataRequest;

NS_ASSUME_NONNULL_BEGIN

@interface DMERequestFactory : NSObject

/**
 -init unavailable. Use -initWithConfiguration:

 @return instancetype
 */
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;


/**
 Designated object initializer

 @param configuration DMClientConfiguration
 @return instancetype
 */
- (instancetype)initWithConfiguration:(id<DMEClientConfiguration>)configuration NS_DESIGNATED_INITIALIZER;


/**
 Creates NSURLRequest for creating a new session.
 
 @param appId NSString
 @param contractId NSString
 @param scope id<DataRequest>
 @return NSURLRequest
 */
- (NSURLRequest *)sessionRequestWithAppId:(NSString *)appId contractId:(NSString *)contractId scope:(nullable id<DMEDataRequest>)scope;


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
 Creates NSURLRequest for pushing data content.
 
 @param postboxId NSString
 @param data NSData - payload to push to Postbox
 @param jwtBearer NSString - signed JSON Web Token
 @return NSURLRequest
 */
- (NSURLRequest *)pushRequestWithPostboxId:(NSString *)postboxId payload:(NSData *)data bearer:(NSString *)jwtBearer;

/**
Creates NSURLRequest for acquiring a pre-authentication code.

@param jwtBearer NSString - signed JSON Web Token
@return NSURLRequest
*/
- (NSURLRequest *)preAuthRequestWithBearer:(NSString *)jwtBearer;

/**
Creates NSURLRequest for validating pre-authentication code.

@return NSURLRequest
*/
- (NSURLRequest *)preAuthValidationRequest;

/**
Creates NSURLRequest for acquiring an authentication code.

@param jwtBearer NSString - signed JSON Web Token
@return NSURLRequest
*/
- (NSURLRequest *)authRequestWithBearer:(NSString *)jwtBearer;

/**
Creates NSURLRequest for triggering data (this makes protected resources associated with the JWT available for retrieval).

@param jwtBearer NSString - signed JSON Web Token
@return NSURLRequest
*/
- (NSURLRequest *)dataTriggerRequestWithBearer:(NSString *)jwtBearer;

/**
 Base url used for all API calls.
 */
@property (nonatomic, strong, readonly) NSString *baseUrl;

/**
 DMEClientConfiguration object.
 */
@property (nonatomic, strong, readonly) id<DMEClientConfiguration> config;

@end

NS_ASSUME_NONNULL_END
