//
//  DMEStatusLogger.h
//  DigiMeSDK
//
//  Created on 23/09/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMEStatusLogger : NSObject

/**
 Checks for SDK Status messages in response header fields
 
 @param headerFields NSDictionary
 @return notes about current SDK version status
 */
+ (NSString *)getSDKStatus:(NSDictionary *)headerFields;

@end

NS_ASSUME_NONNULL_END
