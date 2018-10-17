//
//  DMEClientCallbacks.h
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "CASession.h"
#import "CAFiles.h"
#import "CAFile.h"
#import "CAAccounts.h"

#pragma once

NS_ASSUME_NONNULL_BEGIN


/**
 AuthorizationCompletionBlock - executed when authorization stage has completed.

 @param session CASession
 @param error NSError
 */
typedef void (^AuthorizationCompletionBlock) (CASession * _Nullable session, NSError * _Nullable error);


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
