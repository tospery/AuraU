//
//  AUIntroStep2Panel.m
//  AuraU
//
//  Created by Thundersoft on 15/4/1.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUIntroStep2Panel.h"

@interface AUIntroStep2Panel ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@end

@implementation AUIntroStep2Panel

-(void)awakeFromNib {
    _titleLabel.text = kStringScanFace;
}
@end
