//
//  PreConsentView.m
//  DigiMeSDK
//
//  Created by digi.me Ltd. on 01/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

#import "PreConsentView.h"

static NSUInteger const kInset = 30;
static NSUInteger const kDigimeImageWidth = 111;
static NSUInteger const kDigimeImageHeight = 119;
static NSUInteger const kConfettiImageWidth = 120;
static NSUInteger const kConfettiImageHeight = 85;
static NSUInteger const kAppstoreButtonWidth = 148;
static NSUInteger const kAppstoreButtonHeight = 50;

@implementation PreConsentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.layer.cornerRadius = 15;
    self.layer.masksToBounds = YES;
    
    self.backgroundColor = [UIColor whiteColor];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.digimeLogoImageView = [UIImageView new];
    self.digimeLogoImageView.frame = CGRectMake((self.frame.size.width / 2) - (kDigimeImageWidth / 2), kInset, kDigimeImageWidth, kDigimeImageHeight);
    self.digimeLogoImageView.image = [UIImage imageNamed:@"digimeLogo" inBundle:bundle compatibleWithTraitCollection:nil];
    self.digimeLogoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.digimeLogoImageView.backgroundColor = [UIColor clearColor];
    
    self.confettiImageView = [UIImageView new];
    self.confettiImageView.frame = CGRectMake(self.frame.size.width - kConfettiImageWidth, 0, kConfettiImageWidth, kConfettiImageHeight);
    self.confettiImageView.image = [UIImage imageNamed:@"confetti" inBundle:bundle compatibleWithTraitCollection:nil];
    self.confettiImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.confettiImageView.backgroundColor = [UIColor clearColor];
    
    self.appstoreButton = [UIButton new];
    self.appstoreButton.frame = CGRectMake((self.frame.size.width / 2) - (kAppstoreButtonWidth / 2), self.frame.size.height - kAppstoreButtonHeight - kInset, kAppstoreButtonWidth, kAppstoreButtonHeight);
    [self.appstoreButton setImage:[UIImage imageNamed:@"appstore" inBundle:bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.appstoreButton addTarget:self action:@selector(appstoreButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.frame = CGRectMake(kInset, self.digimeLogoImageView.frame.origin.y + kDigimeImageHeight, self.frame.size.width - (kInset * 2), self.appstoreButton.frame.origin.y - (self.digimeLogoImageView.frame.origin.y + kDigimeImageHeight));
    self.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightLight];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSString *title = NSLocalizedString(@"Create your own digi.me to make sharing data faster, more secure and always under your control", nil);
    NSString *boldTitle = NSLocalizedString(@"Save time! Stay in control!", nil);
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r\r%@", title, boldTitle]];
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:NSMakeRange(string.string.length - boldTitle.length,  boldTitle.length)];
    self.titleLabel.attributedText = string;
    
    [self addSubview:self.confettiImageView];
    [self addSubview:self.digimeLogoImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.appstoreButton];
}

- (void)appstoreButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(appstoreButtonClicked)])
    {
        [self.delegate appstoreButtonClicked];
    }
}

@end
