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
#import "DMEClient+Private.h"
#import "DMEValidator.h"

@interface CASessionManager()

@property (nonatomic, strong, readwrite) DMEAPIClient *apiClient;
@property (nonatomic, strong, readwrite) CASession *currentSession;

@end

@implementation CASessionManager

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

- (void)sessionWithCompletion:(AuthorizationCompletionBlock)completion
{
    //validation
    if (!self.client.contractId)
    {
        completion(nil, [NSError sdkError:SDKErrorNoContract]);
        return;
    }
    
    if (![DMEValidator validateContractId:self.client.contractId])
    {
        completion(nil, [NSError sdkError:SDKErrorInvalidContract]);
        return;
    }
    
    //create new session. We always retrieve new session when requesting authorization
    [self invalidateCurrentSession];
    
    [self.apiClient requestSessionWithSuccess:^(NSData * _Nonnull data) {
        
        NSError *error;
        CASession *session = [CASessionDeserializer deserialize:data error:&error];
        
        self.currentSession = session;
        
        if (session)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.client.delegate respondsToSelector:@selector(sessionCreated:)])
                {
                    [self.client.delegate sessionCreated:session];
                }
            });
        }
        else if (error)
        {
            NSLog(@"[CASessionManager] Failed to create session: %@", error.localizedDescription);
        }
        else
        {
            //something unknown occurred.
            error = [NSError authError:AuthErrorGeneral];
        }
        
        completion(session, error);
        
    } failure:^(NSError * _Nonnull error) {
        
        if ([self.client.delegate respondsToSelector:@selector(sessionCreateFailed:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.client.delegate sessionCreateFailed:error];
            });
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

- (DMEAPIClient *)apiClient
{
    return self.client.apiClient;
}

@end
