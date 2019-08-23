//
//  main.m
//  DigiMeSDKExample
//
//  Created on 24/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

static BOOL isRunningUnitTests(void);
NSString *delegateClassName(void);

NSString *delegateClassName()
{
    return isRunningUnitTests() ? nil : NSStringFromClass([AppDelegate class]);
}

int main(int argc, char * argv[])
{
    @autoreleasepool
    {
        int retval;
        
        @try
        {
            retval = UIApplicationMain(argc, argv, nil, delegateClassName());
        }
        @catch (NSException *exception)
        {
            @throw;
        }
        return retval;
    }
}

static BOOL isRunningUnitTests()
{
    NSDictionary<NSString *, NSString *> *env = [NSProcessInfo processInfo].environment;
    
    // Library tests
    NSString *envValue = env[@"XPC_SERVICE_NAME"];
    BOOL isTesting = (envValue && [envValue rangeOfString:@"xctest"].location != NSNotFound);
    if (isTesting) {
        return YES;
    }
    
    // App tests
    // XPC_SERVICE_NAME will return the same string as normal app start when unit test is executed using "Host Application"
    // --> check for "XCTestConfigurationFilePath" instead
    envValue = env[@"XCTestConfigurationFilePath"];
    isTesting = (envValue && [envValue rangeOfString:@"xctest"].location != NSNotFound);
    return isTesting;
}
