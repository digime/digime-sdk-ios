//
//  DMEServiceType.m
//  DigiMeSDK
//
//  Created on 21/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEServiceType.h"

@implementation DMEServiceType

- (instancetype)initWithIdentifier:(NSUInteger)identifier objectTypes:(NSArray<DMEServiceObjectType *> *)serviceObjectTypes
{
    self = [super init];
    
    if (self)
    {
        _identifier = identifier;
        _serviceObjectTypes = serviceObjectTypes;
    }
    
    return self;
}

@end
