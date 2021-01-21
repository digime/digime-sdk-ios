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
#import "DMECrypto.h"
#import "NSString+DMECrypto.h"
#import "DMEDataDecryptor.h"
#import "DMEDataUnpacker.h"
#import "DMEFileListDeserializer.h"
#import "DMEGuestConsentManager.h"
#import "DMENativeConsentManager.h"
#import "DMEOAuthService.h"
#import "DMEPreConsentViewController.h"
#import "DMEPullClient.h"
#import "DMEPullConfiguration.h"
#import "DMESessionManager.h"
#import "UIViewController+DMEExtension.h"
#import <DigiMeSDK/DigiMeSDK-Swift.h>

@interface DMEPullClient () <DMEPreConsentViewControllerDelegate, DMEAPIClientDelegate>

@property (nonatomic, strong, readonly) DMEDataDecryptor *dataDecryptor;
@property (nonatomic, strong, readonly) DMENativeConsentManager *nativeConsentManager;
@property (nonatomic, strong, readonly) DMEGuestConsentManager *guestConsentManager;
@property (nonatomic, strong, readonly) DMEOAuthService *oAuthService;
@property (nonatomic, strong, nullable) DMEPreConsentViewController *preconsentViewController;
@property (nonatomic, strong, nullable) DMESessionOptions *options;
@property (nonatomic, strong, nullable) DMEFileListCache *fileCache;
@property (nonatomic, readonly) DMEFileSyncState syncState;
@property (nonatomic, strong, nullable) void (^sessionDataCompletion)(DMEFileList * _Nullable fileList, NSError * _Nullable error);
@property (nonatomic, strong, nullable) void (^sessionContentHandler)(DMEFile * _Nullable file, NSError * _Nullable error);
@property (nonatomic, strong, nullable) void (^sessionFileListCompletion)(NSError * _Nullable error);
@property (nonatomic, strong, nullable) void (^sessionFileListUpdateHandler)(DMEFileList * fileList, NSArray *fileIds);
@property (nonatomic) BOOL fetchingSessionData;
@property (nonatomic) NSInteger stalePollCount;
@property (nonatomic, strong, nullable) DMEFileList *sessionFileList;
@property (nonatomic, strong, nullable) NSError *sessionError;
@property (nonatomic, strong, nullable) NSString *publicKeyHex;
@property (nonatomic, strong, nullable) NSString *privateKeyHex;
@property (nonatomic, strong, nullable) DMEOAuthToken *oAuthToken;

@end

@implementation DMEPullClient

#pragma mark - Initialization

- (instancetype)initWithConfiguration:(DMEPullConfiguration *)configuration
{
    self = [super initWithConfiguration:configuration];
    if (self)
    {
        _nativeConsentManager = [[DMENativeConsentManager alloc] initWithSessionManager:self.sessionManager appId:self.configuration.appId];
        _guestConsentManager = [[DMEGuestConsentManager alloc] initWithSessionManager:self.sessionManager configuration:self.configuration];
        _dataDecryptor = [[DMEDataDecryptor alloc] initWithConfiguration:configuration];
        _oAuthService = [[DMEOAuthService alloc] initWithConfiguration:configuration apiClient:self.apiClient];
        _fileCache = [DMEFileListCache new];
        _fetchingSessionData = NO;
        _stalePollCount = 0;
    }
    
    return self;
}

#pragma mark - Property accessors

- (nullable NSString *)publicKeyHex
{
    return ((DMEPullConfiguration *)self.configuration).publicKeyHex;
}

#pragma mark - Authorization

// Public func - notify completion on main thread
- (void)authorizeWithCompletion:(nonnull DMEAuthorizationCompletion)completion
{
    [self authorizeWithOptions:nil completion:completion];
}

// Public func - notify completion on main thread
- (void)authorizeWithScope:(id<DMEDataRequest>)scope completion:(nonnull DMEAuthorizationCompletion)completion
{
    [self authorizeWithScope:scope internalCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        // Notify on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(session, error);
        });
    }];
}

