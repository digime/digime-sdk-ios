//
//  DMEClient+GuestConsent.m
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <objc/runtime.h>

#import "DMEClient+GuestConsent.h"
#import "DMEGuestConsentManager.h"
#import "DMEClient+Private.h"
#import "CASessionManager.h"
#import "PreConsentViewController.h"
#import "UIViewController+DMEExtension.h"

@interface DMEClient () <PreConsentViewControllerDelegate>

@property (nonatomic, weak) DMEGuestConsentManager *guestConsentManager;
@property (nonatomic, strong) PreConsentViewController *preconsentViewController;
@property (nonatomic, strong, nullable) id<CADataRequest> scope;

@end

@implementation DMEClient (GuestConsent)

#pragma mark - class property accessors

DMEGuestConsentManager *_guestConsentManager;

- (DMEGuestConsentManager *)guestConsentManager
{
    return _guestConsentManager;
}

- (void)setGuestConsentManager:(DMEGuestConsentManager *)manager
{
    _guestConsentManager = manager;
}

PreConsentViewController *_preconsentViewController;

- (PreConsentViewController *)preconsentViewController
{
    return _preconsentViewController;
}

- (void)setPreconsentViewController:(PreConsentViewController *)controller
{
    _preconsentViewController = controller;
}

AuthorizationCompletionBlock _authorizationCompletion;

- (void)setAuthorizationCompletion:(AuthorizationCompletionBlock)authorizationCompletion
{
    _authorizationCompletion = authorizationCompletion;
}

id<CADataRequest> _scope;

- (id<CADataRequest>)scope
{
    return _scope;
}

- (void)setScope:(id<CADataRequest>)scope
{
    _scope = scope;
}

#pragma mark - authorization

- (void)authorizeGuestWithCompletion:(AuthorizationCompletionBlock)completion
{
    [self authorizeGuestWithScope:nil completion:completion];
}

- (void)authorizeGuestWithScope:(id<CADataRequest>)scope completion:(AuthorizationCompletionBlock)completion
{
    if ([self canOpenDigiMeApp])
    {
        [self authorizeWithCompletion:completion];
    }
    else
    {
        self.scope = scope;
        [self setAuthorizationCompletion:completion];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.preconsentViewController = [PreConsentViewController new];
            self.preconsentViewController.delegate = self;
            self.preconsentViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [[UIViewController topmostViewController] presentViewController:self.preconsentViewController animated:YES completion:nil];
        });
    }
}

- (void)authorizeGuest
{
    if (!self.guestConsentManager)
    {
        // Prepare manager.
        DMEGuestConsentManager *guestConsentManager = [[DMEGuestConsentManager alloc] initWithAppCommunicator:self.appCommunicator];
        [self.appCommunicator addCallbackHandler:guestConsentManager];
        self.guestConsentManager = guestConsentManager;
    }
    
    // Validation
    NSError *validationError = [self validateClient];
    if (validationError != nil)
    {
        [self executeCompletionWithSession:nil error:validationError];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.sessionManager sessionWithScope:self.scope completion:^(CASession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!session)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf executeCompletionWithSession:nil error:error];
            });
            
            return;
        }
        
        [strongSelf.guestConsentManager requestGuestConsentWithCompletion:^(CASession * _Nullable session, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf executeCompletionWithSession:session error:error];
            });
        }];
    }];
}

- (void)executeCompletionWithSession:(CASession * _Nullable )session error:(NSError * _Nullable)error
{
    if (_authorizationCompletion != nil)
    {
        _authorizationCompletion(session, error);
        _authorizationCompletion = nil;
    }
}

#pragma mark - Preconsent View Controller delegate methods
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)downloadDigimeFromAppstore
{
    [self.preconsentViewController dismissViewControllerAnimated:YES completion:^{
        [self authorizeWithCompletion:^(CASession * _Nullable session, NSError * _Nullable error) {
            [self executeCompletionWithSession:session error:error];
        }];
    }];
}

- (void)authenticateUsingGuestConsent
{
    [self.preconsentViewController dismissViewControllerAnimated:YES completion:^{
        [self authorizeGuest];
    }];
}
#pragma clang diagnostic pop
@end
