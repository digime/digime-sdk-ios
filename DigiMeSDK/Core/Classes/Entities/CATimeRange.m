//
//  CATimeRange.m
//  DigiMeSDK
//
//  Created on 27/11/2018.
//

#import "CATimeRange.h"

@interface CATimeRange()

@property (nonatomic, strong, nullable, readwrite) NSDate *from;
@property (nonatomic, strong, nullable, readwrite) NSDate *to;
@property (nonatomic, strong, nullable, readwrite) NSString *last;

@end

@implementation CATimeRange

+ (CATimeRange *)from:(NSDate *)from
{
    CATimeRange *range = [CATimeRange new];
    range.from = from;
    
    return range;
}

+ (CATimeRange *)from:(NSDate *)from to:(NSDate *)to
{
    CATimeRange *range = [CATimeRange new];
    range.from = from;
    range.to = to;
    
    return range;
}

+ (CATimeRange *)priorTo:(NSDate *)priorTo
{
    CATimeRange *range = [CATimeRange new];
    range.to = priorTo;
    
    return range;
}

+ (CATimeRange *)last:(int)x unit:(CATimeRangeUnit)unit
{
    CATimeRange *range = [CATimeRange new];
    NSString *unitString = [[self class] stringFromUnit:unit];
    range.last = [NSString stringWithFormat:@"%i%@", x, unitString];
    
    return range;
}

+ (NSString *)stringFromUnit:(CATimeRangeUnit)unit
{
    switch (unit) {
        case CATimeRangeUnitDay:
            return @"d";
            
        case CATimeRangeUnitMonth:
            return @"m";
            
        case CATimeRangeUnitYear:
            return @"y";
    }
}

@end