// Private func - no need to notify completion on main thread
- (void)authorizeWithScope:(id<DMEDataRequest>)scope internalCompletion:(nonnull DMEAuthorizationCompletion)completion
{
    DMESessionOptions *options = [DMESessionOptions new];
    options.scope = scope;
    [self authorizeWithOptions:options completion:completion];
}

- (void)authorizeWithOptions:(DMESessionOptions *)options completion:(DMEAuthorizationCompletion)completion
{
    // Validation
    NSError *validationError = [self validateClient];
    if (validationError != nil)
    {
        completion(nil, validationError);
        return;
    }
    
    self.options = options;
    
    if (((DMEPullConfiguration *)self.configuration).guestEnabled)
    {
        [self authorizeGuestWithOptions:options completion:completion];
    }
    else
    {
        [self authorizeNativeWithOptions:options completion:completion];
    }
}

// Private func - no need to notify completion on main thread
- (void)authorizeNativeWithOptions:(DMESessionOptions * _Nullable)options completion:(nonnull DMEAuthorizationCompletion)completion
{
    // Get session
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithOptions:options completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (session == nil)
        {
            NSError *errorToReport = error ?: [NSError authError:AuthErrorGeneral];
            completion(nil, errorToReport);
            return;
        }
        
        // Begin authorization
        [strongSelf.nativeConsentManager beginAuthorizationWithCompletion:completion];
    }];
}

- (void)authorizeNative
{
    [self authorizeNativeWithOptions:self.options completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        [self executeCompletionWithSession:session error:error];
    }];
}

#pragma mark - Ongoing Access Authorisation
// Public func - notify completion on main thread
- (void)authorizeOngoingAccessWithСompletion:(nonnull DMEOngoingAccessAuthorizationCompletion)completion
{
    [self authorizeOngoingAccessWithOptions:nil oAuthToken:nil completion:completion];
}

// Public func - notify completion on main thread
- (void)authorizeOngoingAccessWithScope:(nullable id<DMEDataRequest>)scope oAuthToken:(DMEOAuthToken * _Nullable)oAuthToken completion:(DMEOngoingAccessAuthorizationCompletion)completion
{
    [self authorizeOngoingAccessWithScope:scope oAuthToken:oAuthToken completion:^(DMESession * _Nullable session, DMEOAuthToken * _Nullable oAuthToken, NSError * _Nullable error) {
        // Notify on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(session, oAuthToken, error);
        });
    }];
}

// Private func - no need to notify completion on main thread
- (void)authorizeOngoingAccessWithScope:(nullable id<DMEDataRequest>)scope oAuthToken:(DMEOAuthToken * _Nullable)oAuthToken internalCompletion:(DMEOngoingAccessAuthorizationCompletion)completion
{
    DMESessionOptions *options = [DMESessionOptions new];
    options.scope = scope;
    [self authorizeOngoingAccessWithOptions:options oAuthToken:oAuthToken completion:completion];
}

- (void)authorizeOngoingAccessWithOptions:(DMESessionOptions * _Nullable)options oAuthToken:(DMEOAuthToken *)oAuthToken completion:(DMEOngoingAccessAuthorizationCompletion)completion
{
    // Validation
    NSError *validationError = [self validateClient];
    if (validationError != nil)
    {
        completion(nil, nil, validationError);
        return;
    }
    
    self.options = options;
    
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithOptions:options completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (session == nil)
        {
            NSError *errorToReport = error ?: [NSError authError:AuthErrorGeneral];
            completion(nil, nil, errorToReport);
            return;
        }
        
        if (oAuthToken)
        {
            strongSelf.oAuthToken = oAuthToken;
            [strongSelf triggerDataRetrievalWithCompletion:completion];
            return;
        }
        
        [strongSelf.oAuthService requestPreAuthorizationCodeWithPublicKey:[self publicKeyHex] success:^(NSString * _Nonnull preAuthCode) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf authorizeNativeOngoingAccessWithPreAuthCode:preAuthCode completion:completion];
        } failure:^(NSError * _Nonnull error) {
            completion(nil, nil, error);
        }];
    }];
}

