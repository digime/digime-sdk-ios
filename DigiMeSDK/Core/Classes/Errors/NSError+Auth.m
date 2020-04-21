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
    return [[self class] authError:authError additionalInfo:nil];
}

+ (NSError *)authError:(AuthError)authError additionalInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)additionalInfo
{
    NSMutableDictionary<NSErrorUserInfoKey, id> *userInfo = [additionalInfo mutableCopy] ?: [NSMutableDictionary dictionary];
    userInfo[NSLocalizedDescriptionKey] = [[self class] authDescription:authError];
    return [NSError errorWithDomain:DME_AUTHORIZATION_ERROR code:authError userInfo:[userInfo copy]];
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
            return @"digi.me app returned an invalid session key.";
            break;
            
        case AuthErrorScopeOutOfBounds:
            return @"Requested scope is out of bounds of the Contract scope.";
            break;
            
        case AuthErrorOAuthTokenExpired:
            return @"OAuthToken expired. Use `authorize` without token in order to get a new token.";
            break;
    }

    return NSLocalizedString(@"", @"");
}

+ (NSError *)authError:(AuthError)authError reference:(nullable NSString *)errorReference
{
    if ([errorReference length] > 0)
    {
        NSMutableDictionary<NSErrorUserInfoKey, id> *userInfo = [NSMutableDictionary dictionary];
        NSString *errorDescription = [[self class] authDescription:authError];
        userInfo[NSLocalizedDescriptionKey] = [NSString stringWithFormat:@"%@ %@ %@", errorDescription, NSLocalizedString(@"Reference:", nil), errorReference];
        return [NSError errorWithDomain:DME_AUTHORIZATION_ERROR code:authError userInfo:[userInfo copy]];
    }
    else
    {
        return [[self class] authError:authError];
    }
}

@end
