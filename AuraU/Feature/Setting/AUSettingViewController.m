//
//  AUSettingViewController.m
//  AuraU
//
//  Created by Thundersoft on 15/2/10.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUSettingViewController.h"
#import "AUSettingShareViewController.h"

#define kAUSettingViewControllerCellTitle           (@"kAUSettingViewControllerCellTitle")
#define kAUSettingViewControllerCellImage           (@"kAUSettingViewControllerCellImage")

extern BOOL gMediaArrangeFinished;
@interface AUSettingViewController ()
@property (nonatomic, strong) NSArray *settingDict;
@property (nonatomic, strong) UISwitch *sw;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation AUSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureVar];
    [self configureView];
    [self configureWeb];
}

- (void)configureVar {
    _settingDict = @[@{kAUSettingViewControllerCellTitle: kStringSetSharedDirectory,
                       kAUSettingViewControllerCellImage: [UIImage imageNamed:@"ic_privacy"]},
                     @{kAUSettingViewControllerCellTitle: kStringSupportFlatGesture,
                       kAUSettingViewControllerCellImage: [UIImage imageNamed:@"ic_gesture"]}];
}


- (void)configureView {
    self.title = kStringSetting;
    UIView *footerView = [[[NSBundle mainBundle] loadNibNamed:@"AUSettingFooterView" owner:nil options:nil] lastObject];
    UILabel *label = (UILabel *)[footerView viewWithTag:101];
    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    label.text = [NSString stringWithFormat:@"AuraU %@", appVersion];
    [_tableView setTableFooterView:footerView];

    _sw = [[UISwitch alloc] init];
    [_sw setSelected:YES];
    [_sw addTarget:self action:@selector(swSwitched:) forControlEvents:UIControlEventValueChanged];
}

- (void)configureWeb {
}

- (void)swSwitched:(id)sender {

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[_sw setOn:[[NSUserDefaults standardUserDefaults] boolForKey:kSlzFlatEnable]];
    BOOL swOn = [[[NSUserDefaults standardUserDefaults] objectForKey:kSlzFlatEnable] isEqualToString:@"On"] ? YES : NO;
    [_sw setOn:swOn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // [[NSUserDefaults standardUserDefaults] setBool:_sw.on forKey:kSlzFlatEnable];
    NSString *on = _sw.on ? @"On" : @"Off";
    [[NSUserDefaults standardUserDefaults] setObject:on forKey:kSlzFlatEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (!JXiOSVersionGreaterThanOrEqual(7.0)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyResetGuideViewForiOS6 object:nil];
    }
}

#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _settingDict.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kJXSizeForStandardCellHeight + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJXIdentifierForUITableViewCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kJXIdentifierForUITableViewCell];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [(NSDictionary *)_settingDict[indexPath.row] objectForKey:kAUSettingViewControllerCellTitle];
    cell.imageView.image = [(NSDictionary *)_settingDict[indexPath.row] objectForKey:kAUSettingViewControllerCellImage];

    if (0 == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else {
        cell.detailTextLabel.text = kStringUnrecognizeFlatGestureAfterClosed;
        cell.detailTextLabel.numberOfLines = 0;
        cell.accessoryView = _sw;
    }
    return cell;
}

#pragma mark UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.row) {
        if (!gMediaArrangeFinished) {
            AUAlertHUDTips(kStringMediaArraging);
            return;
        }

        AUSettingShareViewController *shareVC = [[AUSettingShareViewController alloc] init];
        shareVC.firstLoding = NO;
        UIBarButtonItem *leftItme  = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backIcon.png"] style:UIBarButtonItemStyleDone target:shareVC action:@selector(makeBack)];
        shareVC.navigationItem.leftBarButtonItem = leftItme;
        [self.navigationController pushViewController:shareVC animated:YES];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}
@end
