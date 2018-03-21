#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "DMEClientCallbacks.h"
#import "DMEClientDelegate.h"
#import "CASessionManager.h"
#import "DMEAuthorizationManager.h"
#import "DMEClient.h"
#import "DMEClientConfiguration.h"
#import "CAAccounts.h"
#import "CAFile.h"
#import "CAFileObject.h"
#import "CAFiles.h"
#import "CASession.h"
#import "NSError+API.h"
#import "NSError+Auth.h"
#import "NSError+SDK.h"
#import "DMEAPIClient.h"
#import "DMEOperation.h"
#import "DMERequestFactory.h"
#import "CADataDecryptor.h"
#import "DMECertificatePinner.h"
#import "DMECrypto.h"
#import "CAFilesDeserializer.h"
#import "CASessionDeserializer.h"
#import "DMECryptoUtilities.h"
#import "NSData+DMECrypto.h"
#import "NSString+DMECrypto.h"
#import "UIViewController+DMEExtension.h"

FOUNDATION_EXPORT double DigiMeSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char DigiMeSDKVersionString[];

