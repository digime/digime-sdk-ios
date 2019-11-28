//
//  DMEServiceGroup.h
//  DigiMeSDK
//
//  Created on 21/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEServiceGroup.h"

@implementation DMEServiceGroup

- (instancetype)initWithIdentifier:(NSUInteger)identifier serviceTypes:(NSArray<DMEServiceType *> *)serviceTypes
{
    self = [super init];
    
    if (self)
    {
        _identifier = identifier;
        _serviceTypes = serviceTypes;
    }
    
    return self;
}

@end
