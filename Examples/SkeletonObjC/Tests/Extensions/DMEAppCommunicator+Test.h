//
//  DMEAppCommunicator+Test.h
//  DigiMeSDKExample_tests
//
//  Created on 27/11/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#pragma once

#import <DigiMeSDK/DigiMeSDK.h>
#import <DigiMeSDK/DMEAppCommunicator.h>
#import <DigiMeSDK/DMEAppCommunicator+Private.h>

@interface DMEAppCommunicator (Test)

- (NSURL *)digiMeBaseURL;
@property (nonatomic, strong) NSMutableArray<id<DMEAppCallbackHandler>> *callbackHandlers;

@end
