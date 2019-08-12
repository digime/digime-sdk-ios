//
//  DMEClient+Private.h
//  DigiMeSDK
//
//  Created on 16/10/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMEClient.h"

@class DMEAPIClient, DMEAppCommunicator;

NS_ASSUME_NONNULL_BEGIN

@interface DMEClient ()

@property (nonatomic, strong) DMEAppCommunicator *appCommunicator;

@property (nonatomic, strong, readwrite) DMEAPIClient *apiClient;

- (nullable NSError *)validateClient;

- (instancetype)initWithConfiguration:(id<DMEClientConfiguration>)configuration NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
