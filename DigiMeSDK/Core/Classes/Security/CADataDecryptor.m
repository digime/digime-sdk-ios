//
//  CADataDecryptor.m
//  DigiMeSDK
//
//  Created on 05/02/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "CADataDecryptor.h"
#import "NSString+DMECrypto.h"
#import "DMECrypto.h"
#import "NSError+SDK.h"
#import "NSError+Auth.h"

@implementation CADataDecryptor

+ (NSData *)decrypt:(NSData *)jsonData error:(NSError * _Nullable __autoreleasing *)error
{
    DMECrypto *crypto = [DMECrypto new];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:error];
    
    NSString *base64Encoded = json[@"fileContent"];
    
    if ([base64Encoded isKindOfClass:[NSString class]] && base64Encoded.length && [base64Encoded isBase64])
    {
        NSData *encryptedData = [base64Encoded base64Data];
        NSData *privateKeyData = [crypto privateKeyHex];
        
        if (!privateKeyData)
        {
            if (error != nil)
            {
                *error = [NSError sdkError:SDKErrorNoPrivateKeyHex];
            }
            
            return nil;
        }
        
        NSData *decryptedData = [crypto getDataFromEncryptedBytes:encryptedData privateKeyData:privateKeyData];
        
        if (!decryptedData)
        {
            if (error != nil)
            {
                *error = [NSError sdkError:SDKErrorDecryptionFailed];
            }
            
            return nil;
        }
        
        return decryptedData;
    }
    else
    {
        id fileContent = json[@"fileContent"];
        
        if (!fileContent || (![fileContent isKindOfClass:[NSDictionary class]] && ![fileContent isKindOfClass:[NSArray class]]))
        {
            *error = [NSError sdkError:SDKErrorDecryptionFailed];
            return nil;
        }
        
        NSError *serializationError;
        NSData *unencryptedData = [NSJSONSerialization dataWithJSONObject:fileContent options:kNilOptions error:&serializationError];
        
        if (!unencryptedData)
        {
            *error = [NSError sdkError:SDKErrorDecryptionFailed];
            return nil;
        }
        
        return unencryptedData;
    }
    
    return nil;
}

@end
