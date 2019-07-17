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

@class CAPostbox, DMEFile;

NS_ASSUME_NONNULL_BEGIN

/**
 AuthorizationCompletionBlock - executed when authorization stage has completed.

 @param session DMESession
 @param error NSError
 */
typedef void (^AuthorizationCompletionBlock) (DMESession * _Nullable session, NSError * _Nullable error);

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

 @param files DMEFiles
 @param error NSError
 */
typedef void (^FileListCompletionBlock) (DMEFiles * _Nullable files, NSError  * _Nullable error);


/**
 FileContentCompletionBlock - executed when a file has been retrieved.

 @param file DMEFile
 @param error NSError
 */
typedef void (^FileContentCompletionBlock) (DMEFile * _Nullable file, NSError * _Nullable error);


/**
 AccountsCompletionBlock - executed when account metadata has been retrieved.

 @param accounts DMEAccounts
 @param error NSError
 */
typedef void (^AccountsCompletionBlock) (DMEAccounts * _Nullable accounts, NSError * _Nullable error);

NS_ASSUME_NONNULL_END
