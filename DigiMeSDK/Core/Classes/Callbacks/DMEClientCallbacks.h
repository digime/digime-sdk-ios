//
//  DMEClientCallbacks.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMESession.h"
#import "NSError+SDK.h"
#import "NSError+Auth.h"
#import "NSError+API.h"
#import "DMEFiles.h"
#import "DMEAccounts.h"

#pragma once

@class DMEPostbox, DMEFile;

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

extern NSString * const kFileIdKey;

/**
 DMEAccountsCompletion - executed when account metadata has been retrieved.

 @param accounts The accounts if retrieval is successful, nil if not
 @param error nil if retrieval is succesful, otherwise an error specifying what went wrong
 */
typedef void (^DMEAccountsCompletion) (DMEAccounts * _Nullable accounts, NSError * _Nullable error);

NS_ASSUME_NONNULL_END
