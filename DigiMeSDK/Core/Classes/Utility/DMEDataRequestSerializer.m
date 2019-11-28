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
static NSString * const dataRequestIdKey = @"id";
static NSString * const dataRequestServiceGroupsKey = @"serviceGroups";
static NSString * const dataRequestServiceTypesKey = @"serviceTypes";
static NSString * const dataRequestServiceObjectTypesKey = @"serviceObjectTypes";

@implementation DMEDataRequestSerializer

+ (NSDictionary *)serialize:(id<DMEDataRequest>)requestedScope
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSArray *serviceGroups = [self serializeDataRequest:requestedScope];
    NSArray *timeRanges = [self serializeTimeRanges:requestedScope];
    
    if (serviceGroups.count > 0)
    {
        result[dataRequestServiceGroupsKey] = serviceGroups;
    }
    
    if (timeRanges.count > 0)
    {
        result[timeRangesKey] = timeRanges;
    }

    return [result allKeys].count > 0 ? result : nil;
}

+ (NSArray *)serializeTimeRanges:(id<DMEDataRequest>)requestedScope
{
    NSMutableArray *serializedRanges = [NSMutableArray new];
    
    for (DMETimeRange *timeRange in requestedScope.timeRanges)
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
    
    return [serializedRanges copy];
}

+ (NSArray *)serializeDataRequest:(id<DMEDataRequest>)requestedScope
{
    NSMutableArray *serializedRanges = [NSMutableArray new];
    
    for (DMEServiceGroup *serviceGroup in requestedScope.serviceGroups)
    {
        NSMutableDictionary *groupsDict = [NSMutableDictionary new];
        groupsDict[dataRequestIdKey] = @(serviceGroup.identifier);
        NSMutableArray *serviceTypes = [NSMutableArray new];
        
        for (DMEServiceType *serviceType in serviceGroup.serviceTypes)
        {
            NSMutableDictionary *typesDict = [NSMutableDictionary new];
            typesDict[dataRequestIdKey] = @(serviceType.identifier);
            NSMutableArray *serviceObjectTypes = [NSMutableArray new];
            
            for (DMEServiceObjectType *serviceObjectType in serviceType.serviceObjectTypes)
            {
                NSDictionary *dict = @{ dataRequestIdKey: @(serviceObjectType.identifier) };
                [serviceObjectTypes addObject:dict];
            }
            
            typesDict[dataRequestServiceObjectTypesKey] = serviceObjectTypes;
            [serviceTypes addObject:typesDict];
        }
        
        groupsDict[dataRequestServiceTypesKey] = serviceTypes;
        [serializedRanges addObject:groupsDict];
    }
    
    return [serializedRanges copy];
}

@end
