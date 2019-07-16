//
//  DMEClient.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEAPIClient.h"
#import "DMEClient.h"
#import "CAFilesDeserializer.h"
#import "CASessionManager.h"
#import "DMECrypto.h"
#import "DMEValidator.h"
#import "DMEAppCommunicator.h"
#import "DMEAuthorizationManager.h"
#import "DMEClient+Private.h"
#import "DMEDataUnpacker.h"
#import <DigiMeSDK/DigiMeSDK-Swift.h>

@implementation DMEClient
@synthesize privateKeyHex = _privateKeyHex;

#pragma mark - Initialization

+ (DMEClient *)sharedClient
{
    static DMEClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    
    return sharedClient;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _clientConfiguration = [DMEClientConfiguration new];
        _apiClient = [[DMEAPIClient alloc] initWithConfig:_clientConfiguration];
        _sessionManager = [[CASessionManager alloc] initWithApiClient:_apiClient];
        _crypto = [DMECrypto new];
        _decryptsData = YES;
        
        // Configure mercury appCommunicator.
        _appCommunicator = [DMEAppCommunicator new];
        DMEAuthorizationManager *authMgr = [[DMEAuthorizationManager alloc] initWithAppCommunicator:_appCommunicator];
        [_appCommunicator addCallbackHandler:authMgr];
        _authManager = authMgr;
    }
    
    return self;
}

#pragma mark - Authorization

- (void)authorize
{
    [self authorizeWithScope:nil completion:nil];
}

- (void)authorizeWithScope:(id<CADataRequest>)scope
{
    [self authorizeWithScope:scope completion:nil];
}

- (void)authorizeWithCompletion:(nullable AuthorizationCompletionBlock)authorizationCompletion
{
    [self authorizeWithScope:nil completion:authorizationCompletion];
}

- (void)authorizeWithScope:(id<CADataRequest>)scope completion:(nullable AuthorizationCompletionBlock)authorizationCompletion
{
    // Validation
    NSError *validationError = [self validateClient];
    if (validationError != nil)
    {
        if (authorizationCompletion)
        {
            authorizationCompletion(nil, validationError);
        }
        else if ([self.authorizationDelegate respondsToSelector:@selector(sessionCreateFailed:)])
        {
            [self.authorizationDelegate sessionCreateFailed:validationError];
        }
        
        return;
    }
    
    //get session
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithScope:scope completion:^(CASession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (session == nil)
        {
            // Notify on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *errorToReport = error ?: [NSError authError:AuthErrorGeneral];
                if (authorizationCompletion)
                {
                    authorizationCompletion(nil, errorToReport);
                    return;
                }
                
                // No completion block, so notify via delegate
                if ([strongSelf.authorizationDelegate respondsToSelector:@selector(sessionCreateFailed:)])
                {
                    NSError *errorToReport = error ?: [NSError authError:AuthErrorGeneral];
                    [strongSelf.authorizationDelegate sessionCreateFailed:errorToReport];
                }
            });
            return;
        }
        
        // Can only notify session creation success via delegate, not completion block
        if ([strongSelf.authorizationDelegate respondsToSelector:@selector(sessionCreated:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.authorizationDelegate sessionCreated:session];
            });
        }
        
        //begin authorization
        [strongSelf userAuthorizationWithCompletion:authorizationCompletion];
    }];
}

- (nullable NSError *)validateClient
{
    if (!self.appId || [self.appId isEqualToString:@"YOUR_APP_ID"])
    {
        return [NSError sdkError:SDKErrorNoAppId];
    }
    
    NSArray *urlTypes = NSBundle.mainBundle.infoDictionary[@"CFBundleURLTypes"];
    NSArray *urlSchemes = [[urlTypes valueForKey:@"CFBundleURLSchemes"] valueForKeyPath: @"@unionOfArrays.self"];
    NSString *expectedUrlScheme = [NSString stringWithFormat:@"digime-ca-%@", self.appId];
    if (![urlSchemes containsObject:expectedUrlScheme])
    {
        return [NSError sdkError:SDKErrorNoURLScheme];
    }
    
    if (!self.privateKeyHex)
    {
        return [NSError sdkError:SDKErrorNoPrivateKeyHex];
    }
    
    if (!self.contractId || [self.contractId isEqualToString:@"YOUR_CONTRACT_ID"])
    {
        return [NSError sdkError:SDKErrorNoContract];
    }
    
    if (![DMEValidator validateContractId:self.contractId])
    {
        return [NSError sdkError:SDKErrorInvalidContract];
    }
    
    return nil;
}

