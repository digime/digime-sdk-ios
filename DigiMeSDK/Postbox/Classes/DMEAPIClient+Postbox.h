//
//  DMEAPIClient+Postbox.h
//  DigiMeSDK
//
//  Created on 23/05/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientConfiguration.h"
#import "DMEAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMEAPIClient (Postbox)

/**
 Pushes data to user's Postbox.
 
 @param postbox DMEPostbox
 @param metadata NSData
 @param data NSData
 @param completion PostboxDataPushCompletionBlock
 */
- (void)pushDataToPostbox:(DMEPostbox *)postbox
                 metadata:(NSData *)metadata
                     data:(NSData *)data
               completion:(PostboxDataPushCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