// Private func - no need to notify completion on main thread
- (void)authorizeNativeOngoingAccessWithPreAuthCode:(NSString *)preAuthCode completion:(nonnull DMEOngoingAccessAuthorizationCompletion)completion
{
    __weak __typeof(self)weakSelf = self;
    [self.nativeConsentManager beginOngoingAccessAuthorizationWithPreAuthCode:preAuthCode completion:^(DMESession * _Nullable session, NSString * _Nullable authCode, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error || session == nil || authCode == nil)
        {
            NSError *errorToReport = error ?: [NSError authError:AuthErrorGeneral];
            completion(nil, nil, errorToReport);
            return;
        }
        
        [strongSelf.oAuthService requestOAuthTokenForAuthCode:authCode publicKey:[self publicKeyHex] success:^(DMEOAuthToken * _Nonnull oAuthToken) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.oAuthToken = oAuthToken;
            completion(session, oAuthToken, nil);
        } failure:^(NSError * _Nonnull error) {
            completion(nil, nil, error);
        }];
    }];
}

#pragma mark - Ongoing Access Data retrieval

// Private func - no need to notify completion on main thread
- (void)triggerDataRetrievalWithCompletion:(nonnull DMEOngoingAccessAuthorizationCompletion)completion
{
    //validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession];
        completion(nil, self.oAuthToken, error);
        return;
    }
    
    if (!self.oAuthToken)
    {
        NSError *error = [NSError sdkError:SDKErrorOAuthTokenNotSet];
        completion(nil, nil, error);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    NSString *jwtTriggerDataBearer = [DMECrypto createDataTriggerJwtWithAccessToken:self.oAuthToken.accessToken appId:self.configuration.appId contractId:self.configuration.contractId sessionKey:self.sessionManager.currentSession.sessionKey privateKey:self.privateKeyHex publicKey:self.publicKeyHex];
    
    [self.apiClient requestDataTriggerWithBearer:jwtTriggerDataBearer success:^(NSData * _Nonnull data) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        completion(strongSelf.sessionManager.currentSession, strongSelf.oAuthToken, nil);
    } failure:^(NSError * _Nonnull error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;

        // This is the place where we should update Access token using Refresh token.
        // Access token valid for one day, refresh token is valid for 30 days.
        // When you renew Access token you will get new Access token and new Refresh token, but refresh token's expiration date will be the same as for the previous.
        // It means in any scenario 3rd party should ask for user's consent every month.
        if (error.code == 401 && [error.userInfo[@"code"] isEqualToString:@"InvalidToken"])
        {
            [strongSelf.oAuthService renewAccessTokenWithOAuthToken:strongSelf.oAuthToken publicKey:[self publicKeyHex] retryHandler:^(DMEOAuthToken * _Nonnull oAuthToken) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                strongSelf.oAuthToken = oAuthToken;
                [strongSelf triggerDataRetrievalWithCompletion:completion];
            } reauthHandler:^{
                // Authorize without token, via digi.me app
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf authorizeOngoingAccessWithScope:self.scope oAuthToken:nil internalCompletion:completion];
            } errorHandler:^(NSError * _Nonnull error) {
                completion(nil, nil, error);
            }];
            return;
        }
        
        completion(nil, nil, error);
    }];
}

#pragma mark - Guest Authorization
DMEAuthorizationCompletion _authorizationCompletion;

- (void)setAuthorizationCompletion:(DMEAuthorizationCompletion)authorizationCompletion
{
    _authorizationCompletion = authorizationCompletion;
}

