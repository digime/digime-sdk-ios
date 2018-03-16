//
//  DMECertificatePinner.m
//  DigiMeSDK
//
//  Created on 25/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMECertificatePinner.h"

@interface DMECertificatePinner()

#if !DEBUG
@property (nonatomic, strong) NSArray *localCerts;
#endif

@end

@implementation DMECertificatePinner

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self)
    {
#if !DEBUG
        NSMutableArray* certs = [NSMutableArray new];
        for (int i = 1; i<=3; i++)
        {
            NSString* path = [[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"apiCert%d",i,nil] ofType:@"der"];
            if(path)
            {
                NSData* data = [NSData dataWithContentsOfFile:path];
                if(data)
                {
                    [certs addObject:data];
                }
            }
        }
        
        _localCerts = certs.copy;
#endif
    }
    
    return self;
}

#pragma mark - Certificate Pinning

- (NSURLSessionAuthChallengeDisposition)authenticateURLChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([[[challenge protectionSpace] authenticationMethod] isEqualToString: NSURLAuthenticationMethodServerTrust])
    {
#if DEBUG
        return NSURLSessionAuthChallengePerformDefaultHandling;
#else
        do
        {
            // in the future will be an array of certs to compare with... one for now
            SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
            if (nil == serverTrust)
            {
                break; /* failed */
            }
            
            OSStatus status = SecTrustEvaluate(serverTrust, NULL);
            if (errSecSuccess != status)
            {
                break; /* failed */
            }
            
            SecCertificateRef serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
            if (nil == serverCertificate)
            {
                break; /* failed */
            }
            
            CFDataRef serverCertificateData = SecCertificateCopyData(serverCertificate);
            if (nil == serverCertificateData)
            {
                break; /* failed */
            }
            
            const UInt8* const data = CFDataGetBytePtr(serverCertificateData);
            const CFIndex size = CFDataGetLength(serverCertificateData);
            NSData* remoteCert = [NSData dataWithBytes:data length:(NSUInteger)size];
            if (remoteCert == nil || [remoteCert isEqual:[NSNull class]])
            {
                break; /* failed */
            }
            
            if(![self isRemoteCertIsEqualToAnyLocalCert:self.localCerts remoteCert:remoteCert])
            {
                break; /* failed */
            }
            
            // The only good exit point
            return NSURLSessionAuthChallengeUseCredential;
        } while(0);
        
        // Bad dog
        return NSURLSessionAuthChallengeCancelAuthenticationChallenge;
#endif
    }
    
    return NSURLSessionAuthChallengePerformDefaultHandling;
}

- (BOOL)isRemoteCertIsEqualToAnyLocalCert:(nonnull NSArray<NSData*> *)localCerts remoteCert:(nonnull NSData*)remoteCert
{
    for (NSData* localCert in localCerts)
    {
        if([remoteCert isEqualToData:localCert])
        {
            return YES;
        }
    }
    
    return NO;
}

@end
