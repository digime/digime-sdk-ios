//
//  DMECryptoUtilities.m
//  DigiMeSDK
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
    CFRelease(pkcs12_data_ref);
    CFRelease(options_ref);

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
    CFRelease(identity_ref);
    
    if (copy_err != errSecSuccess)
    {
        NSLog(@"[DMECrypto] Error extracting privateKeyRef: %@", @((NSInteger) copy_err));
        return nil;
    }

    CFErrorRef error_ref;
    CFDataRef data_ref = SecKeyCopyExternalRepresentation(private_key_ref, &error_ref);
    
    if (data_ref == NULL)
    {
        NSLog(@"[DMECrypto] Error copying external key representation");
        return nil;
    }
    
    NSData *data = (__bridge NSData *)data_ref;
    NSString *hexKey = [data hexString];
    CFRelease(data_ref);
    return hexKey;
}

+ (BOOL)validateContractId:(NSString *)contractId
{
    NSRange range = [contractId rangeOfString:@"^[a-zA-Z0-9_]+$" options:NSRegularExpressionSearch];
    
    return (range.location != NSNotFound && contractId.length > 5 && contractId.length < 64);
}

@end
