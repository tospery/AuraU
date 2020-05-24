//
//  AUResultViewController.m
//  AuraU
//
//  Created by Army on 15-3-17.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUResultViewController.h"
#import "AUResultsView.h"
@interface AUResultViewController ()
{
}
@property (nonatomic,strong)IBOutlet UILabel *lableContent;

@end

@implementation AUResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(okNoitification) name:kOkButtonClicked
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(cancelNoitification) name:kCancelButtonClicked
                                              object:nil];
    
    NSString *strContent = kStringCaptureSuccessWaitingOtherThenCanSeeOnAura;
    self.lableContent.text = strContent;

    UIBarButtonItem *leftItme  = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backIcon.png"] style:UIBarButtonItemStyleDone target:self action:@selector(popRoot)];
    self.navigationItem.leftBarButtonItem = leftItme;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark  - NSNotificationCenter
- (void)okNoitification
{
    [self performSelector:@selector(popRoot) withObject:self afterDelay:.5];
}

- (void)cancelNoitification
{
    [self performSelector:@selector(popRoot) withObject:self afterDelay:.5];
}


- (void)popRoot
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
