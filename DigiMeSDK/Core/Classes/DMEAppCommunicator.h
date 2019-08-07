//
//  DMEAppCommunicator.h
//  DigiMeSDK
//
//  Created on 25/06/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Handles communication between SDK and digi.me application
 */
@interface DMEAppCommunicator : NSObject

/**
 Singleton initializer;
 
 @return A shared instance.
 */
+ (DMEAppCommunicator *)shared;

/**
 Handles returning from digi.me application.
 
 @param url NSURL
 @param options NSDictionary
 @return BOOL - NO if there is schema mismatch, YES if it was handled.
 */
- (BOOL)openURL:(NSURL *)url options:(NSDictionary *)options;

/**
 Determines whether the digi.me application is installed and can therefore be opened.
 
 @return YES if digi.me app is installed, NO if not.
 */
- (BOOL)canOpenDMEApp;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
