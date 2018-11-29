//
//  DMEDataUnpacker.h
//  DigiMeSDK
//
//  Created by Jacob King on 28/11/2018.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMEDataUnpacker : NSObject

+ (nullable NSData *)unpackData:(NSData *)data fromRootData:(NSData *)rootData;

@end

NS_ASSUME_NONNULL_END
