//
//  DMEAppCommunicator+Quark.h
//  DigiMeSDK
//
//  Created on 26/11/2018.
//

#import <DigiMeSDK/DigiMeSDK.h>

@interface DMEAppCommunicator (Quark)

- (void)openBrowserWithParameters:(NSDictionary *)parameters;
- (NSError *)handleQuarkCallbackWithParameters:(NSDictionary<NSString *,id> *)parameters;

@end
