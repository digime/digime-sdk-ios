//
//  DigiMeSDKExampleTests-Bridging-Header.h
//  DigiMeSDKExampleSwift
//
//  Created on 19/08/2019.
//  Copyright © 2019 digi.me. All rights reserved.
//

#ifndef DigiMeSDKExampleTests_Bridging_Header_h
#define DigiMeSDKExampleTests_Bridging_Header_h

#import <DigiMeSDK/DigiMeSDK.h>
#import <DigiMeSDK/DMECrypto.h>
#import <DigiMeSDK/DMEDataDecryptor.h>
#import <DigiMeSDK/NSData+DMECrypto.h>
#import <DigiMeSDK/NSString+DMECrypto.h>
#import <DigiMeSDK/DMEAPIClient.h>
#import <DigiMeSDK/DMEClientConfiguration.h>
#import <DigiMeSDK/DMEStatusLogger.h>
#import <DigiMeSDK/NSError+API.h>
#import <DigiMeSDK/NSError+Auth.h>
#import <DigiMeSDK/NSError+SDK.h>
#import <DigiMeSDK/DMEOperation.h>
#import <DigiMeSDK/DMEClient.h>
#import <DigiMeSDK/DMEClient+Private.h>
#import <DigiMeSDK/DMEAPIClient+Private.h>
#import <DigiMeSDK/DMESessionManager.h>
#import "DMEPullClient+Tests.h"
#import <DigiMeSDK/DMERequestFactory.h>
#import <DigiMeSDK/DMEDataRequestSerializer.h>
#import <DigiMeSDK/DMEAppCommunicator.h>
#import <DigiMeSDK/DMEAppCommunicator+Private.h>

#endif /* DigiMeSDKExampleTests_Bridging_Header_h */


@interface DMEAppCommunicator (Test)

- (NSURL *)digiMeBaseURL;
@property (nonatomic, strong) NSMutableArray<id<DMEAppCallbackHandler>> *callbackHandlers;

@end
