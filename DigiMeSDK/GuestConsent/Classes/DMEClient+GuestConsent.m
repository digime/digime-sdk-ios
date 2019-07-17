//
//  DMEClient+GuestConsent.m
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <objc/runtime.h>

#import "DMEClient+GuestConsent.h"
#import "DMEGuestConsentManager.h"
#import "DMEClient+Private.h"
#import "DMESessionManager.h"
#import "PreConsentViewController.h"
#import "UIViewController+DMEExtension.h"

@interface DMEClient () <PreConsentViewControllerDelegate>

@property (nonatomic, weak) DMEGuestConsentManager *guestConsentManager;
@property (nonatomic, strong) PreConsentViewController *preconsentViewController;

@end

@implementation DMEClient (GuestConsent)

#pragma mark - class property accessors

DMEGuestConsentManager *_guestConsentManager;

-(DMEGuestConsentManager *)guestConsentManager
{
    return _guestConsentManager;
}

-(void)setGuestConsentManager:(DMEGuestConsentManager *)manager
{
    _guestConsentManager = manager;
}

PreConsentViewController *_preconsentViewController;

-(PreConsentViewController *)preconsentViewController
{
    return _preconsentViewController;
}

-(void)setPreconsentViewController:(PreConsentViewController *)controller
{
    _preconsentViewController = controller;
}

#pragma mark - authorization

- (void)authorizeGuest
{
    if ([self canOpenDigiMeApp])
    {
        [self authorizeWithCompletion:nil];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.preconsentViewController = [PreConsentViewController new];
            self.preconsentViewController.delegate = self;
            self.preconsentViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [[UIViewController topmostViewController] presentViewController:self.preconsentViewController animated:YES completion:nil];
        });
    }
}

- (void)authorizeGuestWithScope:(id<DMEDataRequest>)scope
{
    [self authorizeGuestWithScope:scope completion:nil];
}

- (void)authorizeGuestWithCompletion:(AuthorizationCompletionBlock)completion
{
    [self authorizeGuestWithScope:nil completion:completion];
}

- (void)authorizeGuestWithScope:(id<DMEDataRequest>)scope completion:(AuthorizationCompletionBlock)completion
{
    if (!self.guestConsentManager)
    {
        // Prepare manager.
        DMEGuestConsentManager *guestConsentManager = [[DMEGuestConsentManager alloc] initWithAppCommunicator:self.appCommunicator];
        [self.appCommunicator addCallbackHandler:guestConsentManager];
        self.guestConsentManager = guestConsentManager;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithScope:scope completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!session)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                {
                    completion(nil, error);
                }
            });
            
            return;
        }
        
        [strongSelf.guestConsentManager requestGuestConsentWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion)
                {
                    completion(session, error);
                }
            });
        }];
    }];
}

#pragma mark - Preconsent View Controller delegate methods
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)downloadDigimeFromAppstore
{
    [self.preconsentViewController dismissViewControllerAnimated:YES completion:^{
        [self authorizeWithCompletion:nil];
    }];
}

- (void)authenticateUsingGuestConsent
{
    [self.preconsentViewController dismissViewControllerAnimated:YES completion:^{
        [self authorizeGuestWithCompletion:nil];
    }];
}
#pragma clang diagnostic pop
@end
