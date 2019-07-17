//
//  DMEClientCallbacks.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "CASession.h"
#import "NSError+SDK.h"
#import "NSError+Auth.h"
#import "NSError+API.h"
#import "CAFiles.h"
#import "CAAccounts.h"

#pragma once

@class CAPostbox, CAFile;

NS_ASSUME_NONNULL_BEGIN

/**
 AuthorizationCompletionBlock - executed when authorization stage has completed.

 @param session CASession
 @param error NSError
 */
typedef void (^AuthorizationCompletionBlock) (CASession * _Nullable session, NSError * _Nullable error);

/**
 PostboxCompletionBlock - executed when a Postbox is retrieved.

 @param postbox CAPostbox
 @param error NSError
 */
typedef void (^PostboxCreationCompletionBlock) (CAPostbox * _Nullable postbox, NSError * _Nullable error);

/**
 PostboxDataPushCompletionBlock - executed when data has been pushed to Postbox.
 
 @param error NSError
 */
typedef void (^PostboxDataPushCompletionBlock) (NSError * _Nullable error);

/**
 FileListCompletionBlock - executed when file list has been retrieved.

 @param files CAFiles
 @param error NSError
 */
typedef void (^FileListCompletionBlock) (CAFiles * _Nullable files, NSError  * _Nullable error);


/**
 FileContentCompletionBlock - executed when a file has been retrieved.

 @param file CAFile
 @param error NSError
 */
typedef void (^FileContentCompletionBlock) (CAFile * _Nullable file, NSError * _Nullable error);


/**
 AccountsCompletionBlock - executed when account metadata has been retrieved.

 @param accounts CAAccounts
 @param error NSError
 */
typedef void (^AccountsCompletionBlock) (CAAccounts * _Nullable accounts, NSError * _Nullable error);

NS_ASSUME_NONNULL_END
