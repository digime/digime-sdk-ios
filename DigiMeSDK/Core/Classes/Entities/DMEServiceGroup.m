//
//  DMEServiceGroup.h
//  DigiMeSDK
//
//  Created on 21/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEServiceGroup.h"

@interface DMEServiceGroup()

@property (nonatomic) NSUInteger serviceGroupId;
@property (nonatomic, strong) NSArray<DMEServiceType *> *serviceTypes;

@end

@implementation DMEServiceGroup

- (instancetype)initWithServiceGroup:(NSUInteger)serviceGroupId serviceTypes:(NSArray<DMEServiceType *> *)serviceTypes
{
    self = [super init];
    
    if (self)
    {
        _serviceGroupId = serviceGroupId;
        _serviceTypes = serviceTypes;
    }
    
    return self;
}

@end
