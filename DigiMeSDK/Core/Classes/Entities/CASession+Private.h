//
//  CASession+Private.h
//  DigiMeSDK
//
//  Created on 21/01/2019.
//  Copyright © 2019 digi.me Limited. All rights reserved.
//

#import "CASession.h"

NS_ASSUME_NONNULL_BEGIN

@interface CASession ()

@property (strong, nonatomic, readwrite) NSDictionary<NSString *, id> *metadata;

@end

NS_ASSUME_NONNULL_END
