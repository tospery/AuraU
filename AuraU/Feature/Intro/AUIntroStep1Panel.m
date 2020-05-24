//
//  AUIntroStep1Panel.m
//  AuraU
//
//  Created by Thundersoft on 15/4/1.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUIntroStep1Panel.h"

@interface AUIntroStep1Panel ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *tips1Label;
@property (nonatomic, weak) IBOutlet UILabel *tips2Label;
@end

@implementation AUIntroStep1Panel
- (void)awakeFromNib {
    _titleLabel.text = kStringGestureAction;
    _tips1Label.text = kStringFlatPhoneOnAuraToShowMainMenu;
    _tips2Label.text = kStringShakePhoneToSharePhotosToAura;
}

@end