- (void)userAuthorizationWithCompletion:(nullable AuthorizationCompletionBlock)authorizationCompletion
{
    __weak __typeof(self)weakSelf = self;
    [self.authManager beginAuthorizationWithCompletion:^(CASession * _Nullable session, NSError * _Nullable error) {
        
        //notify on main thread.
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.clientConfiguration.debugLogEnabled)
        {
            NSLog(@"[DMEClient] isMain thread: %@", ([NSThread currentThread].isMainThread ? @"YES" : @"NO"));
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (authorizationCompletion)
            {
                authorizationCompletion(session, error);
                return;
            }
            
            // No completion block, so notify via delegate
            if (error)
            {
                if ([error.domain isEqualToString:DME_AUTHORIZATION_ERROR] &&
                    error.code == AuthErrorCancelled &&
                    [strongSelf.authorizationDelegate respondsToSelector:@selector(authorizeDenied:)])
                {
                    [strongSelf.authorizationDelegate authorizeDenied:error];
                }
                else if ([strongSelf.authorizationDelegate respondsToSelector:@selector(authorizeFailed:)])
                {
                    [strongSelf.authorizationDelegate authorizeFailed:error];
                }
            }
            else if ([strongSelf.authorizationDelegate respondsToSelector:@selector(authorizeSucceeded:)])
            {
                [strongSelf.authorizationDelegate authorizeSucceeded:session];
            }
        });
    }];
}

#pragma mark - Get File List

- (void)getFileList
{
    [self getFileListWithCompletion:nil];
}

- (void)getFileListWithCompletion:(FileListCompletionBlock)completion
{
    //validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession];
        if (completion)
        {
            completion(nil, error);
        }
        else if ([self.downloadDelegate respondsToSelector:@selector(clientFailedToRetrieveFileList:)])
        {
            [self.downloadDelegate clientFailedToRetrieveFileList:error];
        }
        
        return;
    }
    
    //initiate file list request
    __weak __typeof(DMEClient *)weakSelf = self;
    [self.apiClient requestFileListWithSuccess:^(NSData * _Nonnull data) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;
        
        NSError *error;
        CAFiles *files = [CAFilesDeserializer deserialize:data error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion(files, error);
            }
            else if (error)
            {
                if ([strongSelf.downloadDelegate respondsToSelector:@selector(clientFailedToRetrieveFileList:)])
                {
                    [strongSelf.downloadDelegate clientFailedToRetrieveFileList:error];
                }
            }
            else if ([strongSelf.downloadDelegate respondsToSelector:@selector(clientRetrievedFileList:)])
            {
                [strongSelf.downloadDelegate clientRetrievedFileList:files];
            }
        });
    } failure:^(NSError * _Nonnull error) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion(nil, error);
            }
            else if ([strongSelf.downloadDelegate respondsToSelector:@selector(clientFailedToRetrieveFileList:)])
            {
                [strongSelf.downloadDelegate clientFailedToRetrieveFileList:error];
            }
        });
    }];
}

#pragma mark - Private Key

- (void)setPrivateKeyHex:(NSString *)privateKeyHex
{
    [self.crypto addPrivateKeyHex:privateKeyHex];
    _privateKeyHex = privateKeyHex;
}

#pragma mark - Get File Content

- (void)getFileWithId:(NSString *)fileId
{
    [self getFileWithId:fileId completion:nil];
}

- (void)getFileWithId:(NSString *)fileId completion:(FileContentCompletionBlock)completion
{
    //ensures this method cannot be called with completion *AND* no data decryption
    if (completion != nil && !self.decryptsData)
    {
        NSError *sdkError = [NSError sdkError:SDKErrorEncryptedDataCallback];
        completion(nil, sdkError);
        return;
    }
    
    //validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession];
        
        if (completion)
        {
            CAFile *file = [[CAFile alloc] initWithFileId:fileId fileContent:[NSData data] fileMetadata:nil];
            completion(file, error);
        }
        else if ([self.downloadDelegate respondsToSelector:@selector(fileRetrieveFailed:error:)])
        {
            [self.downloadDelegate fileRetrieveFailed:fileId error:error];
        }
        
        return;
    }
    
    //initiate file content request
    __weak __typeof(DMEClient *)weakSelf = self;
    [self.apiClient requestFileWithId:fileId success:^(NSData * _Nonnull data) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;

        if (!strongSelf.decryptsData)
        {
            if ([strongSelf.downloadDelegate respondsToSelector:@selector(dataRetrieved:fileId:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.downloadDelegate dataRetrieved:data fileId:fileId];
                });
            }
            
            //completion at this point will be nil.
            return;
        }
        
        [strongSelf processFileData:data fileId:fileId completion:completion];
        
    } failure:^(NSError * _Nonnull error) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (completion)
            {
                completion(nil, error);
            }
            else if ([strongSelf.downloadDelegate respondsToSelector:@selector(fileRetrieveFailed:error:)])
            {
                [strongSelf.downloadDelegate fileRetrieveFailed:fileId error:error];
            }
        });
    }];
}

