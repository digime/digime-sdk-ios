//
//  NSString+DMECrypto.m
//  DigiMe
//
//  Created on 25/01/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

#import "NSString+DMECrypto.h"

static const NSInteger kBASE64QUANTUM = 3;
static const NSInteger kBASE64QUANTUMREP = 4;

static unsigned char decodeBase64[256] = {
    64, 64, 64, 64, 64, 64, 64, 64,  // 0x00
    64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64,  // 0x10
    64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64,  // 0x20
    64, 64, 64, 62, 64, 64, 64, 63,
    52, 53, 54, 55, 56, 57, 58, 59,  // 0x30
    60, 61, 64, 64, 64,  0, 64, 64,
    64,  0,  1,  2,  3,  4,  5,  6,  // 0x40
    7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22,  // 0x50
    23, 24, 25, 64, 64, 64, 64, 64,
    64, 26, 27, 28, 29, 30, 31, 32,  // 0x60
    33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48,  // 0x70
    49, 50, 51, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64,  // 0x80
    64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64,  // 0x90
    64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64,  // 0xA0
    64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64,  // 0xB0
    64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64,  // 0xC0
    64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64,  // 0xD0
    64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64,  // 0xE0
    64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64,  // 0xF0
    64, 64, 64, 64, 64, 64, 64, 64,
};

@implementation NSString (DMECrypto)

- (NSMutableData *)hexToBytes
{
    NSString* cleanedString = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData* data = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    for (NSUInteger i=0; i < [cleanedString length]/2; i++) {
        byte_chars[0] = [cleanedString characterAtIndex:i*2];
        byte_chars[1] = [cleanedString characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    
    NSAssert(data != nil, @"Output data cannot be nil");
    
    return data;
}

-(BOOL)isBase64
{
    NSString * input = [[self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
    if ([input length] % 4 == 0) {
        static NSCharacterSet *invertedBase64CharacterSet = nil;
        if (invertedBase64CharacterSet == nil) {
            invertedBase64CharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="]invertedSet];
        }
        return [input rangeOfCharacterFromSet:invertedBase64CharacterSet options:NSLiteralSearch].location == NSNotFound;
    }
    return NO;
}

#pragma mark - Base 64
- (NSData *)base64Data
{
    unsigned char ch, accumulated[kBASE64QUANTUMREP], outbuf[kBASE64QUANTUM];
    const unsigned char *charString;
    NSMutableData *theData;
    const int OUTOFRANGE = 64;
    const unsigned char LASTCHARACTER = '=';
    
    if (self.length < 1)
    {
        return [NSData data];
    }
    
    for (int i = 0; i < kBASE64QUANTUMREP; i++) {
        accumulated[i] = 0;
    }
    
    charString = (const unsigned char *)[self UTF8String];
    
    theData = [NSMutableData dataWithCapacity: [self length]];
    
    short accumulateIndex = 0;
    for (NSUInteger index = 0; index < [self length]; index++) {
        
        ch = decodeBase64[charString [index]];
        
        if (ch < OUTOFRANGE)
        {
            short ctcharsinbuf = kBASE64QUANTUM;
            
            if (charString [index] == LASTCHARACTER)
            {
                if (accumulateIndex == 0)
                {
                    break;
                }
                else if (accumulateIndex <= 2)
                {
                    ctcharsinbuf = 1;
                }
                else
                {
                    ctcharsinbuf = 2;
                }
                
                accumulateIndex = kBASE64QUANTUM;
            }
            //
            // Accumulate 4 valid characters (ignore everything else)
            //
            accumulated [accumulateIndex++] = ch;
            
            //
            // Store the 6 bits from each of the 4 characters as 3 bytes
            //
            if (accumulateIndex == kBASE64QUANTUMREP)
            {
                accumulateIndex = 0;
                
                outbuf[0] = (accumulated[0] << 2) | ((accumulated[1] & 0x30) >> 4);
                outbuf[1] = ((accumulated[1] & 0x0F) << 4) | ((accumulated[2] & 0x3C) >> 2);
                outbuf[2] = ((accumulated[2] & 0x03) << 6) | (accumulated[3] & 0x3F);
                
                for (int i = 0; i < ctcharsinbuf; i++)
                {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
        }
        
    }
    
    return theData;
}

@end
