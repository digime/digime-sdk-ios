//
//  DMEPushClient.m
//  DigiMeSDK
//
//  Created on 01/08/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEAPIClient+Postbox.h"
#import "DMEAuthorityPublicKey.h"
#import "DMEClient+Private.h"
#import "DMECrypto.h"
#import "DMEOngoingPostbox.h"
#import "DMEPostboxConsentManager.h"
#import "DMEPushClient.h"
#import "DMEPushConfiguration.h"
#import "DMESessionManager.h"
#import <DigiMeSDK/DigiMeSDK-Swift.h>

@interface DMEPushClient ()

@property (nonatomic, strong) DMEPostboxConsentManager *postboxManager;
@property (nonatomic, strong, nullable) DMEAuthorityPublicKey *verificationKey;

@end

@implementation DMEPushClient

- (instancetype)initWithConfiguration:(DMEPushConfiguration *)configuration
{
    self = [super initWithConfiguration:configuration];
    if (self)
    {
        _postboxManager = [[DMEPostboxConsentManager alloc] initWithSessionManager:self.sessionManager appId:self.configuration.appId];
    }
    
    return self;
}

#pragma mark - Property accessors

- (nullable NSString *)privateKeyHex
{
    return ((DMEPushConfiguration *)self.configuration).privateKeyHex;
}

#pragma mark - One-off Postbox

- (void)openDMEAppForPostboxImport
{
    if ([self.appCommunicator canOpenDMEApp])
    {
        DMEOpenAction *action = @"postbox/import";
        [self.appCommunicator openDigiMeAppWithAction:action parameters:@{}];
    }
}

- (void)createPostboxWithCompletion:(DMEPostboxCreationCompletion)completion
{
    // Validation
    NSError *validationError = [self validateClient];
    if (validationError != nil)
    {
        completion(nil, validationError);
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithScope:nil completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!session)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error ?: [NSError authError:AuthErrorGeneral]);
            });
            
            return;
        }
        
        [strongSelf.postboxManager requestPostboxWithCompletion:^(DMEPostbox * _Nullable postbox, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(postbox, error);
            });
        }];
    }];
}

- (void)pushDataToPostbox:(DMEPostbox *)postbox
                 metadata:(NSData *)metadata
                     data:(NSData *)data
               completion:(DMEPostboxDataPushCompletion)completion
{
    [self.apiClient pushDataToPostbox:postbox metadata:metadata data:data completion:^(NSError * _Nullable error) {
        completion(error);
    }];
}

#pragma mark - Ongoing Postbox

- (void)authorizeOngoingPostboxWithExistingPostbox:(DMEOngoingPostbox *)postbox completion:(DMEOngoingPostboxCompletion)completion
{
    // Validation
    NSError *validationError = [self validateClient];
    if (validationError != nil)
    {
        completion(nil, validationError);
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithScope:nil completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!session)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error ?: [NSError authError:AuthErrorGeneral]);
            });
            
            return;
        }
        
        if (postbox != nil)
        {
            DMEOngoingPostbox *updatedPostbox = [postbox updatedPostboxWithSessionKey:session.sessionKey];
            completion(updatedPostbox, nil);
            return;
        }
        
        NSString *jwtRequestBearer = [DMECrypto createPreAuthorizationJwtWithAppId:self.configuration.appId contractId:self.configuration.contractId privateKey:self.privateKeyHex];
        [strongSelf.apiClient requestPreauthorizationCodeWithBearer:jwtRequestBearer success:^(NSData * _Nonnull data) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;

            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSString *jwtResponse = jsonResponse[@"token"];
            
            [strongSelf.apiClient requestValidationDataForPreAuthenticationCodeWithSuccess:^(NSData * _Nonnull data) {
                 __strong __typeof(weakSelf)strongSelf = weakSelf;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSArray *keys = jsonResponse[@"keys"];
                NSDictionary *firstKey = keys.firstObject;
                NSString *publicKey = firstKey[@"pem"];
                // save authority public key for later usage
                strongSelf.verificationKey = [[DMEAuthorityPublicKey alloc] initWithPublicKey:publicKey date:[NSDate date]];
                NSString *preAuthCode = [DMECrypto preAuthCodeFromJwt:jwtResponse publicKey:publicKey];
                [strongSelf.postboxManager requestOngoingPostboxWithPreAuthCode:preAuthCode completion:^(DMEPostbox * _Nullable postbox, NSString * _Nullable accessCode, NSError * _Nullable error) {
                    if (error || accessCode == nil)
                    {
                        // Notify on main thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSError *errorToReport = error ?: [NSError authError:AuthErrorGeneral];
                            completion(nil, errorToReport);
                        });
                        return;
                    }
                    
                    NSString *jwtRequestBearer = [DMECrypto createAuthJwtWithAuthCode:accessCode appId:strongSelf.configuration.appId contractId:strongSelf.configuration.contractId privateKey:strongSelf.privateKeyHex];
                    [strongSelf.apiClient requestAccessAndRefreshTokensWithBearer:jwtRequestBearer success:^(NSData * _Nonnull data) {
                        __strong __typeof(weakSelf)strongSelf = weakSelf;
                        
                        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        NSString *jwtResponse = jsonResponse[@"token"];
                        
                        [strongSelf latestVerificationPublicKeyWithSuccess:^(NSString *publicKey) {
                            DMEOAuthToken *oAuthToken = [DMEJWTUtility oAuthTokenFrom:jwtResponse publicKey:publicKey];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (oAuthToken == nil)
                                {
                                    NSError *errorToReport = error ?: [NSError authError:AuthErrorGeneral];
                                    completion(nil, errorToReport);
                                    return;
                                }

//                                strongSelf.oAuthToken = oAuthToken;
                                DMEOngoingPostbox *ongoingPostbox = [[DMEOngoingPostbox alloc] initWithPostbox:postbox oAuthToken:oAuthToken];
                                completion(ongoingPostbox, nil);
                            });
                        } failure:^(NSError *error) {
                            completion(nil, error);
                        }];
                    } failure:^(NSError * _Nonnull error) {
                        completion(nil, error);
                    }];
                }];
                
            } failure:^(NSError * _Nonnull error) {
                completion(nil, error);
            }];
            
        } failure:^(NSError * _Nonnull error) {
            completion(nil, error);
        }];
    }];
}

- (void)pushDataToOngoingPostbox:(DMEOngoingPostbox *)postbox metadata:(NSData *)metadata data:(NSData *)data completion:(DMEOngoingPostboxCompletion)completion
{
    
}

- (void)latestVerificationPublicKeyWithSuccess:(void(^)(NSString *publicKey))success failure:(void(^)(NSError *error))failure
{
    if (self.verificationKey && [self.verificationKey isValid])
    {
        success(self.verificationKey.publicKey);
        return;
    }
    
    [self.apiClient requestValidationDataForPreAuthenticationCodeWithSuccess:^(NSData * _Nonnull data) {
        NSError *error;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error)
        {
            failure(error);
            return;
        }
        
        NSArray *keys = jsonResponse[@"keys"];
        NSDictionary *firstKey = keys.firstObject;
        NSString *publicKey = firstKey[@"pem"];
        self.verificationKey = [[DMEAuthorityPublicKey alloc] initWithPublicKey:publicKey date:[NSDate date]];
        success(publicKey);
    } failure:^(NSError * _Nonnull error) {
        failure(error);
    }];
}

@end