- (void)authorizeGuestWithOptions:(DMESessionOptions * _Nullable)options completion:(DMEAuthorizationCompletion)completion
{
    if (![NSThread currentThread].isMainThread)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self authorizeGuestWithOptions:options completion:completion];
        });
        return;
    }
    
    if ([self.appCommunicator canOpenDMEApp])
    {
        [self authorizeNativeWithOptions:options completion:completion];
    }
    else
    {
        self.options = options;
        [self setAuthorizationCompletion:completion];
        self.preconsentViewController = [DMEPreConsentViewController new];
        self.preconsentViewController.delegate = self;
        self.preconsentViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [[UIViewController topmostViewController] presentViewController:self.preconsentViewController animated:YES completion:nil];
    }
}

- (void)authorizeGuest
{
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithOptions:self.options completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!session)
        {
            [strongSelf executeCompletionWithSession:nil error:error];
            return;
        }
        
        [strongSelf.guestConsentManager requestGuestConsentWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
            
            [strongSelf executeCompletionWithSession:session error:error];
        }];
    }];
}

// Private func - no need to notify completion on main thread
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
    __weak __typeof(self)weakSelf = self;
    [self.preconsentViewController dismissViewControllerAnimated:YES completion:^{
        [weakSelf authorizeNative];
    }];
}

- (void)authenticateUsingGuestConsent
{
    __weak __typeof(self)weakSelf = self;
    [self.preconsentViewController dismissViewControllerAnimated:YES completion:^{
        [weakSelf authorizeGuest];
    }];
}

#pragma mark - Get File List

// Public func - notify completion and update handler on main thread
- (void)getSessionFileListWithUpdateHandler:(DMESessionFileListCompletion)updateHandler completion:(void (^)(NSError * _Nullable))completion
{
    self.sessionFileListUpdateHandler = ^(DMEFileList * fileList, NSArray *fileIds) {
        dispatch_async(dispatch_get_main_queue(), ^{
            updateHandler(fileList, fileIds);
        });
    };
    self.sessionFileListCompletion = ^(NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    };
    [self beginFileListPollingIfRequired];
}

// Public func - notify completion on main thread
- (void)getFileListWithCompletion:(void (^)(DMEFileList * _Nullable fileList, NSError  * _Nullable error))completion
{
    [self getFileListWithInternalCompletion:^(DMEFileList * _Nullable fileList, NSError * _Nullable error) {
        // Notify on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(fileList, error);
        });
    }];
}

