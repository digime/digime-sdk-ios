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
#import "DMEDataDecryptor.h"
#import "DMEDataUnpacker.h"
#import "DMEFileListDeserializer.h"
#import "DMEGuestConsentManager.h"
#import "DMENativeConsentManager.h"
#import "DMEPreConsentViewController.h"
#import "DMEPullClient.h"
#import "DMEPullConfiguration.h"
#import "DMESessionManager.h"
#import "UIViewController+DMEExtension.h"
#import "DMEOperation.h"
#import <DigiMeSDK/DigiMeSDK-Swift.h>

@interface DMEPullClient () <DMEPreConsentViewControllerDelegate, DMEAPIClientDelegate>

@property (nonatomic, strong, readonly) DMEDataDecryptor *dataDecryptor;
@property (nonatomic, strong, readonly) DMENativeConsentManager *nativeConsentManager;
@property (nonatomic, strong, readonly) DMEGuestConsentManager *guestConsentManager;
@property (nonatomic, strong, nullable) DMEPreConsentViewController *preconsentViewController;
@property (nonatomic, strong, nullable) id<DMEDataRequest> scope;
@property (nonatomic, strong, nullable) DMEFileListCache *fileCache;
@property (nonatomic, readonly) DMEFileSyncStatus syncStatus;
@property (nonatomic, strong, nullable) void (^sessionDataCompletion)(NSError * _Nullable);
@property (nonatomic, strong, nullable) void (^sessionContentHandler)(DMEFile * _Nullable file, NSError * _Nullable error);
@property (nonatomic) BOOL fetchingSessionData;
@property (nonatomic) DMEFileList *sessionFileList;

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
        _fileCache = [DMEFileListCache new];
        _fetchingSessionData = NO;
    }
    
    return self;
}

#pragma mark - Validation

- (nullable NSError *)validateClient
{
    if (!((DMEPullConfiguration *)self.configuration).privateKeyHex)
    {
        return [NSError sdkError:SDKErrorNoPrivateKeyHex];
    }
    
    return [super validateClient];
}

#pragma mark - Authorization

- (void)authorizeWithCompletion:(nonnull DMEAuthorizationCompletion)completion
{
    [self authorizeWithScope:nil completion:completion];
}

- (void)authorizeWithScope:(id<DMEDataRequest>)scope completion:(nonnull DMEAuthorizationCompletion)completion
{
    // Validation
    NSError *validationError = [self validateClient];
    if (validationError != nil)
    {
        completion(nil, validationError);
        return;
    }
    
    if (((DMEPullConfiguration *)self.configuration).guestEnabled)
    {
        [self authorizeGuestWithScope:scope completion:completion];
    }
    else
    {
        [self authorizeNativeWithScope:scope completion:completion];
    }
}

- (void)authorizeNativeWithScope:(id<DMEDataRequest>)scope completion:(nonnull DMEAuthorizationCompletion)completion
{
    // Get session
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithScope:scope completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (session == nil)
        {
            // Notify on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *errorToReport = error ?: [NSError authError:AuthErrorGeneral];
                completion(nil, errorToReport);
                return;
            });
            return;
        }
        
        //begin authorization
        [strongSelf authorizeNativeWithCompletion:completion];
    }];
}

- (void)authorizeNativeWithCompletion:(nonnull DMEAuthorizationCompletion)completion
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
            completion(session, error);
        });
    }];
}

- (void)authorizeNative
{
    [self authorizeNativeWithScope:self.scope completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        [self executeCompletionWithSession:session error:error];
    }];
}

#pragma mark - Guest Authorization
DMEAuthorizationCompletion _authorizationCompletion;

- (void)setAuthorizationCompletion:(DMEAuthorizationCompletion)authorizationCompletion
{
    _authorizationCompletion = authorizationCompletion;
}

- (void)authorizeGuestWithScope:(id<DMEDataRequest>)scope completion:(DMEAuthorizationCompletion)completion
{
    if (![NSThread currentThread].isMainThread)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self authorizeGuestWithScope:scope completion:completion];
        });
        return;
    }
    
    if ([self.appCommunicator canOpenDMEApp])
    {
        [self authorizeNativeWithScope:scope completion:completion];
    }
    else
    {
        self.scope = scope;
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
    [self.sessionManager sessionWithScope:self.scope completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
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

- (void)executeCompletionWithSession:(DMESession * _Nullable )session error:(NSError * _Nullable)error
{
    if (![NSThread currentThread].isMainThread)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self executeCompletionWithSession:session error:error];
        });
        return;
    }
    
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
- (void)getFileListWithCompletion:(void (^)(DMEFileList * _Nullable fileList, NSError  * _Nullable error))completion
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
        DMEFileList *fileList = [DMEFileListDeserializer deserialize:data error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                NSLog(@"DigiMeSDK: Error deserializing file list. Session key: %@. Error: %@", self.sessionManager.currentSession.sessionKey, error.localizedDescription);
            }
            completion(fileList, error);
        });
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"DigiMeSDK: Error requesting file list. Session key: %@. Error: %@", self.sessionManager.currentSession.sessionKey, error.localizedDescription);
            completion(nil, error);
        });
    }];
}

