//
//  DMEOAuthService.m
//  DigiMeSDK
//
//  Created on 14/01/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

#import "DMEAPIClient.h"
#import "DMEAuthorityPublicKey.h"
#import "DMECrypto.h"
#import "DMEOAuthService.h"
#import "NSError+Auth.h"
#import <DigiMeSDK/DigiMeSDK-Swift.h>

@interface DMEOAuthService ()

@property (nonatomic, strong, readonly) id<DMEClientConfiguration> configuration;
@property (nonatomic, strong, readonly) DMEAPIClient *apiClient;

@property (nonatomic, strong, nullable) DMEAuthorityPublicKey *verificationKey;

@end

@implementation DMEOAuthService

- (instancetype)initWithConfiguration:(id<DMEClientConfiguration>)configuration apiClient:(DMEAPIClient *)apiClient
{
    self = [super init];
    if (self)
    {
        _configuration = configuration;
        _apiClient = apiClient;
    }
    
    return self;
}

- (void)latestVerificationPublicKeyWithSuccess:(void (^)(NSString * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure
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

- (void)requestOAuthTokenForAuthCode:(NSString *)authCode publicKey:(nullable NSString *)publicKey success:(void (^)(DMEOAuthToken * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure
{
    NSString *jwtRequestBearer = [DMECrypto createAuthJwtWithAuthCode:authCode appId:self.configuration.appId contractId:self.configuration.contractId privateKey:self.configuration.privateKeyHex publicKey:publicKey];
    
    __weak __typeof(self)weakSelf = self;
    [self.apiClient requestAccessAndRefreshTokensWithBearer:jwtRequestBearer success:^(NSData * _Nonnull data) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        NSError *error;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

        if (error)
        {
            failure(error);
            return;
        }

        NSString *jwtResponse = jsonResponse[@"token"];
        
        [strongSelf latestVerificationPublicKeyWithSuccess:^(NSString *publicKey) {
            DMEOAuthToken *oAuthToken = [DMEJWTUtility oAuthTokenFrom:jwtResponse publicKey:publicKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (oAuthToken == nil)
                {
                    NSError *errorToReport = [NSError authError:AuthErrorGeneral];
                    failure(errorToReport);
                    return;
                }

                success(oAuthToken);
            });
        } failure:failure];
    } failure:failure];
}

- (void)renewAccessTokenWithOAuthToken:(DMEOAuthToken *)oAuthToken publicKey:(nullable NSString *)publicKey retryHandler:(nonnull void(^)(DMEOAuthToken *oAuthToken))retryHandler reauthHandler:(nonnull void(^)(void))reauthHandler errorHandler:(nonnull void(^)(NSError *error))errorHandler
{
    NSString *jwtRefreshTokenBearer = [DMECrypto createRefreshJwtWithRefreshToken:oAuthToken.refreshToken appId:self.configuration.appId contractId:self.configuration.contractId privateKey:self.configuration.privateKeyHex publicKey:publicKey];
    
    __weak typeof(self) weakSelf = self;
    [self.apiClient renewAccessTokenWithBearer:jwtRefreshTokenBearer success:^(NSData * _Nonnull data) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        NSError *error;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

        if (error)
        {
            errorHandler(error);
            return;
        }
        
        NSString *jwtResponse = jsonResponse[@"token"];
        [strongSelf latestVerificationPublicKeyWithSuccess:^(NSString *publicKey) {
            DMEOAuthToken *oAuthToken = [DMEJWTUtility oAuthTokenFrom:jwtResponse publicKey:publicKey];
            retryHandler(oAuthToken);
        } failure:^(NSError *error) {
            errorHandler(error);
        }];
    } failure:^(NSError * _Nonnull error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (error.code == 401 && [error.userInfo[@"code"] isEqualToString:@"InvalidToken"])
        {
            if (strongSelf.configuration.autoRecoverExpiredCredentials)
            {
                reauthHandler();
            }
            else
            {
                NSError *tokenError = [NSError authError:AuthErrorOAuthTokenExpired additionalInfo:error.userInfo];
                errorHandler(tokenError);
            }
                
            return;
        }
        
        errorHandler(error);
    }];
}

@end
