//
//  DMEServiceObjectType.m
//  DigiMeSDK
//
//  Created on 21/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEServiceObjectType.h"

@interface DMEServiceObjectType()

@property (nonatomic) NSUInteger serviceObjectTypeId;

@end

@implementation DMEServiceObjectType

- (instancetype)initWithServiceObjectType:(NSUInteger)serviceObjectTypeId
{
    self = [super init];
    
    if (self)
    {
        _serviceObjectTypeId = serviceObjectTypeId;
    }
    
    return self;
}

@end
