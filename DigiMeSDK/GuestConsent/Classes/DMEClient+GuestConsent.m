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
#import "DMESessionManager.h"
#import "DMEPreConsentViewController.h"
#import "UIViewController+DMEExtension.h"

@interface DMEClient () <DMEPreConsentViewControllerDelegate>

@property (nonatomic, weak) DMEGuestConsentManager *guestConsentManager;
@property (nonatomic, strong) DMEPreConsentViewController *preconsentViewController;
@property (nonatomic, strong, nullable) id<DMEDataRequest> scope;

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

DMEPreConsentViewController *_preconsentViewController;

- (DMEPreConsentViewController *)preconsentViewController
{
    return _preconsentViewController;
}

- (void)setPreconsentViewController:(DMEPreConsentViewController *)controller
{
    _preconsentViewController = controller;
}

DMEAuthorizationCompletion _authorizationCompletion;

- (void)setAuthorizationCompletion:(DMEAuthorizationCompletion)authorizationCompletion
{
    _authorizationCompletion = authorizationCompletion;
}

id<DMEDataRequest> _scope;

- (id<DMEDataRequest>)scope
{
    return _scope;
}

- (void)setScope:(id<DMEDataRequest>)scope
{
    _scope = scope;
}

#pragma mark - authorization

- (void)authorizeGuestWithCompletion:(DMEAuthorizationCompletion)completion
{
    [self authorizeGuestWithScope:nil completion:completion];
}

- (void)authorizeGuestWithScope:(id<DMEDataRequest>)scope completion:(DMEAuthorizationCompletion)completion
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
            self.preconsentViewController = [DMEPreConsentViewController new];
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
    [self.sessionManager sessionWithScope:self.scope completion:^(DMESession * _Nullable session, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (!session)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf executeCompletionWithSession:nil error:error];
            });
            
            return;
        }
        
        [strongSelf.guestConsentManager requestGuestConsentWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf executeCompletionWithSession:session error:error];
            });
        }];
    }];
}

- (void)executeCompletionWithSession:(DMESession * _Nullable )session error:(NSError * _Nullable)error
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
        [self authorizeWithCompletion:^(DMESession * _Nullable session, NSError * _Nullable error) {
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
