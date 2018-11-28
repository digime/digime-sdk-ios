//
//  CATimeRange.h
//  DigiMeSDK
//
//  Created on 27/11/2018.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CATimeRangeUnit) {
    CATimeRangeUnitDay = 0,
    CATimeRangeUnitMonth = 1,
    CATimeRangeUnitYear = 2,
};

@interface CATimeRange : NSObject

@property (nonatomic, strong, readonly, nullable) NSDate *from;
@property (nonatomic, strong, readonly, nullable) NSDate *to;
@property (nonatomic, strong, readonly, nullable) NSString *last;

+ (CATimeRange *)from:(NSDate *)from;
+ (CATimeRange *)priorTo:(NSDate *)priorTo;
+ (CATimeRange *)from:(NSDate *)from to:(NSDate *)to;
+ (CATimeRange *)last:(int)x unit:(CATimeRangeUnit)unit;

@end

NS_ASSUME_NONNULL_END
