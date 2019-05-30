//
//  CADataRequest.h
//  DigiMeSDK
//
//  Created on 27/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "CATimeRange.h"

#ifndef CADataRequest_h
#define CADataRequest_h

@protocol CADataRequest <NSObject>

NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, strong, nullable) NSArray<CATimeRange *> *timeRanges;
@property (nonatomic, strong, readonly) NSString *context;

NS_ASSUME_NONNULL_END

@end

#endif /* CADataRequest_h */
