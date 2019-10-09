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
@class DMEFileList;
@protocol DMEDataRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 Client object used for getting data from the user, following their consent.
 */
@interface DMEPullClient: DMEClient

- (instancetype)initWithConfiguration:(DMEPullConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

/**
 Initializes contract authentication.
 This will first attempt to create a session.
 If session creation is successful will then follow different authentication flows
 depending on the value of `guestEnabled` flag in the configuration:
 - Guest is enabled:
         Either redirect to the digi.me application (if installed) or present options for user to choose a one-time share or download the digi.me app.
 - Guest is not enabled:
         Redirect to the digi.me application (if installed).
 @param completion Block called when authorization has completed
 */
- (void)authorizeWithCompletion:(DMEAuthorizationCompletion)completion;

/**
 Initializes contract authentication with custom scope.
 This will first attempt to create a session.
 If session creation is successful will then follow different authentication flows
 depending on the value of `guestEnabled` flag in the configuration:
 - Guest is enabled:
 Either redirect to the digi.me application (if installed) or present options for user to choose a one-time share or download the digi.me app.
 - Guest is not enabled:
 Redirect to the digi.me application (if installed).
 @param scope Custom scope that will be applied to available data.
 @param completion Block called when authorization has completed
 */
- (void)authorizeWithScope:(nullable id<DMEDataRequest>)scope completion:(DMEAuthorizationCompletion)completion NS_SWIFT_NAME(authorize(scope:completion:));

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
 Fetches file list which contains current snapshot of the sync progress, and a list of files that are available for download.
 
 @param completion Completion block executed once request has completed successfully.
 */
- (void)getFileListWithCompletion:(void (^)(DMEFileList * _Nullable fileList, NSError  * _Nullable error))completion;

/**
 Fetches the accounts available for the authorized contract.
 
 @param completion Reports result of fetch. Either contains the accounts or an error if fetch failed
 */
- (void)getSessionAccountsWithCompletion:(DMEAccountsCompletion)completion NS_SWIFT_NAME(getSessionAccounts(completion:));

@end

NS_ASSUME_NONNULL_END
