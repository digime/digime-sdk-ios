//
//  LogViewController.h
//  DigiMeSDKExample
//
//  Created on 31/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogViewController : UIViewController

- (void)logMessage:(NSString *)text;

- (void)reset;

- (void)decreaseFontSize;

- (void)increaseFontSize;


@end
