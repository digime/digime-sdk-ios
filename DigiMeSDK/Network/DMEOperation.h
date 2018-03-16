//
//  DMEOperation.h
//  DigiMeSDK
//
//  Created on 26/01/2018.
//  Copyright © 2018 DigiMe. All rights reserved.
//

#import "DMEClientConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * An operation with a run loop.  This allows asynchronous work to be carried on a background thread.
 */
@interface DMEOperation : NSOperation

/**
 * The block to execute from the operation object. The block should take no parameters and have no return value.
 * @note Within the block, be sure to call @c finishDoingWork when the work is complete, otherwise operation will never complete
 */
@property (nonatomic, copy, nullable) void (^workBlock)(void);

/**
 Client Configuration object.
 */
@property (nonatomic, strong, readonly, nullable) DMEClientConfiguration *config;

/**
 * Notifies the operation that all work has been completed and can clean itself up.
 * Must be called from within workBlock.
 */
- (void)finishDoingWork;


/**
 Initilize Operation with Client Configuration object

 @param configuration Client Configuration
 @return DMEOperation
 */
- (instancetype)initWithConfiguration:(DMEClientConfiguration *)configuration;


/**
 This method will attempt to retry current operation if it is possible (based on Client Configuration).

 @return BOOL. This will return NO if retry cannot happen. YES if retry was scheduled.
 */
- (BOOL)retry;

NS_ASSUME_NONNULL_END

@end
