//
//  DMEClientDownloadDelegate.h
//  DigiMeSDK
//
//  Created on 09/07/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CASession.h"
#import "NSError+SDK.h"
#import "NSError+Auth.h"
#import "NSError+API.h"
#import "CAAccounts.h"
#import "CAFiles.h"
#import "CAFile.h"

#pragma once

NS_ASSUME_NONNULL_BEGIN

@protocol DMEClientDownloadDelegate <NSObject>

@optional

/**
 Executed when DMEClient has retrieved file list available for the contract.
 
 @param files CAFiles.
 */
- (void)clientRetrievedFileList:(CAFiles *)files;


/**
 Executed DMEClient failed to retrieve contract file list.
 
 @param error NSError.
 */
- (void)clientFailedToRetrieveFileList:(NSError *)error;


/**
 Executed when file content has been retrieved.
 
 @param file CAFile object.
 */
- (void)fileRetrieved:(CAFile *)file;


/**
 Executed when file could not be retrieved
 
 @param fileId Id of the file that failed
 @param error NSError
 */
- (void)fileRetrieveFailed:(NSString *)fileId error:(NSError *)error;


/**
 Executed when decryptsData flag is set to NO and file has been downloaded

 @param data NSData encrypted file data
 @param fileId NSString file identifier
 */
- (void)dataRetrieved:(NSData *)data fileId:(NSString *)fileId;


/**
 Executed when DMEClient has retrieved accounts available for the contract
 
 @param accounts available accounts
 */
- (void)accountsRetrieved:(CAAccounts *)accounts;


/**
 Executed when accounts could not be retrieved
 
 @param error error NSError
 */
- (void)accountsRetrieveFailed:(NSError *)error;


/**
 Executed when decryptsData flag is set to NO and accounts have been downloaded
 
 @param data NSData encrypted accounts data
 */
- (void)accountsDataRetrieved:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
