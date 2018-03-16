//
//  DMECrypto.m
//  DigiMeSDK
//
//  Created on 25/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMECrypto.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import "NSString+DMECrypto.h"
#import "NSData+DMECrypto.h"

static NSString* kPrivateKeyIdentifier    = @"me.digi.digime.privatekey";
static const NSInteger __attribute__((unused)) kDataSymmetricKeyLength = 32;
static const NSInteger kDataInitializationVectorLength = 16;
static const NSInteger kDataSymmetricKeyLengthCA = 256;
static const NSInteger kHashLength = 64;

@implementation DMECrypto

#pragma mark - Keychain

- (BOOL)addPrivateKeyHex:(NSString *)privateKeyHex
{
    NSData* privateKeyData = [privateKeyHex hexToBytes];
    BOOL result = [self saveRSAKeyWithKeyClass:kSecAttrKeyClassPrivate keyData:privateKeyData keyTagString:kPrivateKeyIdentifier overwrite:YES];
    return result;
}

- (NSData *)privateKeyHex
{
    NSData* keyData = [self loadRSAKeyDataWithKeyClass:kSecAttrKeyClassPrivate keyTagString:kPrivateKeyIdentifier];
    return keyData;
}

#pragma mark - Log

- (void)logCCCryptorStatus:(CCCryptorStatus)status
{
    switch ( status )
    {
        case kCCSuccess:
            NSLog(@"[DMECrypto] CCCryptoStatus success.");
            break;
            
        case kCCParamError:
            NSLog(@"[DMECrypto] Illegal parameter supplied to encryption/decryption algorithm.");
            break;
            
        case kCCBufferTooSmall:
            NSLog(@"[DMECrypto] Insufficient buffer provided for specified operation.");
            break;
            
        case kCCMemoryFailure:
            NSLog(@"[DMECrypto] Failed to allocate memory.");
            break;
            
        case kCCAlignmentError:
            NSLog(@"[DMECrypto] Input size to encryption algorithm was not aligned correctly.");
            break;
            
        case kCCDecodeError:
            NSLog(@"[DMECrypto] Input data did not decode or decrypt correctly.");
            break;
            
        case kCCUnimplemented:
            NSLog(@"[DMECrypto] Function not implemented for the current algorithm.");
            break;
            
        default:
            NSLog(@"[DMECrypto] Unknown Error.");
            break;
    }
}

#pragma mark - Decrypt file content

- (NSData *)getDataFromEncryptedBytes:(NSData *)encryptedData privateKeyData:(NSData *)privateKeyData
{
    //convert data back to privateKey.
    [self saveRSAKeyWithKeyClass:kSecAttrKeyClassPrivate keyData:privateKeyData keyTagString:kPrivateKeyIdentifier overwrite:YES];
    SecKeyRef privateKey = [self loadRSAKeyWithKeyClass:kSecAttrKeyClassPrivate keyTagString:kPrivateKeyIdentifier];
    
    NSAssert(encryptedData.length >= 352, @"CA raw file size is wrong");
    NSAssert(0 == (encryptedData.length %16), @"CA raw file size mod 16 is wrong");
    NSData* encryptedDsk = [encryptedData subdataWithRange:NSMakeRange(0,256)];
    
    OSStatus status             = noErr;
    size_t   plainBufferSize    = SecKeyGetBlockSize(privateKey);
    uint8_t* plainBuffer        = malloc(plainBufferSize);
    uint8_t* cipherBuffer1      = (uint8_t*)[encryptedDsk bytes];
    size_t   cipherBufferSize1  = SecKeyGetBlockSize(privateKey);
    
    status = SecKeyDecrypt(privateKey,
                           kSecPaddingOAEP,
                           cipherBuffer1,
                           cipherBufferSize1,
                           plainBuffer,
                           &plainBufferSize);
    
    NSAssert(status == noErr, @"RSA decryption failed");
    
    NSData* decryptedDsk = [NSData dataWithBytes:plainBuffer length:plainBufferSize];
    NSAssert(decryptedDsk.length == kDataSymmetricKeyLength, @"Decrypted DSK size is wrong");
    
    NSData* div = [encryptedData subdataWithRange:NSMakeRange(kDataSymmetricKeyLengthCA,kDataInitializationVectorLength)];
    NSData* fileData = [encryptedData subdataWithRange:NSMakeRange((kDataSymmetricKeyLengthCA+kDataInitializationVectorLength),encryptedData.length-(kDataSymmetricKeyLengthCA+kDataInitializationVectorLength))];
    
    NSError* error;
    NSData* jfsDataWithHash = [self decryptAes256UsingKey:decryptedDsk
                                     initializationVector:div
                                                     data:fileData
                                                    error:&error];
    NSAssert(error == nil, @"An error occured");
    
    NSData* jfsDataHash __attribute__((unused)) = [jfsDataWithHash subdataWithRange:NSMakeRange(0, kHashLength)];
    NSData* jfsData = [jfsDataWithHash subdataWithRange:NSMakeRange(kHashLength, jfsDataWithHash.length - kHashLength)];
    NSData* newJfsDataHash __attribute__((unused)) = [jfsData hashSha512];
    
    NSAssert(jfsData != nil, @"JFS data cannot be nil");
    NSAssert([newJfsDataHash isEqualToData:jfsDataHash], @"Hash doesn't match");
    
    return jfsData;
}

