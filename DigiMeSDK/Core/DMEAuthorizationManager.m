//
//  DMEAuthorizationManager.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMEAuthorizationManager.h"
#import "CASessionManager.h"
#import "DMEClient.h"

#import "NSError+Auth.h"
#import "UIViewController+DMEExtension.h"

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

static NSString * const kCARequestSessionKey = @"CARequestSessionKey";
static NSString * const kCARequestRegisteredAppID = @"CARequestRegisteredAppID";
static NSString * const kCARequest3dPartyAppName = @"CARequest3dPartyAppName";
static NSString * const kCADigimeResponse = @"CADigimeResponse";
static NSString * const kDMEClientScheme = @"digime-ca-master";
static NSString * const kDMEClientSchemePrefix = @"digime-ca-";
static NSInteger  const kDMEClientAppstoreID = 1234541790;
static NSTimeInterval const kCATimerInterval = 0.5;

@interface DMEAuthorizationManager() <SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) CASession *session;
@property (nonatomic, strong) CASessionManager *sessionManager;
@property (nonatomic) BOOL authInProgress;
@property (nonatomic, copy, nullable) AuthorizationCompletionBlock authCompletionBlock;
@property (nonatomic, strong) SKStoreProductViewController *storeViewController;

@end

@implementation DMEAuthorizationManager

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _authInProgress = NO;
        _session = nil;
    }
    
    return self;
}

- (void)dealloc
{
    if (self.storeViewController)
    {
        self.storeViewController.delegate = nil;
        self.storeViewController = nil;
    }
}

#pragma mark - Authorization

- (void)continueAuthorization
{
    void (^completionBlock)(BOOL success) = ^void(BOOL success) {
        if(success)
        {
            NSLog(@"[DMEClient] Authorization begun.");
        }
        else
        {
            if (self.authCompletionBlock)
            {
                self.authCompletionBlock(self.session, [NSError authError:AuthErrorGeneral]);
                self.authCompletionBlock = nil;
            }
        }
    };
    
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [self digiMeUrl];
    
    NSDictionary *options = @{ UIApplicationOpenURLOptionUniversalLinksOnly : @NO };
    [app openURL:url options:options completionHandler:completionBlock];
}

-(void)beginAuthorizationWithCompletion:(AuthorizationCompletionBlock)completion
{
    if (self.authInProgress)
    {
        NSError *authError = [NSError authError:AuthErrorInProgress];
        completion(self.session, authError);
        return;
    }
    
    if (![self.sessionManager isSessionValid])
    {
        completion(nil, [NSError authError:AuthErrorInvalidSession]);
        return;
    }
    
    self.authInProgress = YES;
    
    self.authCompletionBlock = completion;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *url = [self digiMeUrl];
        if ([app canOpenURL:url])
        {
            [self continueAuthorization];
        }
        else
        {
            [self presentAppstoreView];
        }
    });
}