- (void)processFileData:(NSData *)data fileId:(NSString *)fileId completion:(FileContentCompletionBlock)completion
{
    CAFile *file;
    NSError *error;
    CAFileMetadata *metadata;
    NSData *unpackedData = [DMEDataUnpacker unpackData:data resolvedMetadata:&metadata error:&error];
    if (unpackedData != nil)
    {
        file = [[CAFile alloc] initWithFileId:fileId fileContent:unpackedData fileMetadata:metadata];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (completion)
        {
            completion(file, error);
        }
        else if (error)
        {
            if ([self.downloadDelegate respondsToSelector:@selector(fileRetrieveFailed:error:)])
            {
                [self.downloadDelegate fileRetrieveFailed:fileId error:error];
            }
        }
        else if ([self.downloadDelegate respondsToSelector:@selector(fileRetrieved:)])
        {
            [self.downloadDelegate fileRetrieved:file];
        }
        
    });
}


#pragma mark - Accounts
- (void)getAccounts
{
    [self getAccountsWithCompletion:nil];
}

- (void)getAccountsWithCompletion:(AccountsCompletionBlock)completion
{
    //ensures this method cannot be called with completion *AND* no data decryption
    if (completion != nil && !self.decryptsData)
    {
        NSError *sdkError = [NSError sdkError:SDKErrorEncryptedDataCallback];
        completion(nil, sdkError);
        return;
    }
    
    //validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession];
        
        if (completion)
        {
            completion(nil, error);
        }
        else if ([self.downloadDelegate respondsToSelector:@selector(accountsRetrieveFailed:)])
        {
            [self.downloadDelegate accountsRetrieveFailed:error];
        }
        
        return;
    }
    
    //initiate accounts request
    __weak __typeof(DMEClient *)weakSelf = self;
    [self.apiClient requestFileWithId:@"accounts.json" success:^(NSData * _Nonnull data) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;
        
        if (!strongSelf.decryptsData)
        {
            if ([strongSelf.downloadDelegate respondsToSelector:@selector(accountsDataRetrieved:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.downloadDelegate accountsDataRetrieved:data];
                });
            }
            
            //completion at this point will be nil.
            return;
        }
        
        CAAccounts *accounts;
        NSError *error;
        NSData *unpackedData = [DMEDataUnpacker unpackData:data resolvedMetadata:NULL error:&error];
        if (unpackedData != nil)
        {
            accounts = [CAAccounts deserialize:unpackedData error:&error];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (completion)
            {
                completion(accounts, error);
            }
            else if (error)
            {
                if ([strongSelf.downloadDelegate respondsToSelector:@selector(accountsRetrieveFailed:)])
                {
                    [strongSelf.downloadDelegate accountsRetrieveFailed:error];
                }
            }
            else if ([strongSelf.downloadDelegate respondsToSelector:@selector(accountsRetrieved:)])
            {
                [strongSelf.downloadDelegate accountsRetrieved:accounts];
            }
            
        });
        
    } failure:^(NSError * _Nonnull error) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion(nil, error);
            }
            else if ([strongSelf.downloadDelegate respondsToSelector:@selector(accountsRetrieveFailed:)])
            {
                [strongSelf.downloadDelegate accountsRetrieveFailed:error];
            }
        });
    }];
    
}

#pragma mark - Setters

-(void)setClientConfiguration:(DMEClientConfiguration *)clientConfiguration
{
    self.apiClient.config = clientConfiguration;
}

#pragma mark - Digi.me redirect handling

- (BOOL)openURL:(NSURL *)url options:(NSDictionary *)options
{
    return [self.appCommunicator openURL:url options:options];
}

- (BOOL)canOpenDigiMeApp
{
    return [self.appCommunicator canOpenDigiMeApp];
}

- (void)viewReceiptInDigiMeAppWithError:(NSError * __autoreleasing * __nullable)error
{
    // Check we have both the appId and clientId, required for this.
    if (!self.contractId.length)
    {
        *error = [NSError sdkError:SDKErrorNoContract];
        return;
    }
    
    if (!self.appId.length)
    {
        *error = [NSError sdkError:SDKErrorNoAppId];
        return;
    }
    
    // Check the digime app can be opened (ie is installed).
    if (![self canOpenDigiMeApp])
    {
        *error = [NSError sdkError:SDKErrorDigiMeAppNotFound];
        return;
    }
    
    // Prerequesits cleared, build URL.
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"digime";
    components.host = @"receipt";
    components.queryItems = @[[NSURLQueryItem queryItemWithName:@"contractid" value:self.contractId],
                              [NSURLQueryItem queryItemWithName:@"appid" value:self.appId]];
    
    NSURL *deeplinkingURL = components.URL;
    [[UIApplication sharedApplication] openURL:deeplinkingURL options:@{} completionHandler:nil];
}

#pragma mark - Debug

- (NSDictionary <NSString *, id> *)metadata
{
    return [[self.sessionManager currentSession] metadata];
}



@end
