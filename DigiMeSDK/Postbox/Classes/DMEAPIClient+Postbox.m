//
//  DMEAPIClient.m
//  DigiMeSDK
//
//  Created on 26/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "CASessionManager.h"
#import "DMEAPIClient.h"
#import "DMEAPIClient+Postbox.h"
#import "DMEOperation.h"
#import "NSString+DMECrypto.h"
#import "NSData+DMECrypto.h"
#import "DMECrypto.h"
#import "DMECertificatePinner.h"
#import "DMEClient.h"
#import "DMERequestFactory.h"
#import "CADataRequest.h"
#import "CAPostbox.h"

@implementation DMEAPIClient (Postbox)

#pragma mark - Data Push

- (void)pushDataToPostboxWithPostbox:(CAPostbox *)postbox
                      metadataToPush:(NSData *)metadata
                          dataToPush:(NSData *)data
                          completion:(PostboxDataPushCompletionBlock)completion
{
    DMEOperation *operation = [[DMEOperation alloc] initWithConfiguration:self.config];
    
    __weak __typeof(DMEOperation *) weakOperation = operation;
    
    operation.workBlock = ^{
        
        NSData *symmetricalKey = [self.crypto getRandomUnsignedCharacters:32];
        NSData *iv = [self.crypto getRandomUnsignedCharacters:16];
        NSString *metadataEncryptedString = [self.crypto encryptMetadata:metadata symmetricalKey:symmetricalKey initializationVector:iv];
        NSData *payload = [self.crypto encryptData:data symmetricalKey:symmetricalKey initializationVector:iv];
        NSString *keyEncrypted = [self.crypto encryptSymmetricalKey:symmetricalKey rsaPublicKey:postbox.publicKey];
        NSDictionary *metadataHeaders = [self postboxHeadersWithSessionKey:sessionKey symmetricalKey:keyEncrypted initializationVector:[iv hexString] metadata:metadataEncryptedString];
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
