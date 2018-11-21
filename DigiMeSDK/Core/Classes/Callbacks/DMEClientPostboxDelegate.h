//
//  DMEClientPostboxDelegate.h
//  DigiMeSDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma once

@class CAPostbox;

NS_ASSUME_NONNULL_BEGIN

@protocol DMEClientPostboxDelegate <NSObject>

@optional


/**
 Executed when a Postbox is created successfully.

 @param postbox The created Postbox.
 */
- (void)postboxCreationSucceeded:(CAPostbox *)postbox;


/**
 Executed when a Postbox cannot be created.

 @param error The error that occurred.
 */
- (void)postboxCreationFailed:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
