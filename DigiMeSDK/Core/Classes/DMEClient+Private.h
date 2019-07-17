//
//  DMEClient+Private.h
//  DigiMeSDK
//
//  Created on 16/10/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEClient.h"

@class DMECrypto, DMENativeConsentManager, DMEAPIClient, DMEAppCommunicator;

@interface DMEClient ()

@property (nonatomic, strong) DMEAppCommunicator *appCommunicator;

@property (nonatomic, strong, readwrite) DMESessionManager *sessionManager;
@property (nonatomic, strong, readwrite) DMEAPIClient *apiClient;
@property (nonatomic, strong) DMECrypto *crypto;

@property (nonatomic, weak) DMENativeConsentManager *authManager;

@end