- (NSData *)decryptAes256UsingKey:(NSData*)keyData initializationVector:(NSData *)ivData data:(NSData *)data error:(NSError * __autoreleasing *)error
{
    CCCryptorStatus status = kCCSuccess;
    NSData * result = [self decryptedDataUsingAlgorithm:kCCAlgorithmAES128
                                                    key:keyData
                                   initializationVector:ivData
                                                options:kCCOptionPKCS7Padding
                                              keyLength:kCCKeySizeAES256
                                                   data:data
                                                  error:&status];
    if (result != nil)
        return result;
    
    [self logCCCryptorStatus:status];
    
    return ( nil );
}

#pragma mark - RSA Key operations

-(BOOL)saveRSAKeyWithKeyClass:(CFTypeRef) keyClass keyData:(NSData*)keyData keyTagString:(NSString*)keyTagString overwrite:(BOOL) overwrite
{
    CFDataRef ref       = NULL;
    NSData*   peerTag   = [[NSData alloc] initWithBytes:(const void *)[keyTagString UTF8String] length:[keyTagString length]];
    
    NSDictionary* attr = @{
                           (__bridge id)kSecClass               : (__bridge id)kSecClassKey,
                           (__bridge id)kSecAttrKeyType         : (__bridge id)kSecAttrKeyTypeRSA,
                           (__bridge id)kSecAttrKeyClass        : (__bridge id)keyClass,
                           (__bridge id)kSecAttrIsPermanent     : @YES,
                           (__bridge id)kSecAttrApplicationTag  : peerTag,
                           (__bridge id)kSecValueData           : keyData,
                           (__bridge id)kSecReturnPersistentRef : @YES,
                           (__bridge id)kSecReturnData          : @YES
                           };
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attr, (CFTypeRef*)&ref);
    
    if (status == noErr)
        return YES;
    else if (status == errSecDuplicateItem && overwrite == YES)
        return [self updateRSAKeyWithKeyClass:keyClass keyData:keyData keyTagString:keyTagString];
    
    return NO;
}

-(BOOL) updateRSAKeyWithKeyClass:(CFTypeRef) keyClass keyData:(NSData*)keyData keyTagString:(NSString*)keyTagString
{
    NSData* peerTag = [[NSData alloc] initWithBytes:(const void *)[keyTagString UTF8String] length:[keyTagString length]];
    
    NSDictionary* matchingAttr = @{
                                   (__bridge id)kSecClass               : (__bridge id)kSecClassKey,
                                   (__bridge id)kSecAttrKeyType         : (__bridge id)kSecAttrKeyTypeRSA,
                                   (__bridge id)kSecAttrKeyClass        : (__bridge id)keyClass,
                                   (__bridge id)kSecAttrApplicationTag  : peerTag
                                   };
    OSStatus matchingStatus = SecItemCopyMatching((__bridge CFDictionaryRef)matchingAttr, NULL);
    
    if (matchingStatus == noErr) {
        NSDictionary* updateAttr = @{
                                     (__bridge id)kSecClass             : (__bridge id)kSecClassKey,
                                     (__bridge id)kSecAttrKeyType       : (__bridge id)kSecAttrKeyTypeRSA,
                                     (__bridge id)kSecAttrKeyClass      : (__bridge id)keyClass,
                                     (__bridge id)kSecAttrApplicationTag: peerTag
                                     };
        NSDictionary* update = @{
                                 (__bridge id)kSecValueData : keyData
                                 };
        OSStatus updateStatus = SecItemUpdate((__bridge CFDictionaryRef)updateAttr, (__bridge CFDictionaryRef)update);
        return updateStatus == noErr;
    }
    return NO;
}

