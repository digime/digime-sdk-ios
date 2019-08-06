//
//  DMEDataRequest.h
//  DigiMeSDK
//
//  Created on 27/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMETimeRange.h"

#ifndef DMEDataRequest_h
#define DMEDataRequest_h

@protocol DMEDataRequest <NSObject>

NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, strong, nullable) NSArray<DMETimeRange *> *timeRange;
@property (nonatomic, strong, readonly) NSString *context;

NS_ASSUME_NONNULL_END

@end

#endif /* DMEDataRequest_h */
