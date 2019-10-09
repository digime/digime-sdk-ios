//
//  DMEScope.h
//  DigiMeSDK
//
//  Created on 27/11/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEDataRequest.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Scope object that can be used to limit the time period
 for which data can be requested from the user.
 */
@interface DMEScope : NSObject <DMEDataRequest>

@end

NS_ASSUME_NONNULL_END
