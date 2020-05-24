//
//  AUTipsViewController.m
//  AuraU
//
//  Created by Thundersoft on 15/4/13.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUTipsViewController.h"

@interface AUTipsViewController ()
@property (nonatomic, copy) void(^reconnectBlock)();

@property (nonatomic, weak) IBOutlet UIButton *reconnectButton;
@property (nonatomic, weak) IBOutlet UILabel *unopenedTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *unconnectedTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *failureTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *unopenedDescriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *unconnectedDescriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *failureTip1Label;
@property (nonatomic, weak) IBOutlet UILabel *failureTip2Label;
@property (nonatomic, weak) IBOutlet UILabel *failureTip3Label;
@property (nonatomic, weak) IBOutlet UIView *unopenedView;
@property (nonatomic, weak) IBOutlet UIView *unconnectedView;
@property (nonatomic, weak) IBOutlet UIView *failureView;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *hotspotsLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *passwordLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *tipsLabels;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *passwordButtons;

@end

@implementation AUTipsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _unopenedTitleLabel.text = kStringPhoneWLANIsOff;
    _unconnectedTitleLabel.text = kStringUnconnectedAuraHotspots;
    _failureTitleLabel.text = kStringConnectAuraFailed;

    _unopenedDescriptionLabel.text = kStringToSettingOpenWLANThenConnectAura;
    _unconnectedDescriptionLabel.text = kStringToSettingOpenWLANThenConnectAura;
    _failureTip1Label.text = kStringAuraWifiHasSomeProblem;
    _failureTip2Label.text = kStringPleaseToRebootAura;
    _failureTip3Label.text = kStringPleaseToReopenWLAN;

    for (UILabel *hotspotsLabel in _hotspotsLabels) {
        hotspotsLabel.text = kStringHotspotsIsMDMI;
    }
    for (UILabel *passwordLabel in _passwordLabels) {
        passwordLabel.text = kStringPasswordIs12345678;
    }
    for (UILabel *tipsLabel in _tipsLabels) {
        tipsLabel.text = kStringTipToReturnAPP;
    }
    for (UIButton *passwordButton in _passwordButtons) {
        [passwordButton setTitle:kStringCopyPassword forState:UIControlStateNormal];
        [passwordButton setBackgroundImage:[UIImage genWithColor:[UIColor orangeColor]] forState:UIControlStateNormal];
        [passwordButton setBackgroundImage:[UIImage genWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
        [passwordButton exSetBorder:[UIColor clearColor] width:kJXSizeForBorderWidthSmall radius:kJXSizeForCornerRadiusSmall];
    }

    [_reconnectButton setTitle:kStringReconnect forState:UIControlStateNormal];
    [_reconnectButton setBackgroundImage:[UIImage genWithColor:[UIColor orangeColor]] forState:UIControlStateNormal];
    [_reconnectButton setBackgroundImage:[UIImage genWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
    [_reconnectButton exSetBorder:[UIColor clearColor] width:kJXSizeForBorderWidthSmall radius:kJXSizeForCornerRadiusSmall];
}

- (void)setReconnectBlock:(void(^)())reconnectBlock {
    _reconnectBlock = reconnectBlock;
}

- (void)setType:(AUTipsViewControllerType)type {
    _type = type;
    if (AUTipsViewControllerTypeUnopened == _type) {
        [self.view bringSubviewToFront:_unopenedView];
    }else if (AUTipsViewControllerTypeUnconnected == _type) {
        [self.view bringSubviewToFront:_unconnectedView];
    }else if (AUTipsViewControllerTypeFailure == _type) {
        [self.view bringSubviewToFront:_failureView];
    }
}

- (IBAction)passwordButtonPressed:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"12345678";
}

- (IBAction)reconnectButtonPressed:(id)sender {
    if (_reconnectBlock) {
        _reconnectBlock();
    }
}
@end
