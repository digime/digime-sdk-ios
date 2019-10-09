//
//  DMEDataRequest.h
//  DigiMeSDK
//
//  Created on 27/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#pragma once

#import "DMETimeRange.h"

/**
 Protocol representing data scoping.
 */
@protocol DMEDataRequest <NSObject>

NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, strong, nullable) NSArray<DMETimeRange *> *timeRanges;
@property (nonatomic, strong, readonly) NSString *context;

NS_ASSUME_NONNULL_END

@end
