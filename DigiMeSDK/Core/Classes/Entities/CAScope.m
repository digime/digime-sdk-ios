//
//  CAScope.m
//  DigiMeSDK
//
//  Created on 27/11/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "CAScope.h"

@implementation CAScope

@synthesize context = _context;
@synthesize timeRanges = _timeRanges;

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
