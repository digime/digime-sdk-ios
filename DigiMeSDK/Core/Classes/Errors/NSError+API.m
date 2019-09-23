//
//  NSError+API.m
//  DigiMeSDK
//
//  Created on 31/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "NSError+API.h"

@implementation NSError (API)

+ (NSError *)apiError:(NSString *)errorMessage
{
    return [NSError errorWithDomain:DME_API_ERROR code:[[self class] errorCode:errorMessage] userInfo:@{ NSLocalizedDescriptionKey:[[self class] errorDescription:errorMessage]}];
}

+ (NSInteger)errorCode:(NSString *)errorMessage
{
    // Example: failedToRetrieveContract(code: 404) -> 404
    NSString *pattern = @"(\\d+)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionSearch|NSCaseInsensitiveSearch error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:errorMessage options:0 range:NSMakeRange(0, [errorMessage length])];
    if (match != nil)
    {
        NSString *codeString = [errorMessage substringWithRange:[match rangeAtIndex:1]];
        if (codeString != nil && codeString.length > 0)
        {
            return [codeString integerValue];
        }
    }
    
    return -1;
}

+ (NSString *)errorDescription:(NSString *)errorMessage
{
    // Example: failedToRetrieveContract(code: 404) -> 'failedToRetrieveContract'
    NSString *pattern = @"((?:[a-z][a-z]+))";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionSearch|NSCaseInsensitiveSearch error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:errorMessage options:0 range:NSMakeRange(0, [errorMessage length])];
    if (match != nil)
    {
        NSString *messageString = [errorMessage substringWithRange:[match rangeAtIndex:1]];
        if (messageString != nil && messageString.length > 0)
        {
            return messageString;
        }
    }
    
    return NSLocalizedString(@"Unknown error", nil);
}

@end
