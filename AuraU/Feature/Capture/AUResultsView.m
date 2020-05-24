//
//  AUResultsView.m
//  AuraU
//
//  Created by Army on 15-3-17.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUResultsView.h"

@interface AUResultsView ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *okButton;
@end

@implementation AUResultsView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_titleLabel setText:kStringTakePhotoWithPeoples];
    [_cancelButton setTitle:kStringCancel forState:UIControlStateNormal];
    [_okButton setTitle:kStringOK forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)makeCancelAction:(id)sender
{
       if ([self.delegate respondsToSelector:@selector(AUResultsViewIsCancelButtonClicked:)]) {
        [self.delegate AUResultsViewIsCancelButtonClicked:self];
    }
}

- (IBAction)makeOkAciont:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(AUResultsViewIsOkButtonClicked:)]) {
        [self.delegate AUResultsViewIsOkButtonClicked:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
