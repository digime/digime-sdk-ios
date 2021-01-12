//
//  DMEAPIClient+Postbox.h
//  DigiMeSDK
//
//  Created on 23/05/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEAPIClient.h"
#import "DMEClientCallbacks.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMEAPIClient (Postbox)

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

/**
 Pushes data to user's Postbox.
 
 @param postbox Ongoing Postbox
 @param metadata NSData
 @param data NSData
 @param completion DMEOngoingPostboxCompletion
 */
- (void)pushDataToOngoingPostbox:(DMEOngoingPostbox *)postbox
                        metadata:(NSData *)metadata
                            data:(NSData *)data
                      completion:(DMEOngoingPostboxCompletion)completion;

@end

NS_ASSUME_NONNULL_END
