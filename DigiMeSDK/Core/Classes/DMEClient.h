//
//  DMEClient.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEScope.h"
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

 @param authorizationCompletion DMEAuthorizationCompletion
 */
- (void)authorizeWithCompletion:(DMEAuthorizationCompletion)authorizationCompletion;


/**
 Initilizes contract authentication with custom scope. This will attempt to create a session and redirect
 to the Digi.me application.

 @param scope custom scope that will be applied to available data.
 @param authorizationCompletion AuthorizationCompletionBlock
 */
- (void)authorizeWithScope:(nullable id<DMEDataRequest>)scope completion:(DMEAuthorizationCompletion)authorizationCompletion NS_SWIFT_NAME(authorize(scope:completion:));

/**
 Fetches content for all the requested files.
 
 An attempt is made to fetch each requested file and the result of each attempt is passed back via the download handler.
 Therefore multiple the handlers may be called concurrently, so the handler should allow for this.
 
 N.B. A session must already have been authorized

 @param fileContentHandler Handler called after every file fetch attempt finishes. Either contains the file or an error if fetch failed
 @param completion Contains nil once all file fetches have been attempted, or an error if unable to attempt any fetch
 */
- (void)getSessionDataWithDownloadHandler:(DMEFileContentCompletion)fileContentHandler completion:(void (^)(NSError * _Nullable error))completion NS_SWIFT_NAME(getSessionData(downloadHandler:completion:));

/**
 Fetches file content for fileId. The fileId may be retrieved from the download handler in getSessionDataWithDownloadHandler:completion:.

 @param fileId NSString id if the file to fetch.
 @param completion Reports result of fetch. Either contains the file or an error if fetch failed
 */
- (void)getSessionDataForFileWithId:(NSString *)fileId completion:(DMEFileContentCompletion)completion NS_SWIFT_NAME(getSessionData(fileId:completion:));

/**
 Fetches the accounts available for the authorized contract.
 
 @param completion Reports result of fetch. Either contains the accounts or an error if fetch failed
 */
- (void)getSessionAccountsWithCompletion:(DMEAccountsCompletion)completion NS_SWIFT_NAME(getSessionAccounts(completion:));

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
 
 @param error NSError pointer, this method can throw various SDK-related errors; catch and handle them here.
 @return YES if able to open digi.me app, NO if not or some other SDK-related error occurred.
 */
- (BOOL)viewReceiptInDigiMeAppWithError:(NSError * __autoreleasing * __nullable)error;

@end

NS_ASSUME_NONNULL_END
