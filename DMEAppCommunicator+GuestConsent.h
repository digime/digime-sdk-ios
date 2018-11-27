//
//  DMEAppCommunicator+GuestConsent.h
//  DigiMeSDK
//
//  Created on 26/11/2018.
//

#import <DigiMeSDK/DigiMeSDK.h>

@interface DMEAppCommunicator (GuestConsent)

- (void)openBrowserWithParameters:(NSDictionary *)parameters;
- (NSError *)handleGuestConsentCallbackWithParameters:(NSDictionary<NSString *,id> *)parameters;

@end
