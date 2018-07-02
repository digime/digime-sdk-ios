//
//  DMEMercuryInterfacer.m
//  DigiMeSDK
//
//  Created by Jacob King on 25/06/2018.
//  Copyright © 2018 me.digi. All rights reserved.
//

#import "DMEMercuryInterfacer.h"
#import "DMEClient.h"
#import <StoreKit/StoreKit.h>
#import "UIViewController+DMEExtension.h"

static NSString * const kCARequestSessionKey = @"CARequestSessionKey";
static NSString * const kCARequestRegisteredAppID = @"CARequestRegisteredAppID";
static NSString * const kCARequest3dPartyAppName = @"CARequest3dPartyAppName";
static NSString * const kCADigimeResponse = @"CADigimeResponse";
static NSString * const kDMEClientScheme = @"digime-ca-master";
static NSString * const kDMEClientSchemePrefix = @"digime-ca-";
static NSInteger  const kDMEClientAppstoreID = 1234541790;
static NSTimeInterval const kCATimerInterval = 0.5;

@interface DMEMercuryInterfacer () <SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) NSTimer *pendingInstallationPollingTimer;
@property (nonatomic, strong) SKStoreProductViewController *storeViewController;

@property (nonatomic, strong) DMEDigiMeOpenAction *sentAction;
@property (nonatomic, strong) NSDictionary *sentParameters;

@property (nonatomic, strong) NSMutableArray<id<DMEMercuryInterfacee>> *interfacees;

@end

@implementation DMEMercuryInterfacer

#pragma mark - Initialisation

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _interfacees = [NSMutableArray array];
    }
    
    return self;
}


#pragma mark - Public

- (BOOL)canOpenDigiMeApp
{
    return [self digiMeAppIsInstalled];
}

- (void)openDigiMeAppWithAction:(DMEDigiMeOpenAction *)action parameters:(NSDictionary *)parameters
{
    
    self.sentAction = action;
    self.sentParameters = parameters;
    
    if (![self digiMeAppIsInstalled])
    {
        [self presentAppstoreView];
        return; // We have a listener set up to restore this flow after.
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:[self digiMeBaseURL] resolvingAgainstBaseURL:NO];
    components.host = action;
    
    NSMutableArray *newQueryItems = [NSMutableArray arrayWithArray:components.queryItems];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [newQueryItems addObject:[NSURLQueryItem queryItemWithName:key value:obj]];
    }];
    components.queryItems = newQueryItems;
    
    NSURL *openURL = components.URL;
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
    DMEDigiMeOpenAction *action = comps.host;
    
    for (id<DMEMercuryInterfacee> interfacee in self.interfacees)
    {
        if ([interfacee canHandleAction:action])
        {
            // Great, an interfacee can handle the action, grab the params.
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:comps.queryItems.count];
            for (NSURLQueryItem *queryItem in comps.queryItems)
            {
                params[queryItem.name] = queryItem.value;
            }
            
            // Pass values to interfacee to handle.
            [interfacee handleAction:action withParameters:params];
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

#pragma mark - Interfacee Management

- (void)addInterfacee:(id<DMEMercuryInterfacee>)interfacee
{
    if (![self.interfacees containsObject:interfacee])
    {
        interfacee.interfacer = self;
        [self.interfacees addObject:interfacee];
    }
}

- (void)removeInterfacee:(id<DMEMercuryInterfacee>)interfacee
{
    if ([self.interfacees containsObject:interfacee])
    {
        [self.interfacees removeObject:interfacee];
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
    
}

@end
