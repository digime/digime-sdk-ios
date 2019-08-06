//
//  DMEClient.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEAccounts.h"
#import "DMEAPIClient.h"
#import "DMEClient+Private.h"
#import "DMEClientConfiguration.h"
#import "DMEDataDecryptor.h"
#import "DMEDataUnpacker.h"
#import "DMEFilesDeserializer.h"
#import "DMEGuestConsentManager.h"
#import "DMENativeConsentManager.h"
#import "DMEPreConsentViewController.h"
#import "DMEPullClient.h"
#import "DMESessionManager.h"
#import "UIViewController+DMEExtension.h"
#import <DigiMeSDK/DigiMeSDK-Swift.h>

@interface DMEPullClient () <DMEPreConsentViewControllerDelegate>

@property (nonatomic, strong, readonly) DMEDataDecryptor *dataDecryptor;
@property (nonatomic, strong, readonly) DMENativeConsentManager *nativeConsentManager;
@property (nonatomic, strong, readonly) DMEGuestConsentManager *guestConsentManager;
@property (nonatomic, strong, nullable) DMEPreConsentViewController *preconsentViewController;
@property (nonatomic, strong, nullable) id<DMEDataRequest> scope;

@end

@implementation DMEPullClient

#pragma mark - Initialization

- (instancetype)initWithConfiguration:(DMEClientConfiguration *)configuration
{
    self = [super initWithConfiguration:configuration];
    if (self)
    {
        _nativeConsentManager = [[DMENativeConsentManager alloc] initWithSessionManager:self.sessionManager appId:self.configuration.appId];
        _guestConsentManager = [[DMEGuestConsentManager alloc] initWithSessionManager:self.sessionManager configuration:self.configuration];        
        _dataDecryptor = [[DMEDataDecryptor alloc] initWithConfiguration:configuration];
    }
    
    return self;
}

#pragma mark - Native Authorization

- (void)authorizeWithCompletion:(nonnull DMEAuthorizationCompletion)authorizationCompletion
{
    [self authorizeWithScope:nil completion:authorizationCompletion];
}

- (void)authorizeWithScope:(id<DMEDataRequest>)scope completion:(nonnull DMEAuthorizationCompletion)authorizationCompletion
{
    // Validation
    NSError *validationError = [self validateClient];
    if (validationError != nil)
    {
        authorizationCompletion(nil, validationError);
        return;
    }
    
    //get session
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithScope:scope completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (session == nil)
        {
            // Notify on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *errorToReport = error ?: [NSError authError:AuthErrorGeneral];
                authorizationCompletion(nil, errorToReport);
                return;
            });
            return;
        }
        
        //begin authorization
        [strongSelf userAuthorizationWithCompletion:authorizationCompletion];
    }];
}

- (void)userAuthorizationWithCompletion:(nonnull DMEAuthorizationCompletion)authorizationCompletion
{
    __weak __typeof(self)weakSelf = self;
    [self.nativeConsentManager beginAuthorizationWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        //notify on main thread.
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.configuration.debugLogEnabled)
        {
            NSLog(@"[DMEClient] isMain thread: %@", ([NSThread currentThread].isMainThread ? @"YES" : @"NO"));
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            authorizationCompletion(session, error);
            return;
        });
    }];
}

#pragma mark - Guest Authorization
DMEAuthorizationCompletion _authorizationCompletion;

- (void)setAuthorizationCompletion:(DMEAuthorizationCompletion)authorizationCompletion
{
    _authorizationCompletion = authorizationCompletion;
}

- (void)authorizeGuestWithCompletion:(DMEAuthorizationCompletion)completion
{
    [self authorizeGuestWithScope:nil completion:completion];
}

- (void)authorizeGuestWithScope:(id<DMEDataRequest>)scope completion:(DMEAuthorizationCompletion)completion
{
    if ([self.appCommunicator canOpenDMEApp])
    {
        [self authorizeWithCompletion:completion];
    }
    else
    {
        self.scope = scope;
        [self setAuthorizationCompletion:completion];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.preconsentViewController = [DMEPreConsentViewController new];
            self.preconsentViewController.delegate = self;
            self.preconsentViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [[UIViewController topmostViewController] presentViewController:self.preconsentViewController animated:YES completion:nil];
        });
    }
}

