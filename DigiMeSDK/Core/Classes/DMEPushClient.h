//
//  DMEPushClient.h
//  DigiMeSDK
//
//  Created on 01/08/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClient.h"
#import "DMEClientCallbacks.h"

@class DMEPushConfiguration;
@class DMEPostbox;

NS_ASSUME_NONNULL_BEGIN

/**
Client object used for returning data to the user, following their consent.
*/
@interface DMEPushClient: DMEClient

- (instancetype)initWithConfiguration:(DMEPushConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

/**
 After you have pushed data into a postbox, you can trigger the digi.me app to then import the data into the user library.
 */
- (void)openDMEAppForPostboxImport;

/**
 Hands off to the DigiMe app to request a Postbox that can be used to send data to a user's library.
 
 @param completion DMEPostboxCreationCompletion
 */
- (void)createPostboxWithCompletion:(DMEPostboxCreationCompletion)completion;

/**
 Pushes data to user's Postbox.
 
 @param postbox DMEPostbox
 @param metadata NSData
 @param data NSData
 @param completion DMEPostboxDataPushCompletion
 */
- (void)pushDataToPostbox:(DMEPostbox *)postbox
                 metadata:(NSData *)metadata
                     data:(NSData *)data
               completion:(DMEPostboxDataPushCompletion)completion;

@end

NS_ASSUME_NONNULL_END