// Private func - no need to notify completion on main thread
- (void)getFileListWithInternalCompletion:(void (^)(DMEFileList * _Nullable fileList, NSError  * _Nullable error))completion
{
    // Validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession];
        completion(nil, error);
        return;
    }
    
    // Initiate file list request
    [self.apiClient requestFileListForSessionWithKey:self.sessionManager.currentSession.sessionKey success:^(NSData * _Nonnull data) {
        NSError *error;
        DMEFileList *fileList = [DMEFileListDeserializer deserialize:data error:&error];
        completion(fileList, error);
    } failure:^(NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

#pragma mark - Sync Management
- (void)beginFileListPollingIfRequired
{
    if (self.fetchingSessionData)
    {
        NSLog(@"DigiMeSDK: Already fetching session data.");
        return;
    }
    
    [self.fileCache reset];
    self.fetchingSessionData = YES;
    self.apiClient.delegate = self;
    [self refreshFileList];
    [self scheduleNextPoll];
}

- (void)evaluateSessionDataFetchProgress:(BOOL)schedulePoll
{
    @synchronized (self) {
        if (!self.fetchingSessionData)
        {
            return;
        }
    }
    
    if (self.configuration.debugLogEnabled)
    {
        NSLog(@"DigiMeSDK: Sync state - %@", self.sessionFileList.syncStateString);
    }
    
    // If sessionError is not nil, then syncState is irrelevant, as it will be the previous successful fileList call.
    if ((self.sessionError != nil || ![self syncRunning]) && !self.apiClient.isDownloadingFiles)
    {
        if (self.configuration.debugLogEnabled)
        {
            NSLog(@"DigiMeSDK: Finished fetching session data.");
        }
        
        [self completeSessionDataFetchWithError:self.sessionError];
        return;
    }
    else if (schedulePoll)
    {
        [self scheduleNextPoll];
    }
    
    // not checking sessionError here on purpose. If we are here, then there are files still being downloaded
    // so we may as well poll the file list again, just in case the error clears.
    if ([self syncRunning])
    {
        [self refreshFileList];
    }
}

// Private func - no need to notify update handler on main thread
- (void)refreshFileList
{
    if (self.configuration.debugLogEnabled)
    {
        NSLog(@"DigiMeSDK: Refreshing file list");
    }
    
    [self getFileListWithInternalCompletion:^(DMEFileList * _Nullable fileList, NSError * _Nullable error) {
        
        if (fileList == nil)
        {
            // If the error occurred we don't want to terminate right away
            // There could still be files downloading. Instead, we will store the sessionError
            // which will be forwarded in completion once all file have been downloaded
            
            if (self.configuration.debugLogEnabled)
            {
                NSLog(@"DigiMeSDK: Error fetching file list: %@", error.localizedDescription);
            }
            
            // If no files are being downloaded, we can terminate session fetch right away.
            if (!self.apiClient.isDownloadingFiles)
            {
                [self completeSessionDataFetchWithError:error];
            }
            
            self.sessionError = error;
            return;
        }
        
        BOOL fileListDidChange = ![fileList isEqual:self.sessionFileList];
        self.stalePollCount = (fileListDidChange) ? 0 : self.stalePollCount + 1;
        DMEPullConfiguration *configuration = (DMEPullConfiguration *)self.configuration;
        
        if (self.stalePollCount >= configuration.maxStalePolls)
        {
            NSError *error = [NSError sdkError:SDKErrorFileListPollingTimeout];
            self.sessionError = error;
            return;
        }
        
        // If subsequent fetch clears the error (stale one or otherwise) - great, no need to report it back up the chain
        self.sessionError = nil;
        self.sessionFileList = fileList;
        NSArray <DMEFileListItem *> *newItems = [self.fileCache newItemsFromList:fileList.files];
        NSArray *allFiles = [newItems valueForKey:@"name"];
        
        [self handleNewFileListItems:newItems];
        
        // if file list changed and session file list update handler is provided - notify.
        if (fileListDidChange && self.sessionFileListUpdateHandler)
        {
            self.sessionFileListUpdateHandler(fileList, allFiles);
        }
    }];
}

// Private func - no need to notify update handler on main thread
- (void)handleNewFileListItems:(NSArray *)items
{
    NSArray *allFiles = [items valueForKey:@"name"];
    if (items.count > 0)
    {
        if (self.configuration.debugLogEnabled)
        {
            NSLog(@"DigiMeSDK: Found new files to sync: %@", @(items.count));
        }
        
        [self.fileCache cacheItems:items];
        
        //if contentHandler is not provided, no need to download.
        if (self.sessionContentHandler)
        {
            for (NSString *fileId in allFiles)
            {
                if (self.configuration.debugLogEnabled)
                {
                    NSLog(@"DigiMeSDK: Adding file to download queue: %@", fileId);
                }
                
                [self getSessionDataWithFileId:fileId internalCompletion:self.sessionContentHandler];
            }
        }
    }
}

- (void)scheduleNextPoll
{
    DMEPullConfiguration *pullConfiguration = (DMEPullConfiguration *)self.configuration;
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pullConfiguration.pollInterval * NSEC_PER_SEC));
    
    __weak __typeof(self)weakSelf = self;
    dispatch_after(delay, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf evaluateSessionDataFetchProgress:YES];
    });
}

- (BOOL)syncRunning
{
    @synchronized (self) {
        return self.syncState == DMEFileSyncStateRunning || self.syncState == DMEFileSyncStatePending || self.syncState == DMEFileSyncStateUnknown;
    }
}

- (DMEFileSyncState)syncState
{
    if (self.sessionFileList)
    {
        return self.sessionFileList.syncState;
    }
    
    return DMEFileSyncStateUnknown;
}

