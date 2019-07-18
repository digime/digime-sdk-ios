//
//  DMETimeRange.m
//  DigiMeSDK
//
//  Created on 27/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMETimeRange.h"

@interface DMETimeRange()

@property (nonatomic, strong, nullable, readwrite) NSDate *from;
@property (nonatomic, strong, nullable, readwrite) NSDate *to;
@property (nonatomic, strong, nullable, readwrite) NSString *last;

@end

@implementation DMETimeRange

+ (DMETimeRange *)from:(NSDate *)from
{
    DMETimeRange *range = [DMETimeRange new];
    range.from = from;
    
    return range;
}

+ (DMETimeRange *)from:(NSDate *)from to:(NSDate *)to
{
    if ([to timeIntervalSinceDate:from] <= 0)
    {
        [NSException raise:NSInternalInconsistencyException format:@"`from` date must be *before* `to` date."];
    }
    
    DMETimeRange *range = [DMETimeRange new];
    range.from = from;
    range.to = to;
    
    return range;
}

+ (DMETimeRange *)priorTo:(NSDate *)priorTo
{
    DMETimeRange *range = [DMETimeRange new];
    range.to = priorTo;
    
    return range;
}

+ (DMETimeRange *)last:(NSUInteger)x unit:(DMETimeRangeUnit)unit
{
    DMETimeRange *range = [DMETimeRange new];
    NSString *unitString = [[self class] stringFromUnit:unit];
    range.last = [NSString stringWithFormat:@"%@%@", @(x), unitString];
    
    return range;
}

+ (NSString *)stringFromUnit:(DMETimeRangeUnit)unit
{
    switch (unit) {
        case DMETimeRangeUnitDay:
            return @"d";
            
        case DMETimeRangeUnitMonth:
            return @"m";
            
        case DMETimeRangeUnitYear:
            return @"y";
    }
}

@end
