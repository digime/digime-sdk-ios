//
//  DMEValidator.h
//  DigiMeSDK
//
//  Created on 17/10/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMEValidator : NSObject

/**
 Validates Contract Identifier
 
 @param contractId NSString
 @return YES if valid, NO if invalid
 */
+ (BOOL)validateContractId:(NSString *)contractId;

@end

NS_ASSUME_NONNULL_END
