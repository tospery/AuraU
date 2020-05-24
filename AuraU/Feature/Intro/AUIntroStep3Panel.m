//
//  AUIntroStep3Panel.m
//  AuraU
//
//  Created by Thundersoft on 15/4/1.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUIntroStep3Panel.h"

@interface AUIntroStep3Panel ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *entryButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@end

@implementation AUIntroStep3Panel
-(void)awakeFromNib {
    _titleLabel.text = kStringTakePhotoWithPeoples;
    [_entryButton setTitle:kStringGetStarred forState:UIControlStateNormal];
    [_entryButton exSetBorder:[UIColor orangeColor] width:kJXSizeForBorderWidthMiddle radius:kJXSizeForCornerRadiusBig];

    if ([JXDimension currentDimension].screenResolution == JXDimensionScreenResolution640x960) {
        _bottomConstraint.constant = 40;
    }else {
        _bottomConstraint.constant = 80;
    }
}

- (IBAction)joinButtonPressed:(id)sender {
    [self.parentIntroductionView skipIntroductionWithAnimated:NO];
}
@end