// Private func - no need to notify completion on main thread
- (void)completeSessionDataFetchWithError:(NSError * _Nullable)error
{
    if (self.sessionDataCompletion)
    {
        self.sessionDataCompletion(self.sessionFileList, error);
    }
    
    if (self.sessionFileListCompletion)
    {
        self.sessionFileListCompletion(error);
    }
    
    [self clearSessionData];
}

- (void)clearSessionData
{
    @synchronized (self) {
        self.fetchingSessionData = NO;
    }
    
    [self.fileCache reset];
    self.sessionFileList = nil;
    self.sessionDataCompletion = nil;
    self.sessionContentHandler = nil;
    self.sessionFileListUpdateHandler = nil;
    self.sessionFileListCompletion = nil;
    self.apiClient.delegate = nil;
    self.sessionError = nil;
    self.stalePollCount = 0;
}

- (void)cancel
{
    if (!self.fetchingSessionData)
    {
        if (self.configuration.debugLogEnabled)
        {
            NSLog(@"DigiMeSDK: Session fetching not in progress.");
        }
        return;
    }
    
    [self.apiClient cancelQueuedDownloads];
    [self clearSessionData];
    
    if (self.configuration.debugLogEnabled)
    {
        NSLog(@"DigiMeSDK: Session fetch cancelled.");
    }
}

#pragma mark - Get File Content

// Public func - notify completion and download handler on main thread
- (void)getSessionDataWithDownloadHandler:(DMEFileContentCompletion)fileContentHandler completion:(DMESessionDataCompletion)completion
{
    self.sessionDataCompletion = ^(DMEFileList * _Nullable fileList, NSError * _Nullable error) {
        // Notify on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(fileList, error);
        });
    };
    self.sessionContentHandler = ^(DMEFile * _Nullable file, NSError * _Nullable error) {
        // Notify on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            fileContentHandler(file, error);
        });
    };
    
    [self beginFileListPollingIfRequired];
}

// Public func - notify completion on main thread
- (void)getSessionDataForFileWithId:(NSString *)fileId completion:(DMEFileContentCompletion)completion
{
    [self getSessionDataWithFileId:fileId completion:completion];
}

// Public func - notify completion on main thread
- (void)getSessionDataWithFileId:(NSString *)fileId completion:(DMEFileContentCompletion)completion
{
    [self getSessionDataWithFileId:fileId internalCompletion:^(DMEFile * _Nullable file, NSError * _Nullable error) {
        // Notify on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(file, error);
        });
    }];
}

// Private func - no need to notify completion on main thread
- (void)getSessionDataWithFileId:(NSString *)fileId internalCompletion:(DMEFileContentCompletion)completion
{
    // Validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession additionalInfo:@{ kFileIdKey: fileId }];
        completion(nil, error);
        
        return;
    }
    
    // Initiate file content request
    __weak __typeof(self)weakSelf = self;
    [self.apiClient requestFileWithId:fileId sessionKey:self.sessionManager.currentSession.sessionKey success:^(NSData * _Nonnull data) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [strongSelf processFileData:data fileId:fileId completion:completion];
        
    } failure:^(NSError * _Nonnull error) {
        // Add fileId to error before passing to completion
        NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
        userInfo[kFileIdKey] = fileId;
        NSError *newError = [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
        completion(nil, newError);
    }];
}

// Private func - no need to notify completion on main thread
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
    
    completion(file, error);
}


#pragma mark - Accounts

// Public func - notify completion on main thread
- (void)getSessionAccountsWithCompletion:(DMEAccountsCompletion)completion
{
    // Validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
        return;
    }
    
    // Initiate accounts request
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

#pragma mark - DMEAPIClientDelegate
- (void)didFinishAllDownloads
{

    if (self.configuration.debugLogEnabled)
    {
        NSLog(@"DigiMeSDK: Finished Downloading all files");
    }
    
    [self evaluateSessionDataFetchProgress:NO];
}

@end
