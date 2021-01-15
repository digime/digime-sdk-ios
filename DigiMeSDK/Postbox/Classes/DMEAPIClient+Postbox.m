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
#import "DMEOngoingPostbox.h"
#import "DMEPostbox.h"
#import "DMECryptoUtilities.h"
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
        
        NSDictionary *headers = [self defaultPostboxHeaders];
        NSURLSession *session = [self sessionWithHeaders:headers];
        NSURLRequest *request = [self pushRequestToPostbox:postbox accessToken:nil metadata:metadata data:data];
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
                
                // Return if operation will retry
                // Return if operation cannot retry
                return;
            }
            
            pushHandler(data, response, error);
            [weakOperation finishDoingWork];
        }];
        
        [dataTask resume];
    };
    
    [self.queue addOperation:operation];
}

- (void)pushDataToOngoingPostbox:(DMEOngoingPostbox *)postbox
                        metadata:(NSData *)metadata
                            data:(NSData *)data
                      completion:(DMEPostboxDataPushCompletion)completion
{
    DMEOperation *operation = [[DMEOperation alloc] initWithConfiguration:self.configuration];
    
    __weak __typeof(DMEOperation *) weakOperation = operation;
    
    operation.workBlock = ^{
        
        NSDictionary *headers = [self defaultPostboxHeaders];
        NSURLSession *session = [self sessionWithHeaders:headers];
        NSURLRequest *request = [self pushRequestToPostbox:postbox accessToken:postbox.oAuthToken.accessToken metadata:metadata data:data];
        HandlerBlock pushHandler = [self pushResponseHandlerForDomain:DME_API_ERROR completion:completion];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            // Handle oauth errors
            if (httpResp.statusCode == 404)
            {
                if (![weakOperation retry])
                {
                    pushHandler(data, response, error);
                    [weakOperation finishDoingWork];
                }
                
                // Return if operation will retry
                // Return if operation cannot retry
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

- (NSURLRequest *)pushRequestToPostbox:(DMEPostbox *)postbox
                           accessToken:(nullable NSString *)accessToken
                              metadata:(NSData *)metadata
                                  data:(NSData *)data
{
    NSData *symmetricalKey = [DMECryptoUtilities randomBytesWithLength:32];
    NSData *iv = [DMECryptoUtilities randomBytesWithLength:16];
    
    NSString *encryptedMetadata = [DMECrypto encryptMetadata:metadata symmetricalKey:symmetricalKey initializationVector:iv];
    NSData *payload = [DMECrypto encryptData:data symmetricalKey:symmetricalKey initializationVector:iv];
    NSString *encryptedSymmetricalKey = [DMECrypto encryptSymmetricalKey:symmetricalKey rsaPublicKey:postbox.postboxRSAPublicKey contractId:self.configuration.contractId];
    
    NSString *bearer = [DMECrypto createPostboxPushJwtWithAccessToken:accessToken appId:self.configuration.appId contractId:self.configuration.contractId initializationVector:iv metadata:encryptedMetadata sessionKey:postbox.sessionKey symmetricalKey:encryptedSymmetricalKey privateKey:self.configuration.privateKeyHex publicKey:nil];
    
    return [self.requestFactory pushRequestWithPostboxId:postbox.postboxId payload:payload bearer:bearer];
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
