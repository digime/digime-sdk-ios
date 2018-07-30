//
//  DMEAPIClient.m
//  DigiMeSDK
//
//  Created on 26/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMEAPIClient.h"
#import "DMEOperation.h"
#import "NSString+DMECrypto.h"
#import "DMECrypto.h"
#import "DMECertificatePinner.h"
#import "DMEClient.h"
#import "DMERequestFactory.h"

static const NSString* kDigimeConsentAccessVersion              = @"1.0.0";
static const NSString* kDigimeConsentAccessPathSessionKeyCreate = @"v1/permission-access/session";
static const NSString* kDigimeConsentAccessPathDataGet          = @"v1/permission-access/query";
static const NSString* kDownloadQueue                           = @"kDownloadQueue";

typedef void(^HandlerBlock)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface DMEAPIClient() <NSURLSessionDelegate>

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) DMECrypto *crypto;
@property (nonatomic, strong) DMECertificatePinner *certPinner;
@property (nonatomic, strong) DMEClient *client;
@property (nonatomic, strong) DMERequestFactory *requestFactory;

@end

@implementation DMEAPIClient

@synthesize config = _config;

#pragma mark - Initialization

- (instancetype)initWithConfig:(DMEClientConfiguration *)config
{
    self = [super init];
    
    if (self)
    {
        _config = config;
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    _crypto = [DMECrypto new];
    _certPinner = [DMECertificatePinner new];
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = _config.maxConcurrentRequests;
    
    [_queue addObserver:self
                     forKeyPath:NSStringFromSelector(@selector(operationCount))
                        options:NSKeyValueObservingOptionNew
                context:&kDownloadQueue];
}

#pragma mark - Lifecycle

- (void)dealloc
{
    @try {
        [self.queue removeObserver:self
                                forKeyPath:NSStringFromSelector(@selector(operationCount))
                                   context:&kDownloadQueue];
    }
    @catch (NSException * __unused exception) {}
    
    [self.queue cancelAllOperations];
}

- (void)cancelAllOperations
{
    [self.queue cancelAllOperations];
    self.queue = nil;
    
    for (NSOperation* o in [[NSOperationQueue mainQueue] operations])
    {
        [o cancel];
    }
    
    [self initialize];
}

#pragma mark - Session

- (void)requestSessionWithSuccess:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    NSDictionary *headers = [self defaultHeaders];
    NSURLSession *session = [self sessionWithHeaders:headers];
    NSURLRequest *request = [self.requestFactory sessionRequestWithAppId:self.client.appId contractId:self.client.contractId];
    HandlerBlock defaultHandler = [self defaultResponseHandlerForDomain:DME_AUTHORIZATION_ERROR success:success failure:failure];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:defaultHandler];
    
    [dataTask resume];
}

#pragma mark - File List

- (void)requestFileListWithSuccess:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    NSDictionary *headers = [self defaultHeaders];
    NSURLSession *session = [self sessionWithHeaders:headers];
    NSURLRequest *request = [self.requestFactory fileListRequestWithSessionKey:self.client.sessionManager.currentSession.sessionKey];
    HandlerBlock defaultHandler = [self defaultResponseHandlerForDomain:DME_API_ERROR success:success failure:failure];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:defaultHandler];
    
    [dataTask resume];
}

#pragma mark - File Content

- (void)requestFileWithId:(NSString *)fileId success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    DMEOperation *operation = [[DMEOperation alloc] initWithConfiguration:self.config];

    __weak __typeof(DMEOperation *) weakOperation = operation;
    
    operation.workBlock = ^{
        NSDictionary *headers = [self defaultHeaders];
        NSURLSession *session = [self sessionWithHeaders:headers];
        NSURLRequest *request = [self.requestFactory fileRequestWithId:fileId sessionKey:self.client.sessionManager.currentSession.sessionKey];
        HandlerBlock defaultHandler = [self defaultResponseHandlerForDomain:DME_API_ERROR success:success failure:failure];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            
            if (httpResp.statusCode == 404)
            {
                if (![weakOperation retry])
                {
                    defaultHandler(data, response, error);
                    [weakOperation finishDoingWork];
                }
                
                //return if operation will retry
                //return if operation cannot retry
                return;
            }
            
            defaultHandler(data, response, error);
            [weakOperation finishDoingWork];
        }];
        
        [dataTask resume];
    };
    
    [self.queue addOperation:operation];
}

#pragma mark - Private


/**
 Create NSURLSession object with headers.

 @param headers NSDictionary request headers
 @return NSURLSession
 */
- (NSURLSession *)sessionWithHeaders:(NSDictionary *)headers
{
    NSURLSessionConfiguration*  configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPAdditionalHeaders = headers;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    return session;
}


/**
 Convenience method.

 @return NSDictionary default headers required for API calls.
 */
- (NSDictionary *)defaultHeaders
{
    return @{ @"Content-Type" : @"application/json",
              @"Accept" : @"application/json"
              };
}


/**
 Default handler for API responses.

 @param domain NSString - error domain to use if an error has been encountered
 @param success success block
 @param failure failure block
 @return HandlerBlock
 */
- (HandlerBlock)defaultResponseHandlerForDomain:(NSString *)domain success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    HandlerBlock handlerBlock = ^void(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
        
        if (httpResp.statusCode == 202 || httpResp.statusCode == 200)
        {
            if (data)
            {
                success(data);
            }
            return;
        }
        
        if (!error)
        {
            //check response message
            NSError *parsingError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parsingError];
            if (!responseDictionary)
            {
                failure(parsingError);
                return;
            }
            
            NSDictionary *errorDict = responseDictionary[@"error"];
            
            if (errorDict)
            {
                NSError *apiError = [NSError errorWithDomain:domain code:httpResp.statusCode userInfo:errorDict];
                failure(apiError);
            }
        }
        else
        {
            failure(error);
        }
    };
    
    return handlerBlock;
}

#pragma mark - Convenicence
- (DMEClient *)client
{
    return [DMEClient sharedClient];
}

- (DMERequestFactory *)requestFactory
{
    if (!_requestFactory)
    {
        _requestFactory = [[DMERequestFactory alloc] initWithConfiguration:self.config];
    }
    
    return _requestFactory;
}

- (DMEClientConfiguration *)config
{
    if (!_config)
    {
        _config = self.client.clientConfiguration;
    }
    
    return _config;
}

-(void)setConfig:(DMEClientConfiguration *)config
{
    _config = config;
    
    self.queue.maxConcurrentOperationCount = _config.maxConcurrentRequests;
    self.requestFactory = [[DMERequestFactory alloc] initWithConfiguration:_config];
}

#pragma mark - Key Value Observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &kDownloadQueue && [keyPath isEqualToString:NSStringFromSelector(@selector(operationCount))])
    {
        if ([change[NSKeyValueChangeNewKey] integerValue] == 0)
        {
            NSLog(@"[DMEAPIClient] Queued downloads completed.");
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark NSURLSession delegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition challengeDisposition = NSURLSessionAuthChallengePerformDefaultHandling;
    
    if ([[[challenge protectionSpace] host] isEqualToString:[NSURL URLWithString:self.requestFactory.baseUrl].host])
    {
        //certificate pinning
        challengeDisposition = [self.certPinner authenticateURLChallenge:challenge];
    }
    
    completionHandler(challengeDisposition, nil);
}

@end
