//
//  DMECryptoUtilities.m
//  CASDK
//
//  Created on 24/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMECryptoUtilities.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import "NSString+DMECrypto.h"
#import "NSData+DMECrypto.h"

@implementation DMECryptoUtilities

+ (NSString *)privateKeyHexFromP12File:(NSString *)p12FileName password:(NSString *)password
{
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:p12FileName withExtension:@"p12"];
    
    if (!fileUrl)
    {
        NSLog(@"[DMECrypto] Error: Could not find '%@' in the bundle", p12FileName);
        return nil;
    }
    
    NSData *pkcs12_data = [[NSData alloc] initWithContentsOfURL:fileUrl];
    CFDataRef pkcs12_data_ref = (__bridge_retained CFDataRef)(pkcs12_data);
    
    NSDictionary *options = @{ (NSString *)kSecImportExportPassphrase : password };
    CFDictionaryRef options_ref = (__bridge_retained CFDictionaryRef)(options);
    
    CFArrayRef results_ref = NULL;

    OSStatus err = SecPKCS12Import(pkcs12_data_ref, options_ref, &results_ref);

    if (err != errSecSuccess)
    {
        //TODO log error
        NSLog(@"[DMECrypto] Error importing pkcs12: %@", @((NSInteger) err));
        return nil;
    }
    
    NSArray<NSDictionary<NSString *, id> *> *identityDicts = (__bridge NSArray<NSDictionary<NSString *, id> *> *)results_ref;
    SecIdentityRef identity_ref = (__bridge_retained SecIdentityRef)(identityDicts[0][(NSString *)kSecImportItemIdentity]);
    
    SecKeyRef private_key_ref = NULL;
    
    OSStatus copy_err = SecIdentityCopyPrivateKey(identity_ref, &private_key_ref);
    
    if (copy_err != errSecSuccess)
    {
        NSLog(@"[DMECrypto] Error extracting privateKeyRef: %@", @((NSInteger) copy_err));
        return nil;
    }

    if (@available(iOS 10.0, *))
    {
        CFErrorRef error_ref;
        CFDataRef data_ref = SecKeyCopyExternalRepresentation(private_key_ref, &error_ref);
        
        if (data_ref != NULL)
        {
            NSData *data = (__bridge NSData *)data_ref;
            return [data hexString];
        }
        else
        {
            NSLog(@"[DMECrypto] Error copying external key representation");
            return nil;
        }
    }
    else
    {
        NSDictionary *query = @{
                                (__bridge id)kSecClass : (__bridge id)kSecClassKey,
                                (__bridge id)kSecAttrApplicationTag : (__bridge id)private_key_ref,
                                (__bridge id)kSecReturnData : (__bridge id)kCFBooleanTrue
                                };
        CFTypeRef result_ref;
        OSStatus copy_err = SecItemCopyMatching((__bridge_retained CFDictionaryRef)query, &result_ref);
        
        if (copy_err != noErr)
        {
            NSLog(@"[DMECrypto] Error extracting key data: %@", @((NSInteger) err));
            return nil;
        }
        
        NSData *data = (__bridge NSData *)result_ref;
        
        if (!data)
        {
            NSLog(@"[DMECrypto] Unknown Error occurred");
            return nil;
        }
        
        return [data hexString];
    }
}

+ (BOOL)validateContractId:(NSString *)contractId
{
    NSRange range = [contractId rangeOfString:@"^[a-zA-Z0-9_]+$" options:NSRegularExpressionSearch];
    
    return (range.location != NSNotFound && contractId.length > 5 && contractId.length < 64);
}

@end
