//
//  DMEAPIClient+Postbox.m
//  DigiMeSDK
//
//  Created on 23/05/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//


#import "DMEOperation.h"
#import "DMEClient.h"
#import "DMECrypto.h"
#import "DMERequestFactory.h"
#import "DMEPostbox.h"

#import "NSString+DMECrypto.h"
#import "NSData+DMECrypto.h"
#import "DMEAPIClient+Postbox.h"

#import "DMEClient+Private.h"
#import "DMEAPIClient+Private.h"

@implementation DMEAPIClient (Postbox)

#pragma mark - Data Push

- (void)pushDataToPostbox:(DMEPostbox *)postbox
                 metadata:(NSData *)metadata
                     data:(NSData *)data
               completion:(DMEPostboxDataPushCompletion)completion
{
    DMEOperation *operation = [[DMEOperation alloc] initWithConfiguration:self.configuration];
    
    __weak __typeof(DMEOperation *) weakOperation = operation;
    
    operation.workBlock = ^{
        
        NSData *symmetricalKey = [DMECrypto getRandomUnsignedCharacters:32];
        NSData *iv = [DMECrypto getRandomUnsignedCharacters:16];
        NSString *metadataEncryptedString = [DMECrypto encryptMetadata:metadata symmetricalKey:symmetricalKey initializationVector:iv];
        NSData *payload = [DMECrypto encryptData:data symmetricalKey:symmetricalKey initializationVector:iv];
        NSString *keyEncrypted = [DMECrypto encryptSymmetricalKey:symmetricalKey rsaPublicKey:postbox.postboxRSAPublicKey configuration:self.configuration];
        NSDictionary *metadataHeaders = [self postboxHeadersWithSessionKey:postbox.sessionKey symmetricalKey:keyEncrypted initializationVector:[iv hexString] metadata:metadataEncryptedString];
        NSDictionary *headers = [self defaultPostboxHeaders];
        NSURLSession *session = [self sessionWithHeaders:headers];
        NSURLRequest *request = [self.requestFactory pushRequestWithPostboxId:postbox.postboxId payload:payload headerParameters:metadataHeaders];
        HandlerBlock pushHandler = [self pushResponseHandlerForDomain:DME_API_ERROR completion:completion];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            
            if (httpResp.statusCode == 404)
            {
                if (![weakOperation retry])
                {
                    pushHandler(data, response, error);
                    [weakOperation finishDoingWork];
                }
                
                //return if operation will retry
                //return if operation cannot retry
                return;
            }
            
            pushHandler(data, response, error);
            [weakOperation finishDoingWork];
        }];
        
        [dataTask resume];
    };
    
    [self.queue addOperation:operation];
}

#pragma mark - Private

- (NSDictionary *)defaultPostboxHeaders
{
    return @{ @"Content-Type" : @"multipart/form-data",
              @"Accept" : @"application/json"
              };
}

/**
 Convenience method.
 
 @return NSDictionary headers required for Postbox data push.
 */
- (NSDictionary *)postboxHeadersWithSessionKey:(NSString *)sessionKey symmetricalKey:(NSString *)symmetricalKey initializationVector:(NSString *)iv metadata:(NSString *)metadata
{
    return @{ @"Content-Type": @"multipart/form-data",
              @"Accept": @"application/json",
              @"sessionKey": sessionKey,
              @"symmetricalKey": symmetricalKey,
              @"iv": iv,
              @"metadata": metadata,
              };
}

- (HandlerBlock)pushResponseHandlerForDomain:(NSString *)domain completion:(void(^)(NSError * _Nullable error))completion
{
    HandlerBlock handlerBlock = [self defaultResponseHandlerForDomain:domain success:^(NSData *data) {
        completion(nil);
    } failure:^(NSError *error) {
        completion(error);
    }];
    
    return handlerBlock;
}

@end
