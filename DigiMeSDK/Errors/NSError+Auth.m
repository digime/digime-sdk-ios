//
//  NSError+Auth.m
//  CASDK
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
            return NSLocalizedString(@"Unknown authorization error has occurred.", nil);
            break;
            
        case AuthErrorInvalidSession:
            return NSLocalizedString(@"Invalid session.", nil);
            break;
        
        case AuthErrorAppId:
            return NSLocalizedString(@"App Id is not set. Please set appId property of DMEClient and try again.", nil);
            break;
            
        case AuthErrorContract:
            return NSLocalizedString(@"Contract not set. Please set contractId property of DMEClient and try again.", nil);
            break;
            
        case AuthErrorCancelled:
            return NSLocalizedString(@"User cancelled authorization.", nil);
            break;
            
        case AuthErrorInProgress:
            return NSLocalizedString(@"Authorization already in progress.", nil);
            break;
            
        case AuthErrorPrivateHex:
            return @"RSA private key hex not set. Please set the privateKeyHex property of DMEClient and try again.";
            break;
            
        case AuthErrorAppNotFound:
            return @"Digi.me app is not installed.";
            break;
            
        case AuthErrorNotOnboarded:
            return NSLocalizedString(@"Digi.me app is not connected to a library. SDK currently only supports CA when Digi.me app is conencted to a library.", nil);
            break;
            
        case AuthErrorInvalidSessionKey:
            return NSLocalizedString(@"Digi.me app returned an invalid session key.", nil);
            break;
            
        default:
            break;
    }
    return NSLocalizedString(@"", @"");
}

@end
