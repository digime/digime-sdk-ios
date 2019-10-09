//
//  DMEClient.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DMEClientConfiguration;
@class DMESessionManager;

NS_ASSUME_NONNULL_BEGIN

/**
 Base client object used for any authorization flow.
 */
@interface DMEClient : NSObject

/**
 Uses default configuration, which can be overwritten with your own.
 */
@property (nonatomic, strong, readonly) id<DMEClientConfiguration> configuration;

/**
 DigiMe Consent Access Session Manager.
 */
@property (nonatomic, strong, readonly) DMESessionManager *sessionManager;

/**
 Session metadata. Contains additional debug information collected during the session lifetime.
 */
@property (strong, nonatomic, readonly) NSDictionary<NSString *, id> *metadata;

/**
 Hands off to the digi.me app if it's installed, and instructs it to show the receipt
 pertaining to the contractId and appId of the current session.
 
 @param error NSError pointer, this method can throw various SDK-related errors; catch and handle them here.
 @return YES if able to open digi.me app, NO if not or some other SDK-related error occurred.
 */
- (BOOL)viewReceiptInDMEAppWithError:(NSError * __autoreleasing * __nullable)error;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
