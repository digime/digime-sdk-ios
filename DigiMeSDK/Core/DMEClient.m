//
//  DMEClient.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMEClient.h"
#import "DMEAuthorizationManager.h"
#import "CAFilesDeserializer.h"
#import "CADataDecryptor.h"
#import "DMECrypto.h"

@interface DMEClient()

@property (nonatomic, strong) DMEAuthorizationManager *authManager;
@property (nonatomic, strong, readwrite) CASessionManager *sessionManager;
@property (nonatomic, strong, readwrite) DMEAPIClient *apiClient;
@property (nonatomic, strong) DMECrypto *crypto;

@end

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
        _authManager = [DMEAuthorizationManager new];
        _clientConfiguration = [DMEClientConfiguration new];
        _apiClient = [[DMEAPIClient alloc] initWithConfig:_clientConfiguration];;
        _sessionManager = [CASessionManager new];
        _crypto = [DMECrypto new];
    }
    
    return self;
}

#pragma mark - Authorization

- (void)authorize
{
    [self authorizeWithCompletion:nil];
}

- (void)authorizeWithCompletion:(nullable AuthorizationCompletionBlock)authorizationCompletion
{
    //private key validation
    if (!self.privateKeyHex)
    {
        NSError *error = [NSError authError:AuthErrorPrivateHex];
        if (authorizationCompletion)
        {
            authorizationCompletion(nil, error);
        }
        
        if ([self.delegate respondsToSelector:@selector(authorizeFailed:)])
        {
            [self.delegate authorizeFailed:error];
        }
        
        return;
    }
    
    //get session
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithCompletion:^(CASession * _Nullable session, NSError * _Nullable error) {
        
        //begin authorization
        [weakSelf.authManager beginAuthorizationWithCompletion:^(CASession * _Nullable session, NSError * _Nullable error) {
            
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
                }
                
                if (error)
                {
                    if ([error.domain isEqualToString:DME_AUTHORIZATION_ERROR] && error.code == AuthErrorCancelled && [strongSelf.delegate respondsToSelector:@selector(authorizeDenied:)])
                    {
                        [strongSelf.delegate authorizeDenied:error];
                    }
                    else if ([strongSelf.delegate respondsToSelector:@selector(authorizeFailed:)])
                    {
                        [strongSelf.delegate authorizeFailed:error];
                    }
                }
                else if ([strongSelf.delegate respondsToSelector:@selector(authorizeSucceeded:)])
                {
                    [strongSelf.delegate authorizeSucceeded:session];
                }
            });
        }];
        
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
        
        if ([self.delegate respondsToSelector:@selector(clientFailedToRetrieveFileList:)])
        {
            [self.delegate clientFailedToRetrieveFileList:error];
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
            
            if (error)
            {
                if ([strongSelf.delegate respondsToSelector:@selector(clientFailedToRetrieveFileList:)])
                {
                    [strongSelf.delegate clientFailedToRetrieveFileList:error];
                }
            }
            else if ([strongSelf.delegate respondsToSelector:@selector(clientRetrievedFileList:)])
            {
                [strongSelf.delegate clientRetrievedFileList:files];
            }
        });
    } failure:^(NSError * _Nonnull error) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion(nil, error);
            }
            
            if ([strongSelf.delegate respondsToSelector:@selector(clientFailedToRetrieveFileList:)])
            {
                [strongSelf.delegate clientFailedToRetrieveFileList:error];
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
    //validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession];
        
        if (completion)
        {
            CAFile *file = [[CAFile alloc] initWithFileId:fileId];
            completion(file, error);
        }
        
        if ([self.delegate respondsToSelector:@selector(fileRetrieveFailed:error:)])
        {
            [self.delegate fileRetrieveFailed:fileId error:error];
        }
        return;
    }
    
    //initiate file content request
    __weak __typeof(DMEClient *)weakSelf = self;
    [self.apiClient requestFileWithId:fileId success:^(NSData * _Nonnull data) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;
        
        NSError *error;
        NSData *decryptedData = [CADataDecryptor decrypt:data error:&error];
        CAFile *file;
        
        if (!error)
        {
            file = [CAFile deserialize:decryptedData fileId:fileId error:&error];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (completion)
            {
                completion(file, error);
            }
            
            if (error)
            {
                if ([strongSelf.delegate respondsToSelector:@selector(fileRetrieveFailed:error:)])
                {
                    [strongSelf.delegate fileRetrieveFailed:fileId error:error];
                }
            }
            else if ([strongSelf.delegate respondsToSelector:@selector(fileRetrieved:)])
            {
                [strongSelf.delegate fileRetrieved:file];
            }
            
        });
        
    } failure:^(NSError * _Nonnull error) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion(nil, error);
            }
            
            if ([strongSelf.delegate respondsToSelector:@selector(fileRetrieveFailed:error:)])
            {
                [strongSelf.delegate fileRetrieveFailed:fileId error:error];
            }
        });
    }];
}

#pragma mark - Accounts
- (void)getAccounts
{
    [self getAccountsWithCompletion:nil];
}

- (void)getAccountsWithCompletion:(AccountsCompletionBlock)completion
{
    //validate session
    if (![self.sessionManager isSessionValid])
    {
        NSError *error = [NSError authError:AuthErrorInvalidSession];
        
        if (completion)
        {
            completion(nil, error);
        }
        
        if ([self.delegate respondsToSelector:@selector(accountsRetrieveFailed:)])
        {
            [self.delegate accountsRetrieveFailed:error];
        }
        return;
    }
    
    //initiate accounts request
    __weak __typeof(DMEClient *)weakSelf = self;
    [self.apiClient requestFileWithId:@"accounts.json" success:^(NSData * _Nonnull data) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;
        
        NSError *error;
        NSData *decryptedData = [CADataDecryptor decrypt:data error:&error];
        CAAccounts *accounts;
        
        if (!error)
        {
            accounts = [CAAccounts deserialize:decryptedData error:&error];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (completion)
            {
                completion(accounts, error);
            }
            
            if (error)
            {
                if ([strongSelf.delegate respondsToSelector:@selector(accountsRetrieveFailed:)])
                {
                    [strongSelf.delegate accountsRetrieveFailed:error];
                }
            }
            else if ([strongSelf.delegate respondsToSelector:@selector(accountsRetrieved:)])
            {
                [strongSelf.delegate accountsRetrieved:accounts];
            }
            
        });
        
    } failure:^(NSError * _Nonnull error) {
        __strong __typeof(DMEClient *)strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion(nil, error);
            }
            
            if ([strongSelf.delegate respondsToSelector:@selector(accountsRetrieveFailed:)])
            {
                [strongSelf.delegate accountsRetrieveFailed:error];
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
    return [self.authManager openURL:url options:options];
}

- (BOOL)canOpenDigiMeApp
{
    return [self.authManager canOpenDigiMeApp];
}

@end
