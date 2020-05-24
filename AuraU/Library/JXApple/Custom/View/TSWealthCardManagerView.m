//
//  TSWealthCardManagerView.m
//  CMBCEcosphere
//
//  Created by Thundersoft on 10/6/14.
//  Copyright (c) 2014 Zhou , Hongjun. All rights reserved.
//

#import "TSWealthCardManagerView.h"
//#import "TSManager.h"

@interface TSWealthCardManagerView ()
//@property (strong, nonatomic) UIImageView *imageImageView;
//@property (strong, nonatomic) UILabel *officeNameLabel;
//@property (strong, nonatomic) UILabel *nameLabel;
//@property (strong, nonatomic) UILabel *workingLifeLabel;
//@property (strong, nonatomic) UIButton *phoneButton;
//
//@property (assign, nonatomic) /*CLLocationCoordinate2D*/ coordinate;
@end

@implementation TSWealthCardManagerView
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//        self.frame = CGRectMake(0, 0, 320, 100);
//
//        // 头像
//        self.imageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 5, 70, 80)];
//        [self addSubview:self.imageImageView];
//        _imageImageView.contentMode = UIViewContentModeScaleAspectFit;
//
//        // 营业厅
//        _officeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(108, 10, 202, 15)];
//        _officeNameLabel.font = [UIFont systemFontOfSize:12];
//        [self addSubview:_officeNameLabel];
//
//        // 到这里去
//        UnderLineLabel *gotoHereLabel = [[UnderLineLabel alloc] initWithFrame:CGRectMake(108, 28, 48, 15)];
//        [gotoHereLabel setFont:[UIFont systemFontOfSize:12]];
//        [gotoHereLabel setBackgroundColor:[UIColor clearColor]];
//        [gotoHereLabel setTextColor:RGBCOLOR(239, 139, 55)];
//        gotoHereLabel.highlightedColor = [UIColor redColor];
//        gotoHereLabel.shouldUnderline = YES;
//        [gotoHereLabel setText:@"到这里去" andCenter:CGPointMake(108 + 48 / 2, 28 + 15 / 2)];
//        [gotoHereLabel addTarget:self action:@selector(gotoHere:)];
//        [self addSubview:gotoHereLabel];
//
//        // 姓名
//        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(108, 48, 110, 15)];
//        self.nameLabel.font = [UIFont systemFontOfSize:12];
//        [self addSubview:self.nameLabel];
//
//        // 工作年限
//        self.workingLifeLabel = [[UILabel alloc] initWithFrame:CGRectMake(108, 67, 110, 15)];
//        self.workingLifeLabel.font = [UIFont systemFontOfSize:12];
//        [self addSubview:self.workingLifeLabel];
//
//        // 电话
//        self.phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.phoneButton.frame = CGRectMake(221, 40, 89, 20);
//        [self.phoneButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
//        [self.phoneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//        [self.phoneButton setBackgroundImage:[UIImage imageNamed:@"wealth_yuyue_bg_number"] forState:UIControlStateNormal];
//        [_phoneButton addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:self.phoneButton];
//    }
//    return self;
//}
//
//- (void)setManager:(TSManager *)manager
//{
//    [_imageImageView setImageWithURL:[NSURL URLWithString:manager.image] placeholderImage:[UIImage imageNamed:@"waiting_icon"]];
//    _officeNameLabel.text = manager.office.name;
//    _nameLabel.text = [NSString stringWithFormat:@"姓名：%@", manager.name];
//    _workingLifeLabel.text = [NSString stringWithFormat:@"工作年限：%ld", (long)manager.workinglife];
//
//    NSMutableAttributedString *phone = [[NSMutableAttributedString alloc] initWithString:manager.phone];
//    [phone addAttribute:NSForegroundColorAttributeName
//                  value:[UIColor indigoColor]
//                  range:NSMakeRange(0, phone.length)];
//    [phone addAttribute:NSUnderlineStyleAttributeName
//                          value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
//                          range:NSMakeRange(0, phone.length)];
//    [_phoneButton setAttributedTitle:phone forState:UIControlStateNormal];
//
//    _coordinate.latitude = [manager.office.latitude floatValue];
//    _coordinate.longitude = [manager.office.longitude floatValue];
//}
//
//
//- (void)gotoHere:(id)sender
//{
//    if ([self.delegate respondsToSelector:@selector(managerView:didSelectGotoHere:)]) {
//        [self.delegate managerView:self didSelectGotoHere:_coordinate];
//    }
//}
//
//- (void)call:(id)sender
//{
//    UIButton *button = (UIButton *)sender;
//    NSString *mobileNumber = button.titleLabel.text;
//    if ([self.delegate respondsToSelector:@selector(managerView:didSelectCallManager:)]) {
//        [self.delegate managerView:self didSelectCallManager:mobileNumber];
//    }
//}
@end
