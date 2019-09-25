//
//  DMEStatusLogger.m
//  DigiMeSDK
//
//  Created on 23/09/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.//

#import "DMEStatusLogger.h"

@implementation DMEStatusLogger

+ (NSString *)getSDKStatus:(NSDictionary *)headerFields {
    
    NSString* sdkStatus = headerFields[@"x-digi-sdk-status"];
    NSString* sdkMessage = headerFields[@"x-digi-sdk-status-message"];
    
    if (sdkStatus != nil && sdkMessage != nil) {
        return [NSString stringWithFormat: @"\n===========================================================\nSDK Status: %@\n%@\n===========================================================", sdkStatus, sdkMessage];
    } else {
        return nil;
    }
}

@end
