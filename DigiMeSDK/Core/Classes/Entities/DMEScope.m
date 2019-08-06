//
//  DMEScope.m
//  DigiMeSDK
//
//  Created on 27/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEScope.h"

@implementation DMEScope

@synthesize context = _context;
@synthesize timeRange = _timeRange;

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _context = @"scope";
    }
    return self;
}

@end
