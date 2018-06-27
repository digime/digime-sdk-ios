//
//  DMEPostboxManager.h
//  DigiMeSDK
//
//  Created by Jacob King on 26/06/2018.
//  Copyright © 2018 me.digi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMEMercuryInterfacer.h"

@interface DMEPostboxManager : NSObject <DMEMercuryInterfacee>

- (void)requestPostboxWithCompletion:(PostboxCreationCompletionBox)completion

@end
