//
//  DMEClient.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClient.h"
#import "DMEClientCallbacks.h"

@class DMEPullConfiguration;
@protocol DMEDataRequest;

NS_ASSUME_NONNULL_BEGIN

@interface DMEPullClient: DMEClient

- (instancetype)initWithConfiguration:(DMEPullConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

/**
 Initializes contract authentication. This will attempt to create a session and redirect
 to the digi.me application.
 
 @param authorizationCompletion DMEAuthorizationCompletion
 */
- (void)authorizeWithCompletion:(DMEAuthorizationCompletion)authorizationCompletion;

/**
 Initilizes contract authentication with custom scope. This will attempt to create a session and redirect
 to the digi.me application.
 
 @param scope custom scope that will be applied to available data.
 @param authorizationCompletion AuthorizationCompletionBlock
 */
- (void)authorizeWithScope:(nullable id<DMEDataRequest>)scope completion:(DMEAuthorizationCompletion)authorizationCompletion NS_SWIFT_NAME(authorize(scope:completion:));

/**
 Initializes contract authentication. This will attempt to create a session and then either redirect
 to the digi.me application (if installed) or present options for user to choose a one-time share or download the digi.me app.
 
 @param completion Block called when authorization has completed
 */
- (void)authorizeGuestWithCompletion:(DMEAuthorizationCompletion)completion;

/**
 Initializes contract authentication with custom scope. This will attempt to create a session and then either redirect
 to the digi.me application (if installed) or present options for user to choose a one-time share or download the digi.me app.
 
 @param scope Custom scope that will be applied to available data
 @param completion Block called when authorization has completed
 */
- (void)authorizeGuestWithScope:(nullable id<DMEDataRequest>)scope completion:(DMEAuthorizationCompletion)completion;

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

@end

NS_ASSUME_NONNULL_END