#pragma mark - Sync Management
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
        NSLog(@"DigiMeSDK: Sync status - %@", self.sessionFileList.syncStatusString);
    }
    
    if (![self syncRunning] && !self.apiClient.isDownloadingFiles)
    {
        if (self.configuration.debugLogEnabled)
        {
            NSLog(@"DigiMeSDK: Finished fetching session data.");
        }
        
        [self completeSessionDataFetchWithError:nil];
        return;
    }
    else if (schedulePoll)
    {
        [self scheduleNextPoll];
    }
    
    if ([self syncRunning])
    {
        [self refreshFileList];
    }
}

- (void)refreshFileList
{
    if (self.configuration.debugLogEnabled)
    {
        NSLog(@"DigiMeSDK: Refreshing file list");
    }
    
    [self getFileListWithCompletion:^(DMEFileList * _Nullable fileList, NSError * _Nullable error) {
        
        if (fileList == nil)
        {
            [self completeSessionDataFetchWithError:error];
            return;
        }
        
        self.sessionFileList = fileList;
        NSArray <DMEFileListItem *> *newItems = [self.fileCache newItemsFromList:fileList.files];
        
        if (newItems.count > 0)
        {
            if (self.configuration.debugLogEnabled)
            {
                NSLog(@"DigiMeSDK: Found new files to sync: %@", @(newItems.count));
            }
            
            [self.fileCache cacheItems:newItems];
            NSArray *allFiles = [newItems valueForKey:@"name"];
            
            for (NSString *fileId in allFiles)
            {
                if (self.configuration.debugLogEnabled)
                {
                    NSLog(@"DigiMeSDK: Adding file to download queue: %@", fileId);
                }
                
                [self getSessionDataForFileWithId:fileId completion:self.sessionContentHandler];
            }
        }
    }];
}

- (void)scheduleNextPoll
{
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC));
    
    __weak __typeof(self)weakSelf = self;
    dispatch_after(delay, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf evaluateSessionDataFetchProgress:YES];
    });
}

- (BOOL)syncRunning
{
    @synchronized (self) {
        return self.syncStatus == DMEFileSyncStatusRunning || self.syncStatus == DMEFileSyncStatusPending || self.syncStatus == DMEFileSyncStatusUnknown;
    }
}

- (DMEFileSyncStatus)syncStatus
{
    if (self.sessionFileList)
    {
        return self.sessionFileList.syncStatus;
    }
    
    return DMEFileSyncStatusUnknown;
}

- (void)completeSessionDataFetchWithError:(NSError * _Nullable)error
{
    if (error)
    {
        NSLog(@"DigiMeSDK: Error complete session. Session key: %@. Error: %@", self.sessionManager.currentSession.sessionKey, error.localizedDescription);
    }
    
    if (self.sessionDataCompletion)
    {
        self.sessionDataCompletion(error);
        [self clearSessionData];
    }
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
    self.apiClient.delegate = nil;
}

#pragma mark - Get File Content

- (void)getSessionDataWithDownloadHandler:(DMEFileContentCompletion)fileContentHandler completion:(void (^)(NSError * _Nullable))completion
{
    
    if (self.fetchingSessionData)
    {
        NSLog(@"DigiMeSDK: Already fetching session data.");
        return;
    }
    
    [self.fileCache reset];
    self.sessionDataCompletion = completion;
    self.sessionContentHandler = fileContentHandler;
    self.fetchingSessionData = YES;
    self.apiClient.delegate = self;
    [self refreshFileList];
    [self scheduleNextPoll];
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
            NSLog(@"DigiMeSDK: Error retrieving file with id: %@. Session key: %@. Error: %@", fileId, self.sessionManager.currentSession.sessionKey, error.localizedDescription);
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
        NSLog(@"DigiMeSDK: Error processing file with id: %@. Session key: %@. Error: %@", fileId, self.sessionManager.currentSession.sessionKey, error.localizedDescription);
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
            NSLog(@"DigiMeSDK: Error retrieving accounts. Session key: %@. Error: %@", self.sessionManager.currentSession.sessionKey, error.localizedDescription);
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
