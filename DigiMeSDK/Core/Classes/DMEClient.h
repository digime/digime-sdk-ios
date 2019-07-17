//
//  DMEClient.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAScope.h"
#import "DMEClientCallbacks.h"
#import "DMEClientConfiguration.h"

@class DMESessionManager;

NS_ASSUME_NONNULL_BEGIN

@interface DMEClient : NSObject

/**
 Your application Id. This property MUST be set before you can call authorize.
 */
@property (nonatomic, nullable, copy) NSString *appId;


/**
 Your contract Id. This property MUST be set before you can call authorize.
 */
@property (nonatomic, nullable, copy) NSString *contractId;


/**
 Your rsa private key hex. This property MUST be set before you can call authorize.
 */
@property (nonatomic, nullable, copy) NSString *privateKeyHex;


/**
 Uses default configuration, which can be overwritten with your own.
 */
@property (nonatomic, strong) DMEClientConfiguration *clientConfiguration;

/**
 DigiMe Consent Access Session Manager.
 */
@property (nonatomic, strong, readonly) DMESessionManager *sessionManager;


/**
 Defaults to YES. If set to NO, then when data is downloaded it will be passed as raw to the download delegate. We recommend this setting is left at default.
 
 N.B. When set to NO, the download delegate must be set as this is not compatible with DMEClientCallbacks.
 */
@property (nonatomic) BOOL decryptsData;

/**
 Session metadata. Contains additional debug information collected during the session lifetime.
 */
@property (strong, nonatomic, readonly, nonnull) NSDictionary<NSString *, id> *metadata;

/**
 Singleton initializer;

 @return DMEClient instance.
 */
+ (DMEClient *)sharedClient;

/**
 Initilizes contract authentication. This will attempt to create a session and redirect
 to the Digi.me application.

 @param authorizationCompletion AuthorizationCompletionBlock
 */
- (void)authorizeWithCompletion:(nonnull AuthorizationCompletionBlock)authorizationCompletion;


/**
 Initilizes contract authentication with custom scope. This will attempt to create a session and redirect
 to the Digi.me application.

 @param scope custom scope that will be applied to available data.
 @param authorizationCompletion AuthorizationCompletionBlock
 */
- (void)authorizeWithScope:(nullable id<CADataRequest>)scope completion:(nonnull AuthorizationCompletionBlock)authorizationCompletion;

/**
 Fetches file list that's available for the authorized contract.
 @param completion FileListCompletionBlock.
 */
- (void)getFileListWithCompletion:(nonnull FileListCompletionBlock)completion;

/**
 Fetches file content for fileId. FileId is retrieve from fileList.

 @param fileId NSString id if the file to fetch.
 @param completion FileContentCompletionBlock
 */
- (void)getFileWithId:(NSString *)fileId completion:(nonnull FileContentCompletionBlock)completion;

/**
 Fetches the accounts available for the authorized contract.
 @param completion AccountsCompletionBlock
 */
- (void)getAccountsWithCompletion:(nonnull AccountsCompletionBlock)completion;

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
- (BOOL)canOpenDigiMeApp;


/**
 Hands off to the digi.me app if it's installed, and instructs it to show the receipt
 pertaining to the contractId and appId of the current session.
 @param error NSError pointer, this method can throw various errors; catch and handle them here.
 */
- (void)viewReceiptInDigiMeAppWithError:(NSError * __autoreleasing * __nullable)error;

@end

NS_ASSUME_NONNULL_END
