//
//  DMEAPIClient+Private.h
//  DigiMeSDK
//
//  Created on 24/05/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEAPIClient.h"

@class NSOperationQueue, DMECertificatePinner, DMERequestFactory;

typedef void(^HandlerBlock)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface DMEAPIClient ()

@property (nonatomic, strong, readonly) NSOperationQueue *queue;
@property (nonatomic, strong, readonly) DMERequestFactory *requestFactory;
@property (nonatomic, strong, readonly) id<DMEClientConfiguration> configuration;


- (NSURLSession *)sessionWithHeaders:(NSDictionary *)headers;
- (HandlerBlock)defaultResponseHandlerForDomain:(NSString *)domain success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
