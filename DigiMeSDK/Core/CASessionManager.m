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

#pragma mark - Public

- (void)sessionWithCompletion:(AuthorizationCompletionBlock)completion
{
    //validation
    if (!self.client.contractId)
    {
        completion(nil, [NSError sdkError:SDKErrorNoContract]);
        return;
    }
    
    if (![DMECryptoUtilities validateContractId:self.client.contractId])
    {
        completion(nil, [NSError sdkError:SDKErrorInvalidContract]);
        return;
    }
    
    if ([self isSessionValid])
    {
        completion(self.currentSession, nil);
        return;
    }
    
    //create new session.
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
