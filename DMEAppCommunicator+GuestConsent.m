//
//  DMEAppCommunicator+GuestConsent.m
//  DigiMeSDK
//
//  Created on 26/11/2018.
//

#import <SafariServices/SFSafariViewController.h>
#import <SafariServices/SFFoundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "DMEAppCommunicator+GuestConsent.h"
#import "CASessionManager.h"
#import "UIViewController+DMEExtension.h"

static NSString * const kCARequestSessionKey = @"CARequestSessionKey";
static NSString * const kDMEClientSchemePrefix = @"digime-ca-";
static NSString * const kDMEAPIClientBaseUrl = @"DMEAPIClientBaseUrl";

@interface DMEAppCommunicator () <SFSafariViewControllerDelegate>

@property (nonatomic, strong) SFSafariViewController *safariViewController;
@property (nonatomic, strong) NSDictionary *sentParameters;

@end

@implementation DMEAppCommunicator (GuestConsent)

SFSafariViewController *_safariViewController;

-(SFSafariViewController *)safariViewController
{
    return _safariViewController;
}

-(void)setSafariViewController:(SFSafariViewController *)safariViewController
{
    _safariViewController = safariViewController;
}

- (void)openBrowserWithParameters:(NSDictionary *)parameters
{
    dispatch_async(dispatch_get_main_queue(), ^{

        NSString *sessionKey = parameters[kCARequestSessionKey];
        NSString *baseUrl = parameters[kDMEAPIClientBaseUrl];
        NSString *callbackSuffix = @"%3A%2F%2FguestConsent-return%2F";
        NSString *callbackUrl = [NSString stringWithFormat:@"%@%@%@", kDMEClientSchemePrefix, [DMEClient sharedClient].appId, callbackSuffix];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@apps/guestConsent/direct-onboarding?sessionKey=%@&callbackUrl=%@", baseUrl, sessionKey, callbackUrl]];
        self.safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        self.safariViewController.delegate = self;
        if (@available(iOS 11.0, *)) {
            self.safariViewController.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleCancel;
        }
        [[UIViewController topmostViewController] presentViewController:self.safariViewController animated:YES completion:nil];
    });
}

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    [self executeCompletionWithSession:self.session error:[NSError authError:AuthErrorCancelled]];
}

#pragma mark - Private

- (void)executeCompletionWithSession:(CASession *)session error:(NSError *)error
{
    //all callbacks should be returned on main thread.
    if (![NSThread currentThread].isMainThread)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self executeCompletionWithSession:session error:error];
        });
        return;
    }
    
    self.safariViewController.delegate = nil;
    self.safariViewController = nil;
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

    NSString *result = parameters[@"result"];
    
    if (!error && [result isEqualToString:@"DATA_READY"])
    {
        // Everything good; No error to set
    }
    else if ([result isEqualToString:@"CANCELLED"])
    {
        error = [NSError authError:AuthErrorCancelled];
    }
    else
    {
        error = [NSError authError:AuthErrorGeneral];
    }

    [vc.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self executeCompletionWithSession:self.session error:error];
    }];
    
    return error;
}

#pragma mark - Convenience

- (CASession *)session
{
    return self.sessionManager.currentSession;
}

-(CASessionManager *)sessionManager
{
    return [DMEClient sharedClient].sessionManager;
}

@end
