//
//  DMEAPIClient.m
//  DigiMeSDK
//
//  Created on 26/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEAPIClient.h"
#import "DMEAPIClient+Private.h"
#import "DMECertificatePinner.h"
#import "DMECrypto.h"
#import "DMEDataRequest.h"
#import "DMEOperation.h"
#import "DMERequestFactory.h"
#import "DMESessionManager.h"
#import "NSData+DMECrypto.h"
#import "NSString+DMECrypto.h"
#import "DMEStatusLogger.h"

static const NSString *kWorkQueue = @"kWorkQueue";

@interface DMEAPIClient() <NSURLSessionDelegate>

@property (nonatomic, strong, readonly) DMECertificatePinner *certPinner;

@end

@implementation DMEAPIClient

#pragma mark - Initialization

- (instancetype)initWithConfiguration:(id<DMEClientConfiguration>)configuration
{
    self = [super init];
    if (self)
    {
        _configuration = configuration;
        _certPinner = [DMECertificatePinner new];
        _requestFactory = [[DMERequestFactory alloc] initWithConfiguration:configuration];
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = configuration.maxConcurrentRequests;
        
        [_queue addObserver:self
                 forKeyPath:NSStringFromSelector(@selector(operationCount))
                    options:NSKeyValueObservingOptionNew
                    context:&kWorkQueue];
    }
    
    return self;
}

#pragma mark - Lifecycle

- (void)dealloc
{
    @try {
        [self.queue removeObserver:self
                        forKeyPath:NSStringFromSelector(@selector(operationCount))
                           context:&kWorkQueue];
    }
    @catch (NSException * __unused exception) {}
    
    [self.queue cancelAllOperations];
}

#pragma mark - Session

- (void)requestSessionWithScope:(nullable id<DMEDataRequest>)scope success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    NSDictionary *headers = [self defaultHeaders];
    NSURLSession *session = [self sessionWithHeaders:headers];
    NSURLRequest *request = [self.requestFactory sessionRequestWithAppId:self.configuration.appId contractId:self.configuration.contractId scope:scope];
    HandlerBlock defaultHandler = [self defaultResponseHandlerForDomain:DME_AUTHORIZATION_ERROR success:success failure:failure];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:defaultHandler];
    
    [dataTask resume];
}

#pragma mark - File List

- (void)requestFileListForSessionWithKey:(NSString *)sessionKey success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    NSDictionary *headers = [self defaultHeaders];
    NSURLSession *session = [self sessionWithHeaders:headers];
    NSURLRequest *request = [self.requestFactory fileListRequestWithSessionKey:sessionKey];
    HandlerBlock defaultHandler = [self defaultResponseHandlerForDomain:DME_API_ERROR success:success failure:failure];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:defaultHandler];
    
    [dataTask resume];
}

#pragma mark - File Content

- (void)requestFileWithId:(NSString *)fileId sessionKey:(NSString *)sessionKey success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    DMEOperation *operation = [[DMEOperation alloc] initWithConfiguration:self.configuration];

    __weak __typeof(DMEOperation *) weakOperation = operation;
    
    operation.workBlock = ^{
        NSDictionary *headers = [self defaultHeaders];
        NSURLSession *session = [self sessionWithHeaders:headers];
        NSURLRequest *request = [self.requestFactory fileRequestWithId:fileId sessionKey:sessionKey];
        HandlerBlock defaultHandler = [self defaultResponseHandlerForDomain:DME_API_ERROR success:success failure:failure];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
            
            if (weakOperation.isCancelled)
            {
                [weakOperation finishDoingWork];
                return;
            }
            
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

#pragma mark - Ongoing Access
- (void)requestPreauthorizationCodeWithBearer:(NSString *)jwtBearer success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    NSDictionary *headers = [self defaultHeaders];
    NSURLSession *session = [self sessionWithHeaders:headers];
    NSURLRequest *request = [self.requestFactory preAuthRequestWithBearer:jwtBearer];
    HandlerBlock defaultHandler = [self defaultResponseHandlerForDomain:DME_API_ERROR success:success failure:failure];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:defaultHandler];
    
    [dataTask resume];
}

- (void)requestValidationDataForPreAuthenticationCodeWithSuccess:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    NSDictionary *headers = [self defaultHeaders];
    NSURLSession *session = [self sessionWithHeaders:headers];
    NSURLRequest *request = [self.requestFactory preAuthValidationRequest];
    HandlerBlock defaultHandler = [self defaultResponseHandlerForDomain:DME_API_ERROR success:success failure:failure];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:defaultHandler];
    
    [dataTask resume];
}

- (void)requestAccessAndRefreshTokensWithBearer:(NSString *)jwtBearer success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    NSDictionary *headers = [self defaultHeaders];
    NSURLSession *session = [self sessionWithHeaders:headers];
    NSURLRequest *request = [self.requestFactory authRequestWithBearer:jwtBearer];
    HandlerBlock defaultHandler = [self defaultResponseHandlerForDomain:DME_API_ERROR success:success failure:failure];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:defaultHandler];
    
    [dataTask resume];
}

- (void)requestDataTriggerWithBearer:(NSString *)jwtBearer success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    NSDictionary *headers = [self defaultHeaders];
    NSURLSession *session = [self sessionWithHeaders:headers];
    NSURLRequest *request = [self.requestFactory dataTriggerRequestWithBearer:jwtBearer];
    HandlerBlock defaultHandler = [self defaultResponseHandlerForDomain:DME_API_ERROR success:success failure:failure];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:defaultHandler];
    
    [dataTask resume];
}

- (void)renewAccessTokenWithBearer:(NSString *)jwtBearer success:(void(^)(NSData *data))success failure:(void(^)(NSError *error))failure
{
    NSDictionary *headers = [self defaultHeaders];
    NSURLSession *session = [self sessionWithHeaders:headers];
    NSURLRequest *request = [self.requestFactory authRequestWithBearer:jwtBearer];
    HandlerBlock defaultHandler = [self defaultResponseHandlerForDomain:DME_API_ERROR success:success failure:failure];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:defaultHandler];
    
    [dataTask resume];
}

#pragma mark - Cancellation
- (void)cancelQueuedDownloads
{
    [self.queue cancelAllOperations];
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
        
        
        NSString *sdkStatusMessage = [DMEStatusLogger getSDKStatus:httpResp.allHeaderFields];
        
        if (sdkStatusMessage != nil) {
            NSLog(@"%@", sdkStatusMessage);
        }
        
        if (httpResp.statusCode >= 200 && httpResp.statusCode <= 299)
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
            NSError *apiError = [NSError errorWithDomain:domain code:httpResp.statusCode userInfo:errorDict];
            failure(apiError);
        }
        else
        {
            failure(error);
        }
    };
    
    return handlerBlock;
}

#pragma mark - Convenicence

- (NSString *)baseUrl
{
    return self.requestFactory.baseUrl;
}

- (BOOL)isDownloadingFiles
{
    return self.queue.operationCount > 0 && !self.queue.isSuspended;
}

#pragma mark - Key Value Observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &kWorkQueue && [keyPath isEqualToString:NSStringFromSelector(@selector(operationCount))])
    {
        if ([change[NSKeyValueChangeNewKey] integerValue] == 0)
        {
            NSLog(@"[DMEAPIClient] Queued downloads completed.");
            
            if ([self.delegate respondsToSelector:@selector(didFinishAllDownloads)])
            {
                [self.delegate didFinishAllDownloads];
            }
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
