//
//  DMEServiceType.m
//  DigiMeSDK
//
//  Created on 21/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEServiceType.h"

static NSString * const kServiceTypeId = @"id";
static NSString * const kServiceObjectTypes = @"serviceObjectTypes";

@interface DMEServiceType()

@property (nonatomic, strong, readwrite) NSNumber *serviceTypeId;
@property (nonatomic, strong, readwrite, nullable) NSArray <DMEServiceObjectType *> *serviceObjectTypes;

@end

@implementation DMEServiceType

- (instancetype)initWithServiceType:(NSNumber *)serviceTypeId objectTypes:(NSArray<DMEServiceObjectType *> *)serviceObjectTypes
{
    self = [super init];
    
    if (self)
    {
        _serviceTypeId = serviceTypeId;
        _serviceObjectTypes = serviceObjectTypes;
    }
    
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeObject:self.serviceTypeId forKey:kServiceTypeId];
    [coder encodeObject:self.serviceObjectTypes forKey:kServiceObjectTypes];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    NSNumber *serviceTypeId = [coder decodeObjectForKey:kServiceTypeId];
    NSArray <DMEServiceObjectType *> *serviceObjectTypes = [coder decodeObjectForKey:kServiceObjectTypes];
    if (self = [self initWithServiceType:serviceTypeId objectTypes:serviceObjectTypes])
    {
        self.serviceTypeId = serviceTypeId;
        self.serviceObjectTypes = serviceObjectTypes;
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithServiceType:self.serviceTypeId objectTypes:self.serviceObjectTypes];
}

@end
