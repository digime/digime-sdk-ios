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
#import "DMESessionManager.h"
#import "DMECrypto.h"
#import "DMEValidator.h"
#import "DMEAppCommunicator.h"
#import "DMENativeConsentManager.h"
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
        _sessionManager = [[DMESessionManager alloc] initWithApiClient:_apiClient];
        _crypto = [DMECrypto new];
        _decryptsData = YES;
        
        // Configure mercury appCommunicator.
        _appCommunicator = [DMEAppCommunicator new];
        DMENativeConsentManager *authMgr = [[DMENativeConsentManager alloc] initWithAppCommunicator:_appCommunicator];
        [_appCommunicator addCallbackHandler:authMgr];
        _authManager = authMgr;
    }
    
    return self;
}

#pragma mark - Authorization

- (void)authorizeWithCompletion:(nonnull AuthorizationCompletionBlock)authorizationCompletion
{
    [self authorizeWithScope:nil completion:authorizationCompletion];
}

- (void)authorizeWithScope:(id<CADataRequest>)scope completion:(nonnull AuthorizationCompletionBlock)authorizationCompletion
{
    // Validation
    NSError *validationError = [self validateClient];
    if (validationError != nil)
    {
        if (authorizationCompletion)
        {
            authorizationCompletion(nil, validationError);
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
            });
            return;
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

- (void)userAuthorizationWithCompletion:(nonnull AuthorizationCompletionBlock)authorizationCompletion
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
            
        });
    }];
}

#pragma mark - Get File List
- (void)getFileListWithCompletion:(FileListCompletionBlock)completion
{
    //validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession];
        
        completion(nil, error);
        
        return;
    }
    
    //initiate file list request
    [self.apiClient requestFileListWithSuccess:^(NSData * _Nonnull data) {
        
        NSError *error;
        CAFiles *files = [CAFilesDeserializer deserialize:data error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completion(files, error);
            
        });
    } failure:^(NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completion(nil, error);
            
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
        
        CAFile *file = [[CAFile alloc] initWithFileId:fileId fileContent:[NSData data] fileMetadata:nil];
        completion(file, error);
        
        return;
    }
    
    //initiate file content request
    __weak __typeof(DMEClient *)weakSelf = self;
    [self.apiClient requestFileWithId:fileId success:^(NSData * _Nonnull data) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;
        
        if (!strongSelf.decryptsData)
        {
            //completion at this point will be nil.
            return;
        }
        
        [strongSelf processFileData:data fileId:fileId completion:completion];
        
    } failure:^(NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completion(nil, error);
            
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
        
        completion(file, error);
        
    });
}


#pragma mark - Accounts

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
        
        completion(nil, error);
        
        return;
    }
    
    //initiate accounts request
    __weak __typeof(DMEClient *)weakSelf = self;
    [self.apiClient requestFileWithId:@"accounts.json" success:^(NSData * _Nonnull data) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;
        
        if (!strongSelf.decryptsData)
        {
            //completion at this point will be nil.
            return;
        }
        
        DMEAccounts *accounts;
        NSError *error;
        NSData *unpackedData = [DMEDataUnpacker unpackData:data resolvedMetadata:NULL error:&error];
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
