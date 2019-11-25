//
//  DMEServiceGroup.h
//  DigiMeSDK
//
//  Created on 21/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "DMEServiceGroup.h"

static NSString * const kServiceGroupId = @"id";
static NSString * const kServiceTypes = @"serviceTypes";

@interface DMEServiceGroup()

@property (nonatomic, strong, readwrite) NSNumber *serviceGroupId;
@property (nonatomic, strong, readwrite, nullable) NSArray<DMEServiceType *> *serviceTypes;

@end

@implementation DMEServiceGroup

- (instancetype)initWithServiceGroup:(NSNumber *)serviceGroupId serviceTypes:(NSArray<DMEServiceType *> * _Nullable)serviceTypes
{
    self = [super init];
    
    if (self)
    {
        _serviceGroupId = serviceGroupId;
        _serviceTypes = serviceTypes;
    }
    
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeObject:self.serviceGroupId forKey:kServiceGroupId];
    [coder encodeObject:self.serviceTypes forKey:kServiceTypes];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    NSNumber *serviceGroupId = [coder decodeObjectForKey:kServiceGroupId];
    NSArray<DMEServiceType *> *serviceTypes = [coder decodeObjectForKey:kServiceTypes];
    if (self = [self initWithServiceGroup:serviceGroupId serviceTypes:serviceTypes])
    {
        self.serviceGroupId = serviceGroupId;
        self.serviceTypes = serviceTypes;
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithServiceGroup:self.serviceGroupId serviceTypes:self.serviceTypes];
}

@end
