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

@class DMEClientConfiguration;
@class DMEPostbox;

NS_ASSUME_NONNULL_BEGIN

@interface DMEPushClient: DMEClient

- (instancetype)initWithConfiguration:(DMEClientConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

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
