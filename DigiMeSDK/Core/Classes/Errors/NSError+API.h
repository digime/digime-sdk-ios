//
//  NSError+API.h
//  DigiMeSDK
//
//  Created on 31/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const DME_API_ERROR = @"me.digi.api";

@interface NSError (API)

+ (NSError *)apiErrorWithReason:(NSString * _Nullable)reasonErrorMessage reference:(NSString * _Nullable)errorReference;

@end

NS_ASSUME_NONNULL_END
