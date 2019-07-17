//
//  CASessionDeserializer.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "CASessionDeserializer.h"
#import "DMEClient.h"

@implementation CASessionDeserializer

+ (DMESession *)deserialize:(NSData *)jsonData error:(NSError * __autoreleasing *)error
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:error];
    
    NSString *sessionKey = json[@"sessionKey"];
    NSString *sessionExchangeToken = json[@"sessionExchangeToken"];
    NSDate *expiry = [NSDate dateWithTimeIntervalSince1970:[json[@"expiry"] doubleValue]/1000];
    
    if (sessionKey && sessionExchangeToken && expiry)
    {
        return [[DMESession alloc] initWithSessionKey:sessionKey exchangeToken:sessionExchangeToken expiryDate:expiry sessionManager:[DMEClient sharedClient].sessionManager];
    }
    
    return nil;
}

@end
