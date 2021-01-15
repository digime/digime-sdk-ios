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
 @param completion Block called on main thread when authorization has completed
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
 @param completion Block called on main thread when authorization has completed
 */
- (void)authorizeWithScope:(nullable id<DMEDataRequest>)scope completion:(DMEAuthorizationCompletion)completion NS_SWIFT_NAME(authorize(scope:completion:));

/**
 Initializes ongoing contract authentication. Once user has given consent in digi.me app all subsequent data retrieval calls will be done without digi.me client app involvement.
 This authorization flow enables 3rd parties to access protected resources, without requiring users to disclose their digi.me credentials to the consumers.
 
 @param completion Block called on main thread when authorization has completed
 */
- (void)authorizeOngoingAccessWithСompletion:(DMEOngoingAccessAuthorizationCompletion)completion NS_SWIFT_NAME(authorizeOngoingAccess(completion:));

/**
 Initializes ongoing contract authentication with custom scope. Once user has given consent in digi.me app all subsequent data retrieval calls will be done without digi.me client app involvement.
 This authorization flow enables 3rd parties to access protected resources, without requiring users to disclose their digi.me credentials to the consumers
 
 @param scope Custom scope that will be applied to available data.
 @param oAuthToken valid OAuth token
 @param completion Block called on main thread when authorization has completed
 */
- (void)authorizeOngoingAccessWithScope:(nullable id<DMEDataRequest>)scope oAuthToken:(DMEOAuthToken * _Nullable)oAuthToken completion:(DMEOngoingAccessAuthorizationCompletion)completion NS_SWIFT_NAME(authorizeOngoingAccess(scope:oAuthToken:completion:));

/**
 Fetches content for all the requested files.
 
 An attempt is made to fetch each requested file and the result of each attempt is passed back via the download handler.
 Therefore multiple the handlers may be called concurrently, so the handler should allow for this.
 
 N.B. A session must already have been authorized
 
 @param fileContentHandler Handler called after every file fetch attempt finishes. Either contains the file or an error if fetch failed
 @param completion Block called on main thread when fetch completed. Contains final snapshot of DMEFileList. Error object will be set if an error occurred, nil otherwise
 */
- (void)getSessionDataWithDownloadHandler:(DMEFileContentCompletion)fileContentHandler completion:(DMESessionDataCompletion)completion NS_SWIFT_NAME(getSessionData(downloadHandler:completion:));

/**
 Fetches file content for fileId. The fileId may be retrieved from the download handler in getSessionDataWithDownloadHandler:completion:.
 
 @param fileId NSString id if the file to fetch.
 @param completion Block called on main thread when fetch completed. Either contains the file or an error if fetch failed
 */
- (void)getSessionDataForFileWithId:(NSString *)fileId completion:(DMEFileContentCompletion)completion __attribute((deprecated("Use getSessionDataWithFileId:completion: instead."))) NS_SWIFT_UNAVAILABLE("Swift name now associated with getSessionDataWithFileId:completion:");

/**
 Fetches file content for fileId. The fileId may be retrieved from the download handler in getSessionDataWithDownloadHandler:completion:.
 
 @param fileId NSString id if the file to fetch.
 @param completion Block called on main thread when fetch completed. Either contains the file or an error if fetch failed
 */
- (void)getSessionDataWithFileId:(NSString *)fileId completion:(DMEFileContentCompletion)completion NS_SWIFT_NAME(getSessionData(fileId:completion:));


/**
 Polls for file list changes and notifies of any new updates.
 Not intended to be used in conjunction with `getSessionData(downloadHandler:completion:)`.
 
 @param updateHandler returns serialized representation of the latest file list snapshot,
 together with an array of fileIds that have been added or updated since last snapshot.
 Only notified when a change has occurred. See `DMESessionFileListCompletion` for details.
 
 @param completion Block called on main thread when file list has finished updating, and no more changes will come.
 Error object will be set if an error occurred, nil otherwise.
 */
- (void)getSessionFileListWithUpdateHandler:(DMESessionFileListCompletion)updateHandler completion:(void (^)(NSError * _Nullable error))completion NS_SWIFT_NAME(getSessionFileList(updateHandler:completion:));

/**
 Fetches file list which contains current snapshot of the sync progress, and a list of files that are available for download.
 
 @param completion Completion block executed on main thread once request has completed successfully.
 */
- (void)getFileListWithCompletion:(void (^)(DMEFileList * _Nullable fileList, NSError  * _Nullable error))completion;

/**
 Fetches the accounts available for the authorized contract.
 
 @param completion Block called on main thread when fetch completed. Either contains the accounts or an error if fetch failed
 */
- (void)getSessionAccountsWithCompletion:(DMEAccountsCompletion)completion NS_SWIFT_NAME(getSessionAccounts(completion:));

/**
 Cancels any active session fetching activity. No completion handlers will be called. Use this if you wish to stop receiving notification on the handlers.
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
