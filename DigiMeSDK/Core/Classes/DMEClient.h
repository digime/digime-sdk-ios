//
//  DMEClient.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientDelegate.h"
#import "DMEClientConfiguration.h"
#import "DMEClientCallbacks.h"
#import "CAScope.h"

@class CASessionManager;

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
 DigiMe client delegate. This should only be set if you do not with to use DMEClientCallbacks.
 */
@property (nonatomic, nullable, weak) id<DMEClientDelegate> delegate;


/**
 DigiMe Consent Access Session Manager.
 */
@property (nonatomic, strong, readonly) CASessionManager *sessionManager;

/**
 Singleton initializer;

 @return DMEClient instance.
 */
+ (DMEClient *)sharedClient;


/**
 Initializes contract authentication. This will attempt to create a session and redirect
 to the Digi.me application.
 NOTE: If using this method, the delegate must be set.
 */
- (void)authorize;


/**
 Initializes contract authentication with custom scope. This will attempt to create and redirect
 to the Digi.me application.
 NOTE: If using this method, the delegate must be set.
 
 @param scope custom scope that will be applied to available data.
 */
- (void)authorizeWithScope:(id<CADataRequest>)scope;


/**
 Initilizes contract authentication. This will attempt to create a session and redirect
 to the Digi.me application.
 NOTE: If using this method, the delegate must NOT be set.

 @param authorizationCompletion AuthorizationCompletionBlock
 */
- (void)authorizeWithCompletion:(nullable AuthorizationCompletionBlock)authorizationCompletion;


/**
 Initilizes contract authentication with custom scope. This will attempt to create a session and redirect
 to the Digi.me application.
 NOTE: If using this method, the delegate must NOT be set.

 @param scope custom scope that will be applied to available data.
 @param authorizationCompletion AuthorizationCompletionBlock
 */
- (void)authorizeWithScope:(nullable id<CADataRequest>)scope completion:(nullable AuthorizationCompletionBlock)authorizationCompletion;

/**
 Fetches file list that's available for the authorized contract.
 NOTE: If using this method, the delegate must be set.
 */
- (void)getFileList;


/**
 Fetches file list that's available for the authorized contract.
 NOTE: If using this method, the delegate must NOT be set.
 @param completion FileListCompletionBlock.
 */
- (void)getFileListWithCompletion:(nullable FileListCompletionBlock)completion;


/**
 Fetches file content for fileId. FileId is retrieve from fileList.
 NOTE: If using this method, the delegate must be set.

 @param fileId NSString - id of the file to fetch.
 */
- (void)getFileWithId:(NSString *)fileId;


/**
 Fetches file content for fileId. FileId is retrieve from fileList.
 NOTE: If using this method, the delegate must NOT be set.

 @param fileId NSString id if the file to fetch.
 @param completion FileContentCompletionBlock
 */
- (void)getFileWithId:(NSString *)fileId completion:(nullable FileContentCompletionBlock)completion;

/**
 Fetches the accounts available for the authorized contract.
 NOTE: If using this method, the delegate must be set.
 */
- (void)getAccounts;

/**
 Fetches the accounts available for the authorized contract.
 NOTE: If using this method, the delegate must NOT be set.
 @param completion AccountsCompletionBlock
 */
- (void)getAccountsWithCompletion:(nullable AccountsCompletionBlock)completion;

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

@end

NS_ASSUME_NONNULL_END
