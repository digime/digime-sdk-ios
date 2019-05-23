//
//  DMEAPIClient.h
//  DigiMeSDK
//
//  Created on 26/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEClientConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMEAPIClient (Postbox)

/**
 Pushes data to user's Postbox.
 
 @param postbox CAPostbox
 @param metadata NSData
 @param data NSData
 @param completion PostboxDataPushCompletionBlock
 */
- (void)pushDataToPostboxWithPostbox:(CAPostbox *)postbox
                      metadataToPush:(NSData *)metadata
                          dataToPush:(NSData *)data
                          completion:(void(^)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