- (void)authorizeGuest
{
    // Validation
    NSError *validationError = [self validateClient];
    if (validationError != nil)
    {
        [self executeCompletionWithSession:nil error:validationError];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithScope:self.scope completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!session)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf executeCompletionWithSession:nil error:error];
            });
            
            return;
        }
        
        [strongSelf.guestConsentManager requestGuestConsentWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf executeCompletionWithSession:session error:error];
            });
        }];
    }];
}

- (void)executeCompletionWithSession:(DMESession * _Nullable )session error:(NSError * _Nullable)error
{
    if (_authorizationCompletion != nil)
    {
        _authorizationCompletion(session, error);
        _authorizationCompletion = nil;
    }
}

#pragma mark DMEPreConsentViewControllerDelegate

- (void)downloadDigimeFromAppstore
{
    [self.preconsentViewController dismissViewControllerAnimated:YES completion:^{
        [self authorizeWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
            [self executeCompletionWithSession:session error:error];
        }];
    }];
}

- (void)authenticateUsingGuestConsent
{
    [self.preconsentViewController dismissViewControllerAnimated:YES completion:^{
        [self authorizeGuest];
    }];
}

#pragma mark - Get File List
- (void)getFileListWithCompletion:(void (^)(DMEFiles * _Nullable files, NSError  * _Nullable error))completion
{
    //validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession];
        completion(nil, error);
        return;
    }
    
    //initiate file list request
    [self.apiClient requestFileListForSessionWithKey:self.sessionManager.currentSession.sessionKey success:^(NSData * _Nonnull data) {
        NSError *error;
        DMEFiles *files = [DMEFilesDeserializer deserialize:data error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(files, error);
        });
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
}

#pragma mark - Get File Content

- (void)getSessionDataWithDownloadHandler:(DMEFileContentCompletion)fileContentHandler completion:(void (^)(NSError * _Nullable))completion
{
    [self getFileListWithCompletion:^(DMEFiles * _Nullable files, NSError * _Nullable error) {
        if (files == nil)
        {
            completion(error);
            return;
        }
        
        for (NSString *fileId in files.fileIds)
        {
            [self getSessionDataForFileWithId:fileId completion:fileContentHandler];
        }
    }];
}

- (void)getSessionDataForFileWithId:(NSString *)fileId completion:(DMEFileContentCompletion)completion
{
    //validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession additionalInfo:@{ kFileIdKey: fileId }];
        completion(nil, error);
        
        return;
    }
    
    //initiate file content request
    __weak __typeof(self)weakSelf = self;
    [self.apiClient requestFileWithId:fileId sessionKey:self.sessionManager.currentSession.sessionKey success:^(NSData * _Nonnull data) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf processFileData:data fileId:fileId completion:completion];
        
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Add fileId to error before passing to completion
            NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
            userInfo[kFileIdKey] = fileId;
            NSError *newError = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
            
            completion(nil, newError);
        });
    }];
}

- (void)processFileData:(NSData *)data fileId:(NSString *)fileId completion:(DMEFileContentCompletion)completion
{
    DMEFile *file;
    NSError *error;
    DMEFileMetadata *metadata;
    NSData *unpackedData = [DMEDataUnpacker unpackData:data decryptor:self.dataDecryptor resolvedMetadata:&metadata error:&error];
    if (unpackedData != nil)
    {
        file = [[DMEFile alloc] initWithFileId:fileId fileContent:unpackedData fileMetadata:metadata];
    }
    
    if (error != nil)
    {
        // Add fileId to error before passing to completion
        NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
        userInfo[kFileIdKey] = fileId;
        error = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(file, error);
    });
}


#pragma mark - Accounts

- (void)getSessionAccountsWithCompletion:(DMEAccountsCompletion)completion
{
    //validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession];
        completion(nil, error);
        return;
    }
    
    //initiate accounts request
    [self.apiClient requestFileWithId:@"accounts.json" sessionKey:self.sessionManager.currentSession.sessionKey success:^(NSData * _Nonnull data) {

        DMEAccounts *accounts;
        NSError *error;
        NSData *unpackedData = [DMEDataUnpacker unpackData:data decryptor:self.dataDecryptor resolvedMetadata:NULL error:&error];
        if (unpackedData != nil)
        {
            accounts = [DMEAccounts deserialize:unpackedData error:&error];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(accounts, error);
        });
        
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
    }];
    
}

#pragma mark - Debug

- (NSDictionary <NSString *, id> *)metadata
{
    return self.sessionManager.currentSession.metadata;
}

@end
