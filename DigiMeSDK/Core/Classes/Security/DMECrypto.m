//
//  DMECrypto.m
//  DigiMeSDK
//
//  Created on 25/01/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import "DMECrypto.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import "NSString+DMECrypto.h"
#import "NSData+DMECrypto.h"

static NSString* kPrivateKeyIdentifier = @"me.digi.digime.privatekey";
static NSString* kPublicKeyIdentifier = @"me.digi.digime.publickey";
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

#pragma mark - AES Decrypt file content

- (NSData *)getDataFromEncryptedBytes:(NSData *)encryptedData privateKeyData:(NSData *)privateKeyData
{
    //convert data back to privateKey.
    [self saveRSAKeyWithKeyClass:kSecAttrKeyClassPrivate keyData:privateKeyData keyTagString:kPrivateKeyIdentifier overwrite:YES];
    SecKeyRef privateKey = [self loadRSAKeyWithKeyClass:kSecAttrKeyClassPrivate keyTagString:kPrivateKeyIdentifier];
    
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
    if (status != noErr)
    {
        free(plainBuffer);
        return nil;
    }
    
    NSData* decryptedDsk = [NSData dataWithBytes:plainBuffer length:plainBufferSize];
    free(plainBuffer);
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

#pragma mark - AES Encrypt data

- (nullable NSData *)dataEncryptedUsingAlgorithm:(CCAlgorithm)algorithm
                                             key:(NSData *)keyData
                            initializationVector:(NSData *)ivData
                                         options:(CCOptions)options
                                       keyLength:(NSInteger)keyLength
                                            data:(NSData *)data
                                           error:(NSError * __autoreleasing * _Nullable)error
{
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;
    
    if (keyData.length != keyLength)
    {
        NSAssert(error == nil, @"JFS key data cannot be nil");
        
        return nil;
    }
    
    status = CCCryptorCreate( kCCEncrypt, algorithm, options,
                             [keyData bytes], [keyData length], [ivData bytes],
                             &cryptor );
    
    if ( status != kCCSuccess )
    {
        [self logCCCryptorStatus:status];
        
        return nil;
    }
    
    NSData * result = [self runCryptor:cryptor result:&status data:data];
    if ( status != kCCSuccess )
    {
        [self logCCCryptorStatus:status];
        
        return nil;
    }
    
    CCCryptorRelease( cryptor );
    
    return ( result );
}

- (nullable NSData *)encryptAes256UsingKey:(NSData *)keyData initializationVector:(NSData *)ivData data:(NSData *)data error:(NSError * __autoreleasing * _Nullable)error
{
    NSData *result = [self dataEncryptedUsingAlgorithm:kCCAlgorithmAES128
                                                   key:keyData
                                  initializationVector:ivData
                                               options:kCCOptionPKCS7Padding
                                             keyLength:kCCKeySizeAES256
                                                  data:data
                                                 error:error];
    
    return result;
}

#pragma mark - RSA Key operations

-(BOOL)saveRSAKeyWithKeyClass:(CFTypeRef) keyClass keyData:(NSData*)keyData keyTagString:(NSString*)keyTagString overwrite:(BOOL) overwrite
{
    CFDataRef ref       = NULL;
    NSData*   peerTag   = [[NSData alloc] initWithBytes:(const void *)[keyTagString UTF8String] length:[keyTagString length]];
    
    NSAssert(keyData, @"DigiMeSDK: Failed to extract key data. Did you set your P12 password?");
    
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

- (NSData *)stripPublicKeyHeader:(NSData *)d_key
{
    // Skip ASN.1 public key header
    if (d_key == nil)
    {
        return(nil);
    }
    
    unsigned long len = [d_key length];
    if (!len)
    {
        return(nil);
    }
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int idx = 0;
    
    if (c_key[idx++] != 0x30)
    {
        return(nil);
    }
    
    if (c_key[idx] > 0x80)
    {
        idx += c_key[idx] - 0x80 + 1;
    }
    else
    {
        idx++;
    }
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] = { 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15))
    {
        return(nil);
    }
    
    idx += 15;
    
    if (c_key[idx++] != 0x03)
    {
        return(nil);
    }
    
    if (c_key[idx] > 0x80)
    {
        idx += c_key[idx] - 0x80 + 1;
    }
    else
    {
        idx++;
    }
    
    if (c_key[idx++] != '\0')
    {
        return(nil);
    }
    
    // Now make a new NSData from this buffer
    return ([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

- (SecKeyRef)addPublicKey:(NSString *)key
{
    NSRange spos = [key rangeOfString:@"-----BEGIN RSA PUBLIC KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END RSA PUBLIC KEY-----"];
    if (spos.location != NSNotFound && epos.location != NSNotFound)
    {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:key options:NSDataBase64DecodingIgnoreUnknownCharacters];
    // do not remove this commented out code. for sure it could be an issue at some point and we can return it back
    //    data = [self stripPublicKeyHeader:data];
    //    if(!data){
    //        return nil;
    //    }
    
    //a tag to read/write keychain storage
    NSData *d_tag = [NSData dataWithBytes:[kPublicKeyIdentifier UTF8String] length:[kPublicKeyIdentifier length]];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);
    
    // Add persistent version of the key to system keychain
    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id) kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id) kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil)
    {
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem))
    {
        return nil;
    }
    
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    
    if (status != noErr)
    {
        return nil;
    }
    return keyRef;
}

