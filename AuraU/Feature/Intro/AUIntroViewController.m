//
//  AUIntroViewController.m
//  AuraU
//
//  Created by Thundersoft on 15/4/1.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUIntroViewController.h"
#import "AUIntroStep1Panel.h"
#import "AUIntroStep2Panel.h"
#import "AUIntroStep3Panel.h"
#import "AppDelegate.h"

@interface AUIntroViewController ()
@property (nonatomic, assign) BOOL onceToken;
@end

@implementation AUIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    if (_onceToken) {
        return;
    }
    _onceToken = YES;

    AUIntroStep1Panel *panel1 = [[AUIntroStep1Panel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"AUIntroStep1Panel"];
    AUIntroStep2Panel *panel2 = [[AUIntroStep2Panel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"AUIntroStep2Panel"];
    AUIntroStep3Panel *panel3 = [[AUIntroStep3Panel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) nibNamed:@"AUIntroStep3Panel"];

    NSArray *panels = @[panel1, panel2, panel3];
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    introductionView.delegate = self;
    [introductionView.RightSkipButton setHidden:YES];
    introductionView.PageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    introductionView.PageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    introductionView.BackgroundImageView.image = [UIImage imageNamed:@"Default_1334h"];
    [introductionView buildIntroductionWithPanels:panels];

    [self.view addSubview:introductionView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

#pragma mark - MYIntroduction Delegate
-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:appVersion forKey:kAppVersion];
    [userDefaults synchronize];

    [(AppDelegate *)[UIApplication sharedApplication].delegate makeController];
}
@end
