//
//  CADataRequestSerializer.h
//  DigiMeSDK
//
//  Created on 27/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CADataRequest.h"
#import "NSError+SDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface CADataRequestSerializer : NSObject

+ (nullable NSDictionary *)serialize:(id<CADataRequest>)dataRequest;

@end

NS_ASSUME_NONNULL_END
