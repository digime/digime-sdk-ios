//
//  DMEDataRequestSerializer.m
//  DigiMeSDK
//
//  Created on 27/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEDataRequestSerializer.h"
#import <Foundation/Foundation.h>

static NSString * const lastKey = @"last";
static NSString * const fromKey = @"from";
static NSString * const toKey = @"to";
static NSString * const timeRangesKey = @"timeRanges";

@implementation DMEDataRequestSerializer

+ (NSDictionary *)serialize:(id<DMEDataRequest>)dataRequest
{
    
    NSMutableDictionary *dataRequestDict = [NSMutableDictionary new];
    NSMutableArray *serializedRanges = [NSMutableArray new];
    
    for (DMETimeRange *timeRange in dataRequest.timeRange)
    {
        NSMutableDictionary *rangeDict = [NSMutableDictionary new];
        NSDate *from = timeRange.from;
        NSDate *to = timeRange.to;
        NSString *last = timeRange.last;
        
        if (last != nil)
        {
            rangeDict[lastKey] = last;
        }
        else
        {
            if (from != nil)
            {
                rangeDict[fromKey] = @(from.timeIntervalSince1970);
            }
            
            if (to != nil)
            {
                rangeDict[toKey] = @(to.timeIntervalSince1970);
            }
        }
        
        if ([rangeDict allKeys].count > 0)
        {
            [serializedRanges addObject:rangeDict];
        }
    }
    
    if (serializedRanges.count > 0)
    {
        dataRequestDict[timeRangesKey] = serializedRanges;
    }
    
    return [dataRequestDict allKeys].count > 0 ? dataRequestDict : nil;
}

@end
