//
//  NSError+API.m
//  DigiMeSDK
//
//  Created on 31/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "NSError+API.h"

@implementation NSError (API)

+ (NSError *)apiErrorWithReason:(NSString * _Nullable)errorReason reference:(NSString * _Nullable)errorReference
{
    NSString *message = [@[[[self class] errorReason:errorReason], [[self class] errorReference:errorReference]] componentsJoinedByString:@","];
    return [NSError errorWithDomain:DME_API_ERROR code:[[self class] errorCode:errorReason] userInfo:@{ NSLocalizedDescriptionKey:message}];
}

+ (NSInteger)errorCode:(NSString * _Nullable)reasonErrorMessage
{
    // Example: failedToRetrieveContract(code: 404) -> 404
    NSString *pattern = @"(\\d+)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionSearch|NSCaseInsensitiveSearch error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:reasonErrorMessage options:0 range:NSMakeRange(0, [reasonErrorMessage length])];
    if (match != nil)
    {
        NSString *codeString = [reasonErrorMessage substringWithRange:[match rangeAtIndex:1]];
        if (codeString != nil && codeString.length > 0)
        {
            return [codeString integerValue];
        }
    }
    
    return -1;
}

+ (NSString *)errorReason:(NSString * _Nullable)reasonErrorMessage
{
    // Example: failedToRetrieveContract(code: 404) -> 'failedToRetrieveContract'
    NSString *pattern = @"((?:[a-z][a-z]+))";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionSearch|NSCaseInsensitiveSearch error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:reasonErrorMessage options:0 range:NSMakeRange(0, [reasonErrorMessage length])];
    if (match != nil)
    {
        NSString *messageString = [reasonErrorMessage substringWithRange:[match rangeAtIndex:1]];
        if (messageString != nil && messageString.length > 0)
        {
            return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Error message:", nil), messageString];
        }
    }
    
    return NSLocalizedString(@"Unknown error", nil);
}

+ (NSString *)errorReference:(NSString * _Nullable)reference
{
    if (reference != nil && reference.length > 0)
    {
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Error reference:", nil), reference];
    }
    else
    {
        return nil;
    }
}

@end
