//
//  AUHomeTipsUnopenedViewController.m
//  AuraU
//
//  Created by Thundersoft on 15/3/17.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUHomeTipsUnopenedViewController.h"

@interface AUHomeTipsUnopenedViewController ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *desciLabel;
@property (nonatomic, weak) IBOutlet UILabel *hotspotsLabel;
@property (nonatomic, weak) IBOutlet UILabel *passwordLabel;
@property (nonatomic, weak) IBOutlet UILabel *tipsLabel;
@property (nonatomic, weak) IBOutlet UIButton *passwordButton;
@end

@implementation AUHomeTipsUnopenedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_passwordButton setTitle:kStringCopyPassword forState:UIControlStateNormal];
    [_passwordButton setBackgroundImage:[UIImage genWithColor:[UIColor orangeColor]] forState:UIControlStateNormal];
    [_passwordButton setBackgroundImage:[UIImage genWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
    [_passwordButton exSetBorder:[UIColor clearColor] width:kJXSizeForBorderWidthSmall radius:kJXSizeForCornerRadiusSmall];

    _titleLabel.text = kStringPhoneWLANIsOff;
    _desciLabel.text = kStringToSettingOpenWLANThenConnectAura;
    _hotspotsLabel.text = kStringHotspotsIsMDMI;
    _passwordLabel.text = kStringPasswordIs12345678;
    _tipsLabel.text = kStringTipToReturnAPP;
}

- (IBAction)passwordButtonPressed:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"12345678";
}
@end