- (SecKeyRef)addPrivateKey:(NSString *)key
{
    NSRange spos;
    NSRange epos;
    spos = [key rangeOfString:@"-----BEGIN RSA PRIVATE KEY-----"];
    
    if (spos.length > 0)
    {
        epos = [key rangeOfString:@"-----END RSA PRIVATE KEY-----"];
    }
    else
    {
        spos = [key rangeOfString:@"-----BEGIN PRIVATE KEY-----"];
        epos = [key rangeOfString:@"-----END PRIVATE KEY-----"];
    }
    if (spos.location != NSNotFound && epos.location != NSNotFound)
    {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:key options:NSDataBase64DecodingIgnoreUnknownCharacters];
    // do not remove this commented out code. for sure it could be an issue at some point and we can return it back
    //    data = [self stripPrivateKeyHeader:data];
    //    if(!data){
    //        return nil;
    //    }
    
    NSData *d_tag = [NSData dataWithBytes:[kPrivateKeyIdentifier UTF8String] length:[kPrivateKeyIdentifier length]];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *privateKey = [[NSMutableDictionary alloc] init];
    [privateKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [privateKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)privateKey);
    
    // Add persistent version of the key to system keychain
    [privateKey setObject:data forKey:(__bridge id)kSecValueData];
    [privateKey setObject:(__bridge id) kSecAttrKeyClassPrivate forKey:(__bridge id) kSecAttrKeyClass];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id) kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)privateKey, &persistKey);
    if (persistKey != nil)
    {
        CFRelease(persistKey);
    }
    
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }
    
    [privateKey removeObjectForKey:(__bridge id)kSecValueData];
    [privateKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [privateKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)privateKey, (CFTypeRef *)&keyRef);
    if(status != noErr)
    {
        return nil;
    }
    
    return keyRef;
}

#pragma mark - RSA encryption/decryption operations

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

- (NSData*)encryptLargeData:(NSData *)dataToEncrypt publicKey:(SecKeyRef)publicKey
{
    NSCParameterAssert(dataToEncrypt.length > 0);
    NSCParameterAssert(publicKey != NULL);
    
    const uint8_t*  bytesToEncrypt      = dataToEncrypt.bytes;
    size_t          cipherBufferSize    = SecKeyGetBlockSize(publicKey);
    const size_t    blockSize           = cipherBufferSize - 42;
    uint8_t*        cipherBuffer        = (uint8_t *) malloc(sizeof(uint8_t) * cipherBufferSize);
    NSMutableData*  result              = [[NSMutableData alloc] init];
    
    NSCAssert(cipherBufferSize > 42, @"block size is too small: %zd", cipherBufferSize);
    
    @try {
        
        for (size_t block = 0; block * blockSize < dataToEncrypt.length; block++)
        {
            OSStatus        status              = noErr;
            size_t          blockOffset         = block * blockSize;
            const uint8_t*  chunkToEncrypt      = (bytesToEncrypt + block * blockSize);
            const size_t    remainingSize       = dataToEncrypt.length - blockOffset;
            const size_t    subsize             = remainingSize < blockSize ? remainingSize : blockSize;
            size_t          actualOutputSize    = cipherBufferSize;
            
            status = SecKeyEncrypt(publicKey,
                                   kSecPaddingOAEP,
                                   chunkToEncrypt,
                                   subsize,
                                   cipherBuffer,
                                   &actualOutputSize);
            
            NSAssert(status == noErr, @"RSA encryption failed");
            
            if (status != noErr)
            {
                return nil;
            }
            
            [result appendBytes:cipherBuffer length:actualOutputSize];
        }
        
        return [result copy];
    }
    @finally
    {
        free(cipherBuffer);
    }
}

