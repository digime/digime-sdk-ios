//
//  DMEAppCommunicator.h
//  DigiMeSDK
//
//  Created on 25/06/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMEAppCommunicator : NSObject

+ (DMEAppCommunicator *)shared;

- (BOOL)openURL:(NSURL *)url options:(NSDictionary *)options;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
