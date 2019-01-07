//
//  DMEClient+GuestConsent.m
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMEClient+GuestConsent.h"
#import "DMEGuestConsentManager.h"
#import "DMEClient+Private.h"
#import "CASessionManager.h"

@interface DMEClient ()

@property (nonatomic, weak) DMEGuestConsentManager *guestConsentManager;

@end

@implementation DMEClient (GuestConsent)

DMEGuestConsentManager *_guestConsentManager;

-(DMEGuestConsentManager *)guestConsentManager
{
    return _guestConsentManager;
}

-(void)setGuestConsentManager:(DMEGuestConsentManager *)manager
{
    _guestConsentManager = manager;
}

- (void)authorizeGuest
{
    [self authorizeGuestWithCompletion:nil];
}

- (void)authorizeGuestWithScope:(id<CADataRequest>)scope
{
    [self authorizeGuestWithScope:scope completion:nil];
}

- (void)authorizeGuestWithCompletion:(AuthorizationCompletionBlock)completion
{
    [self authorizeGuestWithScope:nil completion:completion];
}

- (void)authorizeGuestWithScope:(id<CADataRequest>)scope completion:(AuthorizationCompletionBlock)completion
{
    if (!self.guestConsentManager)
    {
        // Prepare manager.
        DMEGuestConsentManager *guestConsentManager = [[DMEGuestConsentManager alloc] initWithAppCommunicator:self.appCommunicator];
        [self.appCommunicator addCallbackHandler:guestConsentManager];
        self.guestConsentManager = guestConsentManager;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithScope:scope completion:^(CASession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!session)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                {
                    completion(nil, error);
                }
                
                if ([strongSelf.authorizationDelegate respondsToSelector:@selector(sessionCreateFailed:)])
                {
                    [strongSelf.authorizationDelegate sessionCreateFailed:error];
                }
            });
            
            return;
        }
        
        [strongSelf.guestConsentManager requestGuestConsentWithCompletion:^(CASession * _Nullable session, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                {
                    completion(session, error);
                }
                
                if (error)
                {
                    if ([strongSelf.downloadDelegate respondsToSelector:@selector(authorizeFailed:)])
                    {
                        [strongSelf.authorizationDelegate authorizeFailed:error];
                    }
                }
                else if ([strongSelf.downloadDelegate respondsToSelector:@selector(authorizeSucceeded:)])
                {
                    [strongSelf.authorizationDelegate authorizeSucceeded:session];
                }
            });
        }];
    }];
}

@end
