//
//  DMESessionDeserializer.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMESessionDeserializer.h"

@implementation DMESessionDeserializer

+ (DMESession *)deserialize:(NSData *)jsonData sessionManager:(DMESessionManager *)sessionManager contractId:(NSString *)contractId error:(NSError * __autoreleasing *)error
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:error];
    
    NSString *sessionKey = json[@"sessionKey"];
    NSString *sessionExchangeToken = json[@"sessionExchangeToken"];
    NSNumber *expiry = json[@"expiry"];
    
    if (sessionKey && sessionExchangeToken && expiry)
    {
        NSDate *expiryDate = [NSDate dateWithTimeIntervalSince1970:expiry.doubleValue/1000];
        return [[DMESession alloc] initWithSessionKey:sessionKey exchangeToken:sessionExchangeToken expiryDate:expiryDate contractId:contractId sessionManager:sessionManager];
    }
    
    return nil;
}

@end
