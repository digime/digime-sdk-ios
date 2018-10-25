//
//  DMEClient+Postbox.h
//  DigiMeSDK
//
//  Created by Jacob King on 16/10/2018.
//

#import <Foundation/Foundation.h>
#import "DMEClient.h"

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

@end
