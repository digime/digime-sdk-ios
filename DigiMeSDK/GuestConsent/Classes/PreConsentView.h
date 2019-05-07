//
//  PreConsentView.h
//  DigiMeSDK
//
//  Created by digi.me Ltd. on 01/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PreConsentViewDelegate <NSObject>

- (void)appstoreButtonTapped;

@end

@interface PreConsentView : UIView

@property (nonatomic, strong) UIImageView *digimeLogoImageView;
@property (nonatomic, strong) UIImageView *confettiImageView;
@property (nonatomic, strong) UIButton *appstoreButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) id<PreConsentViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
