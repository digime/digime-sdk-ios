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

#import "DigiMeSDK.h"
#import "DMEClientAuthorizationDelegate.h"
#import "DMEClientCallbacks.h"
#import "DMEClientDownloadDelegate.h"
#import "DMEClientPostboxDelegate.h"
#import "CASessionManager.h"
#import "DMEAppCommunicator.h"
#import "DMEClient.h"
#import "DMEClientConfiguration.h"
#import "DMECryptoUtilities.h"
#import "CAAccounts.h"
#import "CAFile.h"
#import "CAFileObject.h"
#import "CAFiles.h"
#import "CASession.h"
#import "NSError+API.h"
#import "NSError+Auth.h"
#import "NSError+SDK.h"

FOUNDATION_EXPORT double DigiMeSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char DigiMeSDKVersionString[];

