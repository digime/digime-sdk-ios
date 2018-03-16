//
//  NSError+Auth.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "NSError+Auth.h"

@implementation NSError (Auth)

+ (NSError *)authError:(AuthError)authError
{
    return [NSError errorWithDomain:DME_AUTHORIZATION_ERROR code:authError userInfo:@{ NSLocalizedDescriptionKey: [[self class] authDescription:authError]}];
}

+ (NSString *)authDescription:(AuthError)authError
{
    switch (authError) {
        case AuthErrorGeneral:
            return @"Unknown authorization error has occurred.";
            break;
            
        case AuthErrorInvalidSession:
            return @"Invalid session.";
            break;
        
        case AuthErrorAppId:
            return @"App Id is not set. Please set appId property of DMEClient and try again.";
            break;
            
        case AuthErrorContract:
            return @"Contract not set. Please set contractId property of DMEClient and try again.";
            break;
            
        case AuthErrorCancelled:
            return @"User cancelled authorization.";
            break;
            
        case AuthErrorInProgress:
            return @"Authorization already in progress.";
            break;
            
        case AuthErrorPrivateHex:
            return @"RSA private key hex not set. Please set the privateKeyHex property of DMEClient and try again.";
            break;
            
        case AuthErrorAppNotFound:
            return @"Digi.me app is not installed.";
            break;
            
        case AuthErrorNotOnboarded:
            return @"Digi.me app is not connected to a library. SDK currently only supports CA when Digi.me app is conencted to a library.";
            break;
            
        case AuthErrorInvalidSessionKey:
            return @"Digi.me app returned an invalid session key.";
            break;
    }
    
    return NSLocalizedString(@"", @"");
}

@end