- (NSData*)decryptLargeData:(NSData*)dataToDecrypt privateKey:(SecKeyRef)privateKey
{
    NSCParameterAssert(dataToDecrypt != NULL);
    NSCParameterAssert(privateKey != NULL);
    
    uint8_t*        bytesToDecrypt      = (uint8_t*)dataToDecrypt.bytes;
    size_t          cipherBufferSize    = SecKeyGetBlockSize(privateKey);
    const size_t    blockSize           = cipherBufferSize;
    uint8_t*        cipherBuffer        = (uint8_t *) malloc(sizeof(uint8_t) * cipherBufferSize);
    NSMutableData*  result              = [[NSMutableData alloc] init];
    
    NSCAssert(cipherBufferSize > 42, @"block size is too small: %zd", cipherBufferSize);
    
    @try {
        
        for (size_t block = 0; block * blockSize < dataToDecrypt.length; block++)
        {
            OSStatus        status              = noErr;
            size_t          blockOffset         = block * blockSize;
            const uint8_t*  chunkToDecrypt      = (bytesToDecrypt + block * blockSize);
            const size_t    remainingSize       = dataToDecrypt.length - blockOffset;
            const size_t    subsize             = remainingSize < blockSize ? remainingSize : blockSize;
            size_t          actualOutputSize    = cipherBufferSize;
            
            status = SecKeyDecrypt(privateKey,
                                   kSecPaddingOAEP,
                                   chunkToDecrypt,
                                   subsize,
                                   cipherBuffer,
                                   &actualOutputSize);
            
            NSAssert(status == noErr, @"RSA decryption failed");
            
            if (status != noErr)
            {
                return nil;
            }
            
            [result appendBytes:cipherBuffer length:actualOutputSize];
        }
        
        return [result copy];
    }
    @finally
    {
        free(cipherBuffer);
    }
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

- (NSData *)decryptData:(NSData *)data withKeyRef:(SecKeyRef) keyRef
{
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    UInt8 *outbuf = malloc(block_size);
    size_t src_block_size = block_size;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for (int idx = 0; idx < srclen; idx += src_block_size)
    {
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyDecrypt(keyRef,
                               kSecPaddingOAEP,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen
                               );
        if (status != 0)
        {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
            ret = nil;
            break;
        }
        else
        {
            //the actual decrypted data is in the middle, locate it!
            int idxFirstZero = -1;
            int idxNextZero = (int)outlen;
            for (int i = 0; i < outlen; i++)
            {
                if (outbuf[i] == 0)
                {
                    if (idxFirstZero < 0)
                    {
                        idxFirstZero = i;
                    }
                    else
                    {
                        idxNextZero = i;
                        break;
                    }
                }
            }
            
            [ret appendBytes:&outbuf[idxFirstZero+1] length:idxNextZero-idxFirstZero-1];
        }
    }
    
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

#pragma mark - Random

- (NSData *)getRandomUnsignedCharacters:(int)length
{
    NSMutableData *data = [NSMutableData dataWithLength:length];
    
    __attribute__((unused)) int result = SecRandomCopyBytes(kSecRandomDefault,
                                                            (size_t)length,
                                                            data.mutableBytes);
    return data;
}

#pragma mark - Postbox

- (NSString *)preparePostboxMetadataWithKey:(NSData *)symmetricalKey initializationVector:(NSData *)iv metadata:(NSData *)metadata
{
    NSError *error;
    NSData *encryptedData = [self encryptAes256UsingKey:symmetricalKey initializationVector:iv data:metadata error:&error];
    NSAssert(error == nil, @"Postbox metadata. An encryption error occured");
    return [encryptedData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (NSString *)preparePostboxSymmetricalKeyWithData:(NSData *)dataToEncrypt rsaPublicKeyForEncryption:(NSString *)publicKey
{
    SecKeyRef publicKeyRef = [self addPublicKey:publicKey];
    NSData* encryptedLongData = [self encryptLargeData:dataToEncrypt publicKey:publicKeyRef];
    return [encryptedLongData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (NSData *)preparePostboxDataWithKey:(NSData *)symmetricalKey initializationVector:(NSData *)iv dataToPush:(NSData *)data
{
    NSError *error;
    NSData *encryptedData = [self encryptAes256UsingKey:symmetricalKey initializationVector:iv data:data error:&error];
    NSAssert(error == nil, @"Postbox data. An encryption error occured");
    return encryptedData;
}


@end
