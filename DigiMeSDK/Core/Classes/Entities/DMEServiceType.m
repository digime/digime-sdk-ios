//
//  DMEServiceType.m
//  DigiMeSDK
//
//  Created on 21/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEServiceType.h"

@interface DMEServiceType()

@property (nonatomic) NSUInteger serviceTypeId;
@property (nonatomic, strong) NSArray <DMEServiceObjectType *> *serviceObjectTypes;

@end

@implementation DMEServiceType

- (instancetype)initWithServiceType:(NSUInteger)serviceTypeId objectTypes:(NSArray<DMEServiceObjectType *> *)serviceObjectTypes
{
    self = [super init];
    
    if (self)
    {
        _serviceTypeId = serviceTypeId;
        _serviceObjectTypes = serviceObjectTypes;
    }
    
    return self;
}

@end
