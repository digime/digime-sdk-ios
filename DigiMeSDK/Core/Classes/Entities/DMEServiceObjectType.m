//
//  DMEServiceObjectType.m
//  DigiMeSDK
//
//  Created on 21/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEServiceObjectType.h"

@implementation DMEServiceObjectType

- (instancetype)initWithIdentifier:(NSUInteger)identifier
{
    self = [super init];
    
    if (self)
    {
        _identifier = identifier;
    }
    
    return self;
}

@end
