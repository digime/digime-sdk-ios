//
//  DMEClient+Private.h
//  DigiMeSDK
//
//  Created on 16/10/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEAPIClient.h"

@class NSOperationQueue, DMECrypto, DMECertificatePinner, DMEClient, DMERequestFactory;

typedef void(^HandlerBlock)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface DMEAPIClient ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) DMECrypto *crypto;
@property (nonatomic, strong) DMECertificatePinner *certPinner;
@property (nonatomic, strong) DMEClient *client;
@property (nonatomic, strong) DMERequestFactory *requestFactory;

- (NSURLSession *)sessionWithHeaders:(NSDictionary *)headers;
- (HandlerBlock)defaultResponseHandlerForDomain:(NSString *)domain success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
