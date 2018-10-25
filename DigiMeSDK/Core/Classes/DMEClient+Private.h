//
//  DMEClient+Private.h
//  Pods
//
//  Created on 16/10/2018.
//

#import "DMEClient.h"

@class DMECrypto, DMEAuthorizationManager, DMEAPIClient;

@interface DMEClient ()

@property (nonatomic, strong) DMEAppCommunicator *appCommunicator;

@property (nonatomic, strong, readwrite) CASessionManager *sessionManager;
@property (nonatomic, strong, readwrite) DMEAPIClient *apiClient;
@property (nonatomic, strong) DMECrypto *crypto;

@property (nonatomic, weak) DMEAuthorizationManager *authManager;

@end