-(SecKeyRef)loadRSAKeyWithKeyClass:(CFTypeRef)keyClass keyTagString:(NSString*)keyTagString
{
    NSData* peerTag = [[NSData alloc] initWithBytes:(const void *)[keyTagString UTF8String] length:[keyTagString length]];
    
    NSDictionary* attr = @{
                           (__bridge id)kSecClass               : (__bridge id)kSecClassKey,
                           (__bridge id)kSecAttrKeyType         : (__bridge id)kSecAttrKeyTypeRSA,
                           (__bridge id)kSecAttrKeyClass        : (__bridge id)keyClass,
                           (__bridge id)kSecAttrApplicationTag  : peerTag,
                           (__bridge id)kSecReturnRef           : @YES
                           };
    
    SecKeyRef keyRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)attr, (CFTypeRef*)&keyRef);
    
    if (status == noErr)
        return keyRef;
    else
        return NULL;
}

-(NSData*)loadRSAKeyDataWithKeyClass:(CFTypeRef)keyClass  keyTagString:(NSString*)keyTagString
{
    NSData* peerTag = [[NSData alloc] initWithBytes:(const void *)[keyTagString UTF8String] length:[keyTagString length]];
    
    NSDictionary* attr = @{
                           (__bridge id)kSecClass               : (__bridge id)kSecClassKey,
                           (__bridge id)kSecAttrKeyType         : (__bridge id)kSecAttrKeyTypeRSA,
                           (__bridge id)kSecAttrKeyClass        : (__bridge id)keyClass,
                           (__bridge id)kSecAttrApplicationTag  : peerTag,
                           (__bridge id)kSecReturnData          : @YES
                           };
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)attr, (CFTypeRef*)&result);
    
    if (status == noErr && result)
        return (NSData*)CFBridgingRelease(result);
    else if (result)
        CFRelease(result);
    
    return nil;
}

- (NSData *)decryptedDataUsingAlgorithm:(CCAlgorithm)algorithm
                                    key:(NSData *)keyData
                   initializationVector:(NSData *)ivData
                                options:(CCOptions)options
                              keyLength:(NSUInteger)keyLength
                                   data:(NSData *)data
                                  error:(CCCryptorStatus *)error
{
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;
    
    NSAssert([keyData length] == keyLength, @"The key length is wrong");
    
    status = CCCryptorCreate( kCCDecrypt, algorithm, options,
                             [keyData bytes], [keyData length], [ivData bytes],
                             &cryptor );
    
    if ( status != kCCSuccess )
    {
        if ( error != NULL )
            *error = status;
        return nil;
    }
    
    NSData * result = [self runCryptor:cryptor result:&status data:data];
    if ( (result == nil) && (error != NULL) )
        *error = status;
    
    CCCryptorRelease( cryptor );
    
    return result;
}

- (NSData *)runCryptor:(CCCryptorRef)cryptor result:(CCCryptorStatus *)status data:(NSData *)data
{
    size_t bufsize = CCCryptorGetOutputLength( cryptor, (size_t)[data length], true );
    void * buf = malloc( bufsize );
    size_t bufused = 0;
    size_t bytesTotal = 0;
    *status = CCCryptorUpdate( cryptor, [data bytes], (size_t)[data length],
                              buf, bufsize, &bufused );
    if ( *status != kCCSuccess )
    {
        free( buf );
        return ( nil );
    }
    
    bytesTotal += bufused;
    
    // From Brent Royal-Gordon (Twitter: architechies):
    //  Need to update buf ptr past used bytes when calling CCCryptorFinal()
    *status = CCCryptorFinal( cryptor, buf + bufused, bufsize - bufused, &bufused );
    if ( *status != kCCSuccess )
    {
        free( buf );
        return nil;
    }
    
    bytesTotal += bufused;
    
    return [NSData dataWithBytesNoCopy: buf length: bytesTotal];
}

@end
