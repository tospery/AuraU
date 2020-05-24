//
//  AUHomeTipsFailureViewController.m
//  AuraU
//
//  Created by Thundersoft on 15/3/17.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUHomeTipsFailureViewController.h"

@interface AUHomeTipsFailureViewController ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *tip1Label;
@property (nonatomic, weak) IBOutlet UILabel *tip2Label;
@property (nonatomic, weak) IBOutlet UILabel *tip3Label;

@property (nonatomic, copy) void(^reconnectBlock)();
@property (nonatomic, weak) IBOutlet UIButton *reconnectButton;
@end

@implementation AUHomeTipsFailureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_reconnectButton setTitle:kStringReconnect forState:UIControlStateNormal];
    [_reconnectButton setBackgroundImage:[UIImage genWithColor:[UIColor orangeColor]] forState:UIControlStateNormal];
    [_reconnectButton setBackgroundImage:[UIImage genWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
    [_reconnectButton exSetBorder:[UIColor clearColor] width:kJXSizeForBorderWidthSmall radius:kJXSizeForCornerRadiusSmall];

    _titleLabel.text = kStringConnectAuraFailed;
    _tip1Label.text = kStringAuraWifiHasSomeProblem;
    _tip2Label.text = kStringPleaseToRebootAura;
    _tip3Label.text = kStringPleaseToReopenWLAN;
}

- (void)setReconnectBlock:(void(^)())reconnectBlock {
    _reconnectBlock = reconnectBlock;
}

- (IBAction)reconnectButtonPressed:(id)sender {
    if (_reconnectBlock) {
        _reconnectBlock();
    }
}
@end
