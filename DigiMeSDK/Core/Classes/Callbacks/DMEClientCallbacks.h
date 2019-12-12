//
//  DMEClientCallbacks.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "NSError+SDK.h"
#import "NSError+Auth.h"
#import "NSError+API.h"

#pragma once

@class DMEAccounts;
@class DMEFile;
@class DMEPostbox;
@class DMESession;
@class DMEFileList;

NS_ASSUME_NONNULL_BEGIN

/**
 DMEAuthorizationCompletion - executed when authorization stage has completed.

 @param session The session if authorization is successful, nil if not
 @param error nil if authorization is successful, otherwise an error specifying what went wrong
 */
typedef void (^DMEAuthorizationCompletion) (DMESession * _Nullable session, NSError * _Nullable error);

/**
 DMEPostboxCreationCompletion - executed when a Postbox is created.

 @param postbox The Postbox if creation is successful, nil if not
 @param error nil if Postbox creation is successful, otherwise an error specifying what went wrong
 */
typedef void (^DMEPostboxCreationCompletion) (DMEPostbox * _Nullable postbox, NSError * _Nullable error);

/**
 DMEPostboxDataPushCompletion - executed when data has been pushed to Postbox.
 
 @param error nil if push is succesful, otherwise an error specifying what went wrong
 */
typedef void (^DMEPostboxDataPushCompletion) (NSError * _Nullable error);

/**
 DMEFileContentCompletion - executed when a file has been retrieved.

 @param file The file if retrieval is successful, nil if not
 @param error nil if retrieval is succesful, otherwise an error specifying what went wrong. The error's user info will contain the id of the file this error relates to. e.g.
 @code
     NSString *fileId = error.userInfo[kFileIdKey];
 @endcode
 */
typedef void (^DMEFileContentCompletion) (DMEFile * _Nullable file, NSError * _Nullable error);

/**
 DMESessionFileListCompletion - executed when getFileList response has changed.
 
 @param fileList FileList object, representing latest file list snapshot.
 @param fileIds Array of string, fileIds. Only fileIds added, or updated since the last snapshot are included.
 */
typedef void (^DMESessionFileListCompletion) (DMEFileList *fileList, NSArray<NSString *> *fileIds);

/**
DMESessionDataCompletion - executed when session data fetching has completed.

@param fileList FileList object, representing latest file list snapshot. This can be used to verify sync status state.
@param error nil if session data fetching completed succesfully, otherwise an error specifying what went wrong.
*/
typedef void (^DMESessionDataCompletion) (DMEFileList * _Nullable fileList, NSError * _Nullable error);

extern NSString * const kFileIdKey;

/**
 DMEAccountsCompletion - executed when account metadata has been retrieved.

 @param accounts The accounts if retrieval is successful, nil if not
 @param error nil if retrieval is succesful, otherwise an error specifying what went wrong
 */
typedef void (^DMEAccountsCompletion) (DMEAccounts * _Nullable accounts, NSError * _Nullable error);

NS_ASSUME_NONNULL_END
