//
//  TSAdvertiseController.m
//  AuraU
//
//  Created by Army on 15-2-10.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "TSAdvertiseController.h"

@interface TSAdvertiseController ()<UIScrollViewDelegate>
@property (nonatomic,strong)IBOutlet UIScrollView *scrollerView;

@end

@implementation TSAdvertiseController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:appVersion forKey:kAppVersion];
    [userDefaults synchronize];

    self.scrollerView.pagingEnabled = YES;
    self.scrollerView.showsHorizontalScrollIndicator = NO;
    float width = kJXCurrentModeSizeWidth;
    float height = kJXCurrentModeSizeHeight;
    for (int i = 0 ; i < 3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"bg_Advertise%d.jpg",i + 1]];
        if (i == 2) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(i * width, 0, width, height);
            [button setBackgroundImage:image forState:UIControlStateNormal];
            [button setBackgroundImage:image forState:UIControlStateHighlighted];
            [button setUserInteractionEnabled:NO];
            [self.scrollerView addSubview:button];

            UIButton *buttonAction = [UIButton buttonWithType:UIButtonTypeCustom];
            JXDimension *dimension = [JXDimension currentDimension];
            if (dimension.screenResolution == JXDimensionScreenResolution640x960) {
                buttonAction.frame = CGRectMake(i * width + 70, button.frame.size.height - 115, 180, 44);
            }else if (dimension.screenResolution == JXDimensionScreenResolution750x1334) {
                buttonAction.frame = CGRectMake(i * width + 85, button.frame.size.height - 143, 220, 44);
            }else if (dimension.screenResolution == JXDimensionScreenResolution1242x2208) {
                [button setUserInteractionEnabled:YES];
               [button addTarget:self action:@selector(topImageAction) forControlEvents:UIControlEventTouchUpInside];
            }else {
                buttonAction.frame = CGRectMake(i * width + 70, button.frame.size.height - 125, 180, 44);
            }
            [buttonAction setBackgroundColor:[UIColor clearColor]];
            [buttonAction addTarget:self action:@selector(topImageAction) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollerView addSubview:buttonAction];


        } else {
            UIImageView *imagePage = [[UIImageView alloc]initWithFrame:CGRectMake(i * width, 0, width, height)];
            imagePage.image = image;
            [self.scrollerView addSubview:imagePage];
        }

    }
    [self.scrollerView setContentSize:CGSizeMake(3 * width, 0)];
    [self.scrollerView setContentOffset:CGPointMake(0, 0)];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Action
- (void)topImageAction
{
    [[AppDelegate appDelegate] makeController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
