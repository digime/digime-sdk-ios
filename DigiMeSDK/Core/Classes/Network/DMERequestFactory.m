//
//  DMERequestFactory.m
//  DigiMeSDK
//
//  Created on 30/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMERequestFactory.h"
#import "CADataRequestSerializer.h"
#import "NSData+DMECrypto.h"

@import MobileCoreServices;

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

- (NSURLRequest *)sessionRequestWithAppId:(NSString *)appId contractId:(NSString *)contractId scope:(nullable id<CADataRequest>)scope
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
        NSDictionary *serializedScope = [CADataRequestSerializer serialize:scope];
        
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
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: multipart/form-data\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@\n\n", @"file", @"file"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (data)
    {
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    return request;
}

- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                              file:(NSData *)data
{
    NSMutableData *httpBody = [NSMutableData data];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\n\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    NSString *mimetype = @"application/json";
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; file=\"%@\"\n", [data hexString]] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\n\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:data];
    [httpBody appendData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}

- (NSString *)mimeTypeForPath:(NSString *)path {
    // get mime type for an extension using MobileCoreServices.framework
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
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
