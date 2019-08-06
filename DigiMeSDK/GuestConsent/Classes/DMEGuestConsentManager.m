//
//  DMEGuestConsentManager.m
//  DigiMeSDK
//
//  Created on 22/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEClientConfiguration.h"
#import "DMEGuestConsentManager.h"
#import "DMESessionManager.h"
#import "UIViewController+DMEExtension.h"
#import <SafariServices/SFSafariViewController.h>

static NSString * const kDMEAPIClientBaseUrl = @"DMEAPIClientBaseUrl";

@interface DMEGuestConsentManager() <SFSafariViewControllerDelegate>

@property (nonatomic, strong, readonly) DMEAppCommunicator *appCommunicator;
@property (nonatomic, strong, readonly) DMESession *session;
@property (nonatomic, strong, readonly) DMESessionManager *sessionManager;
@property (nonatomic, copy, nullable) DMEAuthorizationCompletion guestConsentCompletionBlock;
@property (nonatomic, strong) SFSafariViewController *safariViewController;
@property (nonatomic, strong) NSDictionary *sentParameters;
@property (nonatomic, strong) DMEClientConfiguration *configuration;

@end

@implementation DMEGuestConsentManager

- (instancetype)initWithSessionManager:(DMESessionManager *)sessionManager configuration:(DMEClientConfiguration *)configuration
{
    self = [super init];
    if (self)
    {
        _appCommunicator = [DMEAppCommunicator shared];
        _sessionManager = sessionManager;
        _configuration = configuration;
    }
    
    return self;
}

- (BOOL)canHandleAction:(DMEOpenAction *)action
{
    return [action isEqualToString:@"guestConsent-return"];
}

- (void)handleAction:(DMEOpenAction *)action withParameters:(NSDictionary<NSString *,id> *)parameters
{
    NSError *error = [self handleGuestConsentCallbackWithParameters:parameters];
    [self executeCompletionWithError:error];
    [self.appCommunicator removeCallbackHandler:self];
}

- (void)requestGuestConsentWithCompletion:(DMEAuthorizationCompletion)completion
{
    
    if (![NSThread currentThread].isMainThread)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestGuestConsentWithCompletion:completion];
        });
        return;
    }
    
    if (![self.sessionManager isSessionValid])
    {
        completion(nil, nil);
        return;
    }
    
    self.guestConsentCompletionBlock = completion;
    
    NSDictionary *params = @{
                             kDMEAPIClientBaseUrl: self.configuration.baseUrl,
                             kDMESessionKey: self.session.sessionExchangeToken,
                             kDMERegisteredAppID: self.configuration.appId,
                             };
    
    [self.appCommunicator addCallbackHandler:self];
    [self openBrowserWithParameters:params];
}

- (void)openBrowserWithParameters:(NSDictionary *)parameters
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *sessionKey = parameters[kDMESessionKey];
        NSString *baseUrl = parameters[kDMEAPIClientBaseUrl];
        NSString *callbackSuffix = @"%3A%2F%2FguestConsent-return%2F";
        NSString *callbackUrl = [NSString stringWithFormat:@"%@%@%@", kDMEClientSchemePrefix, self.configuration.appId, callbackSuffix];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@apps/quark/direct-onboarding?sessionExchangeToken=%@&callbackUrl=%@", baseUrl, sessionKey, callbackUrl]];
        self.safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        self.safariViewController.delegate = self;
        if (@available(iOS 11.0, *)) {
            self.safariViewController.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleCancel;
        }
        [[UIViewController topmostViewController] presentViewController:self.safariViewController animated:YES completion:nil];
    });
}

- (NSError *)handleGuestConsentCallbackWithParameters:(NSDictionary<NSString *,id> *)parameters
{
    NSError *error = nil;
    
    // User could have opened in Safari Browser and cancelled/completed authentication in SafariViewController
    // then cancelled/completed authentication again in Browser,
    // in which case we ignore any callback from Browser as app has already handled a callback.
    SFSafariViewController *vc = self.safariViewController;
    if (vc == nil || !vc.isViewLoaded || vc.view.window == nil || vc.presentingViewController == nil)
    {
        error = [NSError authError:AuthErrorCancelled];
    }
    
    NSString *result = parameters[kDMEResponse];
    
    if (!error && [result isEqualToString:kDMEResultValueSuccess])
    {
        // Everything good; No error to set
    }
    else if ([result isEqualToString:kDMEResultValueCancel])
    {
        error = [NSError authError:AuthErrorCancelled];
    }
    else
    {
        error = [NSError authError:AuthErrorGeneral];
    }
    
    [vc.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self executeCompletionWithError:error];
    }];
    
    return error;
}

- (void)executeCompletionWithError:(NSError *)error
{
    //all callbacks should be returned on main thread.
    if (![NSThread currentThread].isMainThread)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self executeCompletionWithError:error];
        });
        return;
    }
    
    self.safariViewController.delegate = nil;
    self.safariViewController = nil;
    
    if (self.guestConsentCompletionBlock)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.guestConsentCompletionBlock(self.session, error);
            self.guestConsentCompletionBlock = nil;
        });
    }
}

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    [self executeCompletionWithError:[NSError authError:AuthErrorCancelled]];
}

#pragma mark - Convenience

- (DMESession *)session
{
    return self.sessionManager.currentSession;
}

@end
