//
//  NSError+Auth.m
//  DigiMeSDK
//
//  Created on 29/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
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
            
        case AuthErrorCancelled:
            return @"User cancelled authorization.";
            break;
            
        case AuthErrorInvalidSessionKey:
            return @"Digi.me app returned an invalid session key.";
            break;
    }
    
    return NSLocalizedString(@"", @"");
}

@end
