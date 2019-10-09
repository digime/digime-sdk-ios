//
//  DMETimeRange.h
//  DigiMeSDK
//
//  Created on 27/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Enum representing possible unit for a literal time range.
 */
typedef NS_ENUM(NSInteger, DMETimeRangeUnit) {
    DMETimeRangeUnitDay = 0,
    DMETimeRangeUnitMonth = 1,
    DMETimeRangeUnitYear = 2,
};

/**
 Time Range convenience object that describes a date period.
 */
@interface DMETimeRange : NSObject

@property (nonatomic, strong, readonly, nullable) NSDate *from;
@property (nonatomic, strong, readonly, nullable) NSDate *to;
@property (nonatomic, strong, readonly, nullable) NSString *last;

+ (DMETimeRange *)from:(NSDate *)from;
+ (DMETimeRange *)priorTo:(NSDate *)priorTo;
+ (DMETimeRange *)from:(NSDate *)from to:(NSDate *)to;
+ (DMETimeRange *)last:(NSUInteger)x unit:(DMETimeRangeUnit)unit;

@end

NS_ASSUME_NONNULL_END
