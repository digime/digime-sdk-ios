//
//  DMEClient+Postbox.h
//  DigiMeSDK
//
//  Created on 16/10/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClient.h"
#import "CAPostbox.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMEClient (Postbox)

/**
 Hands off to the DigiMe app to request a Postbox that can be used to send data to a user's library.
 NOTE: If using this method, the delegate must be set.
 */
- (void)createPostbox;

/**
 Hands off to the DigiMe app to request a Postbox that can be used to send data to a user's library.
 NOTE: If using this method, the delegate must NOT be set.
 
 @param completion PostboxCreationCompletionBlock
 */
- (void)createPostboxWithCompletion:(PostboxCreationCompletionBlock)completion;

/**
 Pushes data to user's Postbox.
 
 @param postbox CAPostbox
 @param metadata NSData
 @param data NSData
 @param completion PostboxDataPushCompletionBlock
 */
- (void)pushDataToPostbox:(CAPostbox *)postbox
                 metadata:(NSData *)metadata
                     data:(NSData *)data
               completion:(PostboxDataPushCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
