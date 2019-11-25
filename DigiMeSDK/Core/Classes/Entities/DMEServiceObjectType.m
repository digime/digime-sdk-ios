//
//  DMEServiceObjectType.m
//  DigiMeSDK
//
//  Created on 21/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEServiceObjectType.h"

static NSString * const kServiceObjectTypeId = @"id";

@interface DMEServiceObjectType()

@property (nonatomic, strong, readwrite) NSNumber *serviceObjectTypeId;

@end

@implementation DMEServiceObjectType

- (instancetype)initWithServiceObjectType:(NSNumber *)serviceObjectTypeId
{
    self = [super init];
    
    if (self)
    {
        _serviceObjectTypeId = serviceObjectTypeId;
    }
    
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeObject:self.serviceObjectTypeId forKey:kServiceObjectTypeId];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    NSNumber *serviceObjectTypeId = [coder decodeObjectForKey:kServiceObjectTypeId];
    
    if (self = [self initWithServiceObjectType:serviceObjectTypeId])
    {
        self.serviceObjectTypeId = [coder decodeObjectForKey:kServiceObjectTypeId];
    }
    
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithServiceObjectType:self.serviceObjectTypeId];
}

@end
