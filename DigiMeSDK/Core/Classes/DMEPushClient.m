//
//  DMEPushClient.m
//  DigiMeSDK
//
//  Created on 01/08/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEAPIClient+Postbox.h"
#import "DMEClient+Private.h"
#import "DMEOAuthService.h"
#import "DMEOngoingPostbox.h"
#import "DMEPostboxConsentManager.h"
#import "DMEPushClient.h"
#import "DMEPushConfiguration.h"
#import "DMESessionManager.h"

@interface DMEPushClient ()

@property (nonatomic, strong, readonly) DMEPostboxConsentManager *postboxManager;
@property (nonatomic, strong, readonly) DMEOAuthService *oAuthService;

@end

@implementation DMEPushClient

- (instancetype)initWithConfiguration:(DMEPushConfiguration *)configuration
{
    self = [super initWithConfiguration:configuration];
    if (self)
    {
        _postboxManager = [[DMEPostboxConsentManager alloc] initWithSessionManager:self.sessionManager appId:self.configuration.appId];
        _oAuthService = [[DMEOAuthService alloc] initWithConfiguration:configuration apiClient:self.apiClient];
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

- (void)authorizeOngoingPostboxWithExistingPostbox:(nullable DMEOngoingPostbox *)postbox completion:(DMEOngoingPostboxCompletion)completion
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
        
        [strongSelf.oAuthService requestPreAuthorizationCodeWithPublicKey:nil success:^(NSString * _Nonnull preAuthCode) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf authorizeOngoingPostboxWithPreAuthCode:preAuthCode completion:completion];
        } failure:^(NSError * _Nonnull error) {
            completion(nil, error);
        }];
    }];
}

- (void)authorizeOngoingPostboxWithPreAuthCode:(NSString *)preAuthCode completion:(nonnull DMEOngoingPostboxCompletion)completion
{
    __weak __typeof(self)weakSelf = self;
    [self.postboxManager requestOngoingPostboxWithPreAuthCode:preAuthCode completion:^(DMEPostbox * _Nullable postbox, NSString * _Nullable accessCode, NSError * _Nullable error) {
        if (error || accessCode == nil)
        {
            // Notify on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *errorToReport = error ?: [NSError authError:AuthErrorGeneral];
                completion(nil, errorToReport);
            });
            return;
        }
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.oAuthService requestOAuthTokenForAuthCode:accessCode publicKey:nil success:^(DMEOAuthToken * _Nonnull oAuthToken) {
            DMEOngoingPostbox *ongoingPostbox = [[DMEOngoingPostbox alloc] initWithPostbox:postbox oAuthToken:oAuthToken];
            completion(ongoingPostbox, nil);
        } failure:^(NSError * _Nonnull error) {
            completion(nil, error);
        }];
    }];
}

- (void)pushDataToOngoingPostbox:(DMEOngoingPostbox *)postbox metadata:(NSData *)metadata data:(NSData *)data completion:(DMEOngoingPostboxCompletion)completion
{
    __weak typeof(self) weakSelf = self;
    
    // Validate session
    if (![self.sessionManager isSessionValid])
    {
        // Get new session if possible
        [self authorizeOngoingPostboxWithExistingPostbox:postbox completion:^(DMEOngoingPostbox * _Nullable updatedPostbox, NSError * _Nullable error) {
            [weakSelf pushDataToOngoingPostbox:updatedPostbox metadata:metadata data:data completion:completion];
        }];
        
        return;
    }
    
    [self.apiClient pushDataToPostbox:postbox metadata:metadata data:data completion:^(NSError * _Nullable error) {
        if (error == nil)
        {
            completion(postbox, nil);
            return;
        }
        
        // This is the place where we should update Access token using Refresh token.
        // Access token valid for one day, refresh token is valid for 30 days.
        // When you renew Access token you will get new Access token and new Refresh token, but refresh token's expiration date will be the same as for the previous.
        // It means in any scenario 3rd party should ask for user's consent every month.
        if (error.code == 401 && [error.userInfo[@"code"] isEqualToString:@"InvalidToken"])
        {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.oAuthService renewAccessTokenWithOAuthToken:postbox.oAuthToken publicKey:nil retryHandler:^(DMEOAuthToken * _Nonnull oAuthToken) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                DMEOngoingPostbox *updatedPostbox = [[DMEOngoingPostbox alloc] initWithPostbox:postbox oAuthToken:oAuthToken];
                [strongSelf pushDataToOngoingPostbox:updatedPostbox metadata:metadata data:data completion:completion];
                
            } reauthHandler:^{
                // Authorize without token, via digi.me app
                [strongSelf reauthorizeOngoingPostboxAndPushWithMetadata:metadata data:data completion:completion];
                
            } errorHandler:^(NSError * _Nonnull error) {
                completion(nil, error);
            }];
            return;
        }
        
        completion(nil, error);
    }];
}

- (void)reauthorizeOngoingPostboxAndPushWithMetadata:(NSData *)metadata data:(NSData *)data completion:(DMEOngoingPostboxCompletion)completion
{
    __weak typeof(self) weakSelf = self;
    
    // Authorize without token, via digi.me app
    [self authorizeOngoingPostboxWithExistingPostbox:nil completion:^(DMEOngoingPostbox * _Nullable postbox, NSError * _Nullable error) {
        if (error != nil)
        {
            completion(nil, error);
            return;
        }
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf pushDataToOngoingPostbox:postbox metadata:metadata data:data completion:completion];
    }];
}

@end

