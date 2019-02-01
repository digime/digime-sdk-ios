//
//  DMEAppCommunicator.m
//  DigiMeSDK
//
//  Created on 25/06/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEAppCommunicator.h"
#import "DMEClient.h"
#import <StoreKit/StoreKit.h>
#import "UIViewController+DMEExtension.h"

static NSString * const kDMEClientScheme = @"digime-ca-master";
static NSString * const kCASdkVersion = @"CASdkVersion";
static NSInteger  const kDMEClientAppstoreID = 1234541790;
static NSTimeInterval const kCATimerInterval = 0.5;

@interface DMEAppCommunicator () <SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) NSTimer *pendingInstallationPollingTimer;
@property (nonatomic, strong) SKStoreProductViewController *storeViewController;

@property (nonatomic, strong) DMEOpenAction *sentAction;
@property (nonatomic, strong) NSDictionary *sentParameters;

@property (nonatomic, strong) NSMutableArray<id<DMEAppCallbackHandler>> *callbackHandlers;

@end

@implementation DMEAppCommunicator

#pragma mark - Initialisation

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _callbackHandlers = [NSMutableArray array];
    }
    
    return self;
}


#pragma mark - Public

- (BOOL)canOpenDigiMeApp
{
    return [self digiMeAppIsInstalled];
}

- (void)openDigiMeAppWithAction:(DMEOpenAction *)action parameters:(NSDictionary *)parameters
{
    self.sentAction = action;
    self.sentParameters = parameters;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self digiMeAppIsInstalled])
        {
            [self presentAppstoreView];
            return; // We have a listener set up to restore this flow after.
        }
        
        NSURLComponents *components = [NSURLComponents componentsWithURL:[self digiMeBaseURL] resolvingAgainstBaseURL:NO];
        components.host = action;
        
        NSMutableArray *newQueryItems = [NSMutableArray arrayWithArray:components.queryItems] ?: [NSMutableArray array];
        [newQueryItems addObject:[NSURLQueryItem queryItemWithName:kCASdkVersion value:[[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
        
        [parameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [newQueryItems addObject:[NSURLQueryItem queryItemWithName:key value:obj]];
        }];
        components.queryItems = newQueryItems;
        
        NSURL *openURL = components.URL;
        
        [UIApplication.sharedApplication openURL:openURL options:@{} completionHandler:nil];
    });
}

#pragma mark - Callback Forwarding

- (BOOL)openURL:(NSURL *)url options:(NSDictionary *)options
{
    // No point processing further if we don't need to!
    if (![url.absoluteString hasPrefix:kDMEClientSchemePrefix])
    {
        return NO;
    }
    
    // Grab the action.
    NSURLComponents *comps = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    DMEOpenAction *action = comps.host;
    
    for (id<DMEAppCallbackHandler> callbackHandler in self.callbackHandlers)
    {
        if ([callbackHandler canHandleAction:action])
        {
            // Great, a callbackHandler can handle the action, grab the params.
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:comps.queryItems.count];
            for (NSURLQueryItem *queryItem in comps.queryItems)
            {
                params[queryItem.name] = queryItem.value;
            }
            
            // Pass values to callbackHandler to handle.
            [callbackHandler handleAction:action withParameters:params];
            // Exit method, we've handled the URL.
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Internal / Utility

- (BOOL)digiMeAppIsInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[self digiMeBaseURL]];
}

- (NSURL *)digiMeBaseURL
{
    NSURLComponents *components = [NSURLComponents new];
    
    // We need to supply our AppID and name in all calls to DigiMe, so let's include these by default.
    NSURLQueryItem *appNameItem = [NSURLQueryItem queryItemWithName:kCARequest3dPartyAppName value:[self appName]];
    NSURLQueryItem *appIdItem = [NSURLQueryItem queryItemWithName:kCARequestRegisteredAppID value:[self appId]];
    
    components.scheme = kDMEClientScheme;
    components.queryItems = @[appNameItem, appIdItem];
    
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
                                                    
                                                    self.pendingInstallationPollingTimer = [NSTimer scheduledTimerWithTimeInterval:kCATimerInterval target:strongSelf selector:@selector(pollForAppInstall) userInfo:nil repeats:YES];
                                                }];
                                            }
                                        }];
}

- (void)pollForAppInstall
{
    if ([self digiMeAppIsInstalled])
    {
        [self.pendingInstallationPollingTimer invalidate];
        self.pendingInstallationPollingTimer = nil;
        
        [self.storeViewController dismissViewControllerAnimated:YES completion:^{
            [self openDigiMeAppWithAction:self.sentAction parameters:self.sentParameters];
        }];
    }
    
}

#pragma mark - CallbackHandler Management

- (void)addCallbackHandler:(id<DMEAppCallbackHandler>)callbackHandler
{
    if (![self.callbackHandlers containsObject:callbackHandler])
    {
        callbackHandler.appCommunicator = self;
        [self.callbackHandlers addObject:callbackHandler];
    }
}

- (void)removeCallbackHandler:(id<DMEAppCallbackHandler>)callbackHandler
{
    if ([self.callbackHandlers containsObject:callbackHandler])
    {
        [self.callbackHandlers removeObject:callbackHandler];
    }
}

#pragma mark - Convenience Getters

- (NSString *)appName
{
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    if (!appName)
    {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    return appName;
}

- (NSString *)appId
{
    return [DMEClient sharedClient].appId;
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    // Handle case where user cancels the store VC.
    [self.pendingInstallationPollingTimer invalidate];
    self.pendingInstallationPollingTimer = nil;
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    for (id<DMEAppCallbackHandler> callbackHandler in self.callbackHandlers)
    {
        if ([callbackHandler canHandleAction:@"data"] && ![self digiMeAppIsInstalled])
        {
            [callbackHandler handleAction:@"data" withParameters:@{kCADigimeResponse: @NO}];
        }
    }
}

@end
