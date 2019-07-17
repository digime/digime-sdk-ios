//
//  DMERequestFactory.m
//  DigiMeSDK
//
//  Created on 30/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMERequestFactory.h"
#import "DMEDataRequestSerializer.h"
#import "NSData+DMECrypto.h"

static NSString * const kDigiMeAPIVersion = @"v1.3";

@interface DMERequestFactory()

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong, readwrite) DMEClientConfiguration *config;
@property (nonatomic, strong) NSDictionary *sdkAgent;

@end

@implementation DMERequestFactory

#pragma mark - Initialization

- (instancetype)initWithConfiguration:(DMEClientConfiguration *)configuration
{
    self = [super init];
    if (self)
    {
        _config = configuration;
    }
    
    return self;
}

#pragma mark - Public

- (NSURLRequest *)sessionRequestWithAppId:(NSString *)appId contractId:(NSString *)contractId scope:(nullable id<DMEDataRequest>)scope
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/session", self.baseUrlPath]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    
    NSMutableDictionary *postKeys = [NSMutableDictionary new];
    postKeys[@"appId"] = appId;
    postKeys[@"contractId"] = contractId;
    postKeys[@"sdkAgent"] = self.sdkAgent;
    postKeys[@"accept"] = @{ @"compression" : @"gzip" };
    
    if (scope != nil)
    {
        NSDictionary *serializedScope = [DMEDataRequestSerializer serialize:scope];
        
        if (serializedScope != nil)
        {
            postKeys[scope.context] = serializedScope;
        }
    }
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postKeys options:0 error:nil];
    
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    return request;
}

- (NSURLRequest *)fileListRequestWithSessionKey:(NSString *)sessionKey
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query/%@", self.baseUrlPath, sessionKey]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    [request setHTTPMethod:@"GET"];
    return request;
}

- (NSURLRequest *)fileRequestWithId:(NSString *)fileId sessionKey:(NSString *)sessionKey
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query/%@/%@", self.baseUrlPath, sessionKey, fileId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    [request setHTTPMethod:@"GET"];
    return request;
}

- (NSURLRequest *)pushRequestWithPostboxId:(NSString *)postboxId payload:(NSData *)data headerParameters:(NSDictionary *)headers
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/postbox/%@", self.baseUrlPath, postboxId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.globalTimeout];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [self generateBoundaryString];
    NSString *metadata = [[headers[@"metadata"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString *symmetricalKey = [[headers[@"symmetricalKey"] stringByReplacingOccurrencesOfString:@"\n" withString:@""]stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:headers[@"sessionKey"] forHTTPHeaderField: @"sessionKey"];
    [request setValue:symmetricalKey forHTTPHeaderField: @"symmetricalKey"];
    [request setValue:headers[@"iv"] forHTTPHeaderField: @"iv"];
    [request setValue:metadata forHTTPHeaderField: @"metadata"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: multipart/form-data\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n\r\n", @"file", @"file"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (data)
    {
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    return request;

}

- (NSString *)generateBoundaryString {
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

- (NSString *)baseUrl
{
    return self.config.baseUrl;
}

- (NSString *)baseUrlPath
{
    return [NSString stringWithFormat:@"%@%@/permission-access", self.baseUrl, kDigiMeAPIVersion];
}

- (NSDictionary *)sdkAgent
{
    if (_sdkAgent == nil)
    {
        NSString *sdkVersion = [[NSBundle bundleForClass:self.class] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        NSString *sdkName = @"ios";
        _sdkAgent = @{
                      @"name": sdkName,
                      @"version": sdkVersion,
                      };
    }
    
    return _sdkAgent;
}

@end
