//
//  DMEAuthorityPublicKey.m
//  DigiMeSDK
//
//  Created on 14/01/2020.
//  Copyright © 2020 digi.me Limited. All rights reserved.
//

#import "DMEAuthorityPublicKey.h"

@interface DMEAuthorityPublicKey ()

@property (nonatomic, strong, nonnull, readwrite) NSString *publicKey;
@property (nonatomic, strong, nonnull) NSDate *date;

@end

@implementation DMEAuthorityPublicKey

#pragma mark - Initialization

- (instancetype)initWithPublicKey:(NSString *)publicKey date:(NSDate *)date
{
    self = [super init];
    
    if (self)
    {
        _publicKey = publicKey;
        _date = date;
    }
    
    return self;
}

- (BOOL)isValid
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMinute:15];
    NSDate *validationDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self.date options:0];
    NSDate *now = [NSDate date];
    return ([now compare:validationDate] == NSOrderedAscending && [now compare:self.date] == NSOrderedDescending);
}

@end
