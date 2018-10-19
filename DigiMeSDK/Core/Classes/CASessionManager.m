//
//  CASessionManager.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "CASessionManager.h"
#import "DMECryptoUtilities.h"
#import "DMEAPIClient.h"
#import "CASessionDeserializer.h"
#import "DMEClient.h"

@interface CASessionManager()

@property (nonatomic, strong, readonly) DMEAPIClient *apiClient;
@property (nonatomic, strong, readwrite) CASession *currentSession;

@end

@implementation CASessionManager

- (instancetype)initWithApiClient:(DMEAPIClient *)apiClient
{
    self = [super init];
    if (self)
    {
        _apiClient = apiClient;
    }
    
    return self;
}

#pragma mark - Public

- (void)sessionWithCompletion:(AuthorizationCompletionBlock)completion
{
    //create new session. We always retrieve new session when requesting authorization
    [self invalidateCurrentSession];
    
    [self.apiClient requestSessionWithSuccess:^(NSData * _Nonnull data) {
        
        NSError *error;
        CASession *session = [CASessionDeserializer deserialize:data error:&error];
        
        self.currentSession = session;
        
        if (error != nil)
        {
            NSLog(@"[CASessionManager] Failed to create session: %@", error.localizedDescription);
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
-(BOOL)isSessionKeyValid:(NSString *)sessionKey
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
