//
//  UIViewController+DMEExtension.m
//  DigiMeSDK
//
//  Created on 28/02/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "UIViewController+DMEExtension.h"

@implementation UIViewController (DMEExtension)

+ (UIViewController *)topmostViewController
{
    return [self topmostViewControllerFromRootViewController:[UIApplication sharedApplication].delegate.window.rootViewController];
}

+ (UIViewController *)topmostViewControllerFromRootViewController:(UIViewController *)rootViewController
{
    if (rootViewController == nil)
    {
        return nil;
    }
    
    if ([rootViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topmostViewControllerFromRootViewController:[navigationController.viewControllers lastObject]];
    }
    
    if ([rootViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabController = (UITabBarController *)rootViewController;
        return [self topmostViewControllerFromRootViewController:tabController.selectedViewController];
    }
    
    if (rootViewController.presentedViewController) {
        return [self topmostViewControllerFromRootViewController:rootViewController.presentedViewController];
    }
    
    return rootViewController;
}

@end
