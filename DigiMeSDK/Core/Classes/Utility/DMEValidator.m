//
//  DMEValidator.m
//  DigiMeSDK
//
//  Created on 17/10/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMEValidator.h"

@implementation DMEValidator

+ (BOOL)validateContractId:(NSString *)contractId
{
    NSRange range = [contractId rangeOfString:@"^[a-zA-Z0-9_]+$" options:NSRegularExpressionSearch];
    
    return (range.location != NSNotFound && contractId.length > 5 && contractId.length < 64);
}

@end