- (void)checkIfDigiMeIsInstalled
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIApplication *app = [UIApplication sharedApplication];
        NSURL *url = [self digiMeUrl];
        if ([app canOpenURL:url])
        {
            [self.storeViewController dismissViewControllerAnimated:YES completion:^{
                [self continueAuthorization];
            }];
        }
        else
        {
            [NSTimer scheduledTimerWithTimeInterval:kCATimerInterval target:self selector:@selector(checkIfDigiMeIsInstalled) userInfo:nil repeats:NO];
        }
    });
}
- (NSURL *)digiMeUrl
{
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    if (!appName)
    {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    NSURLQueryItem *appNamePublic = [NSURLQueryItem queryItemWithName:kCARequest3dPartyAppName value:appName];
    NSURLQueryItem *sessionKeyComponent = [NSURLQueryItem queryItemWithName:kCARequestSessionKey value:self.session.sessionKey];
    NSURLQueryItem *registereAppIdComponent = [NSURLQueryItem queryItemWithName:kCARequestRegisteredAppID value:self.appId];
    NSURLComponents *components = [NSURLComponents new];
    
    [components setQueryItems: @[sessionKeyComponent, registereAppIdComponent, appNamePublic]];
    [components setScheme:kDMEClientScheme];
    [components setHost:@"data"];
    
    return components.URL;
}

- (void)presentAppstoreView
{
    self.storeViewController = [[SKStoreProductViewController alloc] init];
    self.storeViewController.delegate = self;
    NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier:@(kDMEClientAppstoreID)};
    
    __weak __typeof(self) weakSelf = self;
    [self.storeViewController loadProductWithParameters:parameters
                                        completionBlock:^(BOOL result, NSError *error) {
                                            if (result)
                                            {
                                                __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                [[UIViewController topmostViewController] presentViewController:strongSelf.storeViewController animated:YES completion:^{
                                                    
                                                    [NSTimer scheduledTimerWithTimeInterval:kCATimerInterval target:strongSelf selector:@selector(checkIfDigiMeIsInstalled) userInfo:nil repeats:NO];
                                                }];
                                            }
                                        }];
}

#pragma mark - SKStoreProductViewControllerDelegate

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [NSTimer cancelPreviousPerformRequestsWithTarget:self];
    [viewController dismissViewControllerAnimated:YES completion:nil];
    self.authInProgress = NO;
    [self executeCompletionWithSession:self.session error:[NSError authError:AuthErrorCancelled]];
}

#pragma mark - Digi.me App openURL handling

- (BOOL)openURL:(NSURL *)url options:(NSDictionary *)options
{
    //if we are not expecting a return, then skip logic.
    if (!self.authInProgress) { return NO; }
    
    BOOL canHandle = NO;
    if([url.absoluteString hasPrefix:kDMEClientSchemePrefix])
    {
        NSLog(@"[DMEClient] Digi.me callback intercepted.");
        
        canHandle = YES;
        NSURLComponents* urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSArray*         queryItems    = urlComponents.queryItems;
        
        BOOL result = [[self valueForKey:kCADigimeResponse inItems:queryItems] boolValue];
        NSString* sessionKey = [self valueForKey:kCARequestSessionKey inItems:queryItems];
        
        if(![self.sessionManager isSessionKeyValid:sessionKey])
        {
            [self executeCompletionWithSession:self.session error:[NSError authError:AuthErrorInvalidSessionKey]];
        }
        else if(result)
        {
            [self executeCompletionWithSession:self.session error:nil];
        }
        else
        {
            [self executeCompletionWithSession:self.session error:[NSError authError:AuthErrorCancelled]];
        }
        
        self.authInProgress = NO;
    }
    
    return canHandle;
}

- (BOOL)canOpenDigiMeApp
{
    NSURLComponents *components = [NSURLComponents new];
    [components setScheme:kDMEClientScheme];
    
    return [[UIApplication sharedApplication] canOpenURL:components.URL];
}

#pragma mark - Private

- (void)executeCompletionWithSession:(CASession *)session error:(NSError *)error
{
    if (self.authCompletionBlock)
    {
        //all callbacks should be returned on main thread.
        if (![NSThread currentThread].isMainThread)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self executeCompletionWithSession:session error:error];
            });
            return;
        }
        
        self.authCompletionBlock(session, error);
        self.authCompletionBlock = nil;
    }
}

#pragma mark - Convenience

-(nullable NSString *)appId
{
    return [DMEClient sharedClient].appId;
}

- (CASession *)session
{
    return self.sessionManager.currentSession;
}

#pragma mark - Utilities
- (NSString *)valueForKey:(NSString *)key inItems:(NSArray *)queryItems
{
    NSPredicate*    predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem* queryItem = [[queryItems filteredArrayUsingPredicate:predicate] firstObject];
    return queryItem.value;
}

-(CASessionManager *)sessionManager
{
    return [DMEClient sharedClient].sessionManager;
}

@end
