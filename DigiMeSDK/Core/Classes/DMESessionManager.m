//
//  DMESessionManager.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMESessionManager.h"
#import "DMECryptoUtilities.h"
#import "DMEAPIClient.h"
#import "CASessionDeserializer.h"
#import "DMEClient+Private.h"

@interface DMESessionManager()

@property (nonatomic, strong, readonly) DMEAPIClient *apiClient;
@property (nonatomic, strong, readwrite) CASession *currentSession;

@end

@implementation DMESessionManager

#pragma mark - Public

- (instancetype)initWithApiClient:(DMEAPIClient *)apiClient
{
    self = [super init];
    if (self)
    {
        _apiClient = apiClient;
    }
    
    return self;
}

- (void)sessionWithScope:(id<DMEDataRequest>)scope completion:(AuthorizationCompletionBlock)completion
{
    //create new session. We always retrieve new session when requesting authorization
    [self invalidateCurrentSession];
    
    [self.apiClient requestSessionWithScope:scope success:^(NSData * _Nonnull data) {
        
        NSError *error;
        CASession *session = [CASessionDeserializer deserialize:data error:&error];
        
        self.currentSession = session;
        
        if (error != nil)
        {
            NSLog(@"[DMESessionManager] Failed to create session: %@", error.localizedDescription);
        }
        else if (session == nil)
        {
            //something unknown occurred.
            error = [NSError authError:AuthErrorGeneral];
        }
        
        completion(session, error);
        
    } failure:^(NSError * _Nonnull error) {
        
        if (error.code == 403 && [error.userInfo[@"code"] isEqualToString:@"SDKVersionInvalid"])
        {
            completion(nil, [NSError sdkError:SDKErrorInvalidVersion]);
            return;
        }

        completion(nil, error);
    }];
}

#pragma mark - Public

- (BOOL)isSessionValid
{
    return (self.currentSession && self.currentSession.expiryDate && [self.currentSession.expiryDate compare:[NSDate date]] == NSOrderedDescending && [self.currentSession.sessionId isEqualToString:self.client.contractId]);
}

- (BOOL)isSessionKeyValid:(NSString *)sessionKey
{
    return (sessionKey.length > 0 && [sessionKey isEqualToString:self.currentSession.sessionKey]);
}

- (void)invalidateCurrentSession
{
    self.currentSession = nil;
}

#pragma mark - Convenience

- (DMEClient *)client
{
    return [DMEClient sharedClient];
}

@end
