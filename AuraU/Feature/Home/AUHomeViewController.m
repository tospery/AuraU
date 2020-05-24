//
//  AUHomeViewController.m
//  AuraU
//
//  Created by Thundersoft on 15/2/15.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUHomeViewController.h"
#import "AUSettingViewController.h"
#import "GDataXMLNode.h"
#import "AUCaptureVIewController.h"
#import "AUSettingShareViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "AUScanline.h"
#import "AUGphotoViewController.h"
#import "AUHomeTipsUnopenedViewController.h"
#import "AUHomeTipsUnconnectedViewController.h"
#import "AUHomeTipsFailureViewController.h"
#import "AUResultViewController.h"
#import "AUTipsViewController.h"
#import "AUResultsView.h"

extern BOOL isFirstStartAfterInstall;
extern BOOL gIsForFlat;

@interface AUHomeViewController ()<AUResultsViewelegate>
{
    NSString *_strTaskID;
    dispatch_source_t _timer;
    BOOL _isRequest;
    NSDictionary *_dicCaptureInfo;

    AUResultsView *_resultsView;
    NSDictionary *_dicInfo;

}
@property (nonatomic, assign) BOOL isInHome;
@property (nonatomic, assign) BOOL checkStatus;
@property (nonatomic, assign) BOOL onceToken;
@property (nonatomic, assign) BOOL onceGuide;
@property (nonatomic, assign) AUNetClientType clientType;
@property (nonatomic, assign) AUHomeTipsType tipsType;
@property (nonatomic, assign) BOOL flatEnabled;
//@property (nonatomic, assign) BOOL isRegistered;
@property (nonatomic, assign) BOOL isInBackground;

//@property (nonatomic, strong) AUHomeTipsUnopenedViewController *tipsForUnopenedVC;
//@property (nonatomic, strong) AUHomeTipsUnconnectedViewController *tipsForUnconnectedVC;
//@property (nonatomic, strong) AUHomeTipsFailureViewController *tipsForFailureVC;
@property (nonatomic, strong) AUTipsViewController *tipsVC;
//@property (nonatomic, strong) AFHTTPRequestOperation *metaCopyOperation;
//@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSArray *howtoTips;
//@property (nonatomic, strong) NSArray *tips;
@property (nonatomic, strong) AUNetClient *netClient;
@property (nonatomic, strong) AUCapture *capture;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;

@property (nonatomic, weak) IBOutlet UILabel *howtoLabel;
@property (nonatomic, weak) IBOutlet UIPageControl *howtoPageControl;

@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@property (nonatomic, weak) IBOutlet UIButton *scanButton;
@property (nonatomic, weak) IBOutlet UIButton *multiButton;

@property (nonatomic, weak) IBOutlet UIView *myGuideView;
@property (nonatomic, weak) IBOutlet UIView *myUseView;
@property (nonatomic, weak) IBOutlet UIView *myHowtoView;
@property (nonatomic, weak) IBOutlet UIView *howto1View;
@property (nonatomic, weak) IBOutlet UIView *howto2View;
@property (nonatomic, weak) IBOutlet UIScrollView *hotoScrollView;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *funcViews;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *funcButtons;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *heightConstraintForHowtoImageViews;

@end

@implementation AUHomeViewController
#pragma mark -
#pragma mark yaoyiyao
- (BOOL)canBecomeFirstResponder {
    return YES;// default is NO
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ([_netClient isConnected] &&
        !_netClient.isDetecting &&
        _netClient.isRegistered &&
        _isInHome) {
        _checkStatus = NO;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        for (AUMetadataItem *metadataItem in  gAU.metadataItems ) {
            if (metadataItem.type == AUMetadataItemTypePhoto) {
                _checkStatus = YES;
                break;
            }
        }

        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (_checkStatus) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [[AUNetClient sharedClient] shake:AUNetClientTypeShakeStart];
        } else {
            AUAlertHUDTips(kStringAllPhotosSettingoAura);
        }

    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (_checkStatus) {
        [[AUNetClient sharedClient] shake:AUNetClientTypeShakeStop];
        [_shareButton setEnabled:YES];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}


#pragma mark - Override methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self configureVar];
    [self configureBlock];
    [self configureView];
    _isRequest = YES;
}

- (void)setSetingShareCotroller {
    AUSettingShareViewController *controller = [[AUSettingShareViewController alloc]init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    if (JXiOSVersionGreaterThanOrEqual(7.0)) {
        navController.navigationBar.translucent = NO;
        navController.navigationBar.barTintColor = [UIColor orangeColor];
        navController.navigationBar.tintColor = [UIColor whiteColor];
    } else {
        [navController.navigationBar setBackgroundImage:[UIImage genWithColor:[UIColor orangeColor]] forBarMetrics:UIBarMetricsDefault];
    }
    navController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    //    UIBarButtonItem *leftItme  = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backIcon.png"] style:UIBarButtonItemStyleDone target:controller action:@selector(makeBack)];
    //    controller.navigationItem.leftBarButtonItem = leftItme;
    controller.firstLoding = YES;
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"【YJX_TEMP】%s", __func__);

    _isInHome = YES;
    gIsForFlat = YES;
    [_capture initCaptureLoadView:nil];
    _capture.deleagte = self;
    id flat = [[NSUserDefaults standardUserDefaults] objectForKey:kSlzFlatEnable];
    if (!flat) {
        flat = @"On";
        [[NSUserDefaults standardUserDefaults] setObject:flat forKey:kSlzFlatEnable];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    _flatEnabled = [flat isEqualToString:@"On"] ? YES : NO;
    _strTaskID = nil;

    if (!_onceToken) {
        _onceToken = YES;
        [self handleWifi];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    //    CGFloat width = self.view.bounds.size.width;
    //    CGFloat height = _howto1View.bounds.size.height;
    //    _howto1View.frame = CGRectMake(0, 0, width, height);
    //    _howto2View.frame = CGRectMake(0, width, width, height);
    //    _myGuideView.frame = CGRectMake(0,
    //                                    _myGuideView.frame.origin.y,
    //                                    self.view.bounds.size.width,
    //                                    _myGuideView.bounds.size.height);
    //    _myUseView.frame = CGRectMake(0, 0, self.view.bounds.size.width, _myGuideView.bounds.size.height);
    //    _myHowtoView.frame = _myUseView.frame;
    //    NSLog(@"aaabbbcccc: %@", NSStringFromCGRect(_myGuideView.frame));
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    //    _hotoScrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 2, _hotoScrollView.bounds.size.height);
    //    _hotoScrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);

    //    _myGuideView.frame = CGRectMake(0,
    //                                    _myGuideView.frame.origin.y,
    //                                    self.view.bounds.size.width,
    //                                    _myGuideView.bounds.size.height);
    //    _myUseView.frame = CGRectMake(0, 0, self.view.bounds.size.width, _myGuideView.bounds.size.height);
    //    _myHowtoView.frame = _myUseView.frame;
    //    NSLog(@"aaabbbcccc: %@", NSStringFromCGRect(_myGuideView.frame));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    _isInHome = NO;
    gIsForFlat = NO;
    [_capture stopCapture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (isFirstStartAfterInstall && !_onceGuide) {
        static int myOnceToken = 0;
        myOnceToken++;
        if (2 == myOnceToken) {
            [self autoScrollHowto];
        }
    }

    //    static int a = 0;
    //    if (1 == a) {
    //        // [self autoScrollHowto];
    ////        [_hotoScrollView setContentOffset:CGPointMake(0, 0)];
    ////        _howtoLabel.text = _howtoTips[0];
    ////        [_howtoPageControl setCurrentPage:0];
    //        _myGuideView.frame = CGRectMake(0,
    //                                        _myGuideView.frame.origin.y,
    //                                        self.view.bounds.size.width,
    //                                        _myGuideView.bounds.size.height);
    //    }
    //    a++;
}

#pragma mark - Private methods
#pragma mark configure
- (void)configureBlock {
    [self setupNet];
    [self setupWifi];
    [self setupMotion];
}

- (void)configureVar {
    //    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    //    [self.navigationController.view addSubview:_hud];
    //    _hud.labelFont = [UIFont boldSystemFontOfSize:18.0f];
    //    _hud.detailsLabelFont = [UIFont boldSystemFontOfSize:14.0f];

    _netClient = [AUNetClient sharedClient];
    _capture = [AUCapture sharedClient];
    [_capture initCaptureLoadView:nil];
    _capture.deleagte = self;

    _howtoTips = @[kStringShakePhoneToSharePhotosToAura, kStringFlatPhoneOnAuraToShowMainMenu];

    NSArray *titles = @[kStringReshareOnBegin, kStringShowMainMenu, kStringScanFace, kStringTakePhotoWithPeoples, kStringCopyPassword];
    for (int i = 0; i < _funcButtons.count; ++i) {
        [_funcButtons[i] setTitle:titles[i] forState:UIControlStateNormal];
        [_funcButtons[i] setBackgroundImage:[UIImage genWithColor:[UIColor orangeColor]] forState:UIControlStateNormal];
        [_funcButtons[i] setBackgroundImage:[UIImage genWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
        [_funcButtons[i] exSetBorder:[UIColor clearColor] width:kJXSizeForBorderWidthSmall radius:kJXSizeForCornerRadiusBig];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyApplicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyApplicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyResetGuideViewForiOS6:) name:kNotifyResetGuideViewForiOS6 object:nil];

    [AUGlobal load];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(metaItmesSuccess)
                                                name:kMetaItmesSuccessNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(metaItmesAdd)
                                                name:kMetaItmesAddNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(metaItmesRemove)
                                                name:kMetaItmesRemoveNotification
                                              object:nil];
}

- (void)configureView {
    self.title = @"AuraU";

    //    NSArray *tipsView = [[NSBundle mainBundle] loadNibNamed:@"AUHomeTipsView" owner:nil options:nil];
    //    NSMutableArray *arr = [NSMutableArray array];
    //    for (UIView *view in tipsView) {
    //        UIButton *btn = (UIButton *)[view viewWithTag:1];
    //        [btn exSetBorder:[UIColor clearColor] width:kJXSizeForBorderWidthSmall radius:kJXSizeForCornerRadiusSmall];
    //        RNBlurModalView *modal = [[RNBlurModalView alloc] initWithView:view];
    //        [modal hideCloseButton:YES];
    //        [arr addObject:modal];
    //    }
    //    _tips = arr;
//    _tipsForUnopenedVC = [[AUHomeTipsUnopenedViewController alloc] init];
//    _tipsForUnconnectedVC = [[AUHomeTipsUnconnectedViewController alloc] init];
//    _tipsForFailureVC = [[AUHomeTipsFailureViewController alloc] init];
    _tipsVC = [[AUTipsViewController alloc] init];
    __block AUHomeViewController *selfInBloc = self;
    [_tipsVC setReconnectBlock:^{
        [selfInBloc hideTips];
        [selfInBloc handleWifi];
    }];

//    __block AUHomeViewController *selfInBloc = self;
//    [_tipsForFailureVC setReconnectBlock:^{
//        [selfInBloc hideTips];
//        [selfInBloc handleWifi];
//    }];

    JXDimensionScreenResolution resolution = [JXDimension currentDimension].screenResolution;
    CGFloat constant = 252;
    if (JXDimensionScreenResolution1242x2208 == resolution) {
        constant = 380;
    }else if (JXDimensionScreenResolution750x1334 == resolution) {
        constant = 340;
    }else if(JXDimensionScreenResolution640x960 == resolution) {
        constant = 180;
    }
    for (NSLayoutConstraint *constraint in _heightConstraintForHowtoImageViews) {
        if (constant != constraint.constant) {
            constraint.constant = constant;
        }
    }

    NSDictionary *images = @{kJXBarButtonItemIconNormal: [UIImage imageNamed:@"ic_setting_normal"],
                             kJXBarButtonItemIconHighlighted: [UIImage imageNamed:@"ic_setting_highlighted"]};
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem genWithImages:images target:self action:@selector(settingItemPressed:)];

    _howtoLabel.text = _howtoTips[0];
}

#pragma mark wifi
- (void)setupWifi {
    AUNetWifi *wifi = [AUNetWifi sharedWifi];
    [wifi setupChangeBlock:^(NetworkStatus status) {
        NSLog(@"setupWifi, %ld, %ld", (long)status, (long)_tipsType);
        switch (status) {
            case NotReachable: {
                [_netClient disconnect];
                //[self showUnopenedTipsIfNeeded];
                break;
            }
            case ReachableViaWiFi: {

                [self showUnconnectedTipsIfNeeded];
                break;
            }
            default:
                break;
        }
    }];
}

- (void)handleWifi {
    //    AUAlertHUDProcessing(kStringConnecting);
    //    [[AUNetClient sharedClient] connect];
    //    return; // YJX_TEMP

    AUNetWifi *wifi = [AUNetWifi sharedWifi];

    // Wifi未开启
    if (!wifi.isEnabled) {
        if ([_netClient isConnected]) {
            [_netClient disconnect];
        }else {
            [self showUnopenedTipsIfNeeded];
        }
        return;
    }
    [self checkConnectedWifiWithConnect:YES];
}

- (void)showTipsForWifiState {
    AUNetWifi *wifi = [AUNetWifi sharedWifi];
    if (!wifi.isEnabled) {
        [self showUnopenedTipsIfNeeded];
        return;
    }
    [self checkConnectedWifiWithConnect:NO];
}

- (void)showUnopenedTipsIfNeeded {
     g_isBlcokResultCapture = NO;
    gAU.isConnectionStatus = NO;
    _tipsType = AUHomeTipsTypeUnopened;
    _statusLabel.text = nil;
    _tipsVC.type = AUTipsViewControllerTypeUnopened;
    [self presentPopupViewController:_tipsVC
                       animationType:MJPopupViewAnimationFade bgclickEnabled:NO];
}

- (void)showFailureTipsIfNeeded {
     g_isBlcokResultCapture = NO;
    gAU.isConnectionStatus = NO;
    _tipsType = AUHomeTipsTypeFailure;
    _statusLabel.text = nil;
    _tipsVC.type = AUTipsViewControllerTypeFailure;
    [self presentPopupViewController:_tipsVC
                       animationType:MJPopupViewAnimationFade bgclickEnabled:NO];
}

- (void)showUnconnectedTipsIfNeeded {
     g_isBlcokResultCapture = NO;
    gAU.isConnectionStatus = NO;
    _tipsType = AUHomeTipsTypeUnconnected;
    _statusLabel.text = nil;
    _tipsVC.type = AUTipsViewControllerTypeUnconnected;
    [self presentPopupViewController:_tipsVC
                       animationType:MJPopupViewAnimationFade bgclickEnabled:NO];
}

- (void)checkConnectedWifiWithConnect:(BOOL)connect {
    if (![[AUNetWifi sharedWifi] isAuraHotspot]) {
        if ([_netClient isConnected]) {
            [_netClient disconnect];
        }else {
            [self showUnconnectedTipsIfNeeded];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kBecomeActiveNotification object:nil];
    }else {

        if (connect) {
            [self hideTips];
            if ([_netClient isConnected] &&
                ![_netClient isRegistered]) {
                NSLog(@"【YJX_TEMP】重新注册：%s", __func__);
                AUAlertHUDProcessing(kStringConnecting);
                [_netClient sendDevice:AUNetClientTypeDeviceRegister];
                [[NSNotificationCenter defaultCenter] postNotificationName:kBecomeActiveNotification object:nil];
            }else if (![_netClient isConnected]) {
                NSLog(@"【YJX_TEMP】重新连接：%s", __func__);
                AUAlertHUDProcessing(kStringConnecting);
                [_netClient connect];
            }else {
                NSLog(@"【YJX_TEMP】异常！！！：%s", __func__);
            }
        }else {
            [self showFailureTipsIfNeeded];
        }
    }
}

- (void)hideTips {
    _tipsType = AUHomeTipsTypeNone;
    [self dismissPopupViewControllerWithanimationTypeWithNoAnimated:MJPopupViewAnimationFade];
}

//- (void)hideAllTips {
////    AUAlertHUDHide();
////    if (_tipsType == AUHomeTipsTypeNone) {
////        return;
////    }
//
//    AUAlertHUDHide();
//    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
//
////    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
////    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
////    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
////    _tipsType = AUHomeTipsTypeNone;
//}

#pragma mark flat
- (void)setupMotion {
    CMMotionManager *motionManager = [[CMMotionManager alloc] init];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    if (motionManager.accelerometerAvailable) {
        motionManager.accelerometerUpdateInterval = 1.0; // 0.4;
        [motionManager startAccelerometerUpdatesToQueue:operationQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            if (error) {
                [motionManager stopAccelerometerUpdates];
                NSLog(@"Accelerometer encounted error: %@", error);
            }else {
                static BOOL isPrevSuccess = NO;
                double x = accelerometerData.acceleration.x;
                double y = accelerometerData.acceleration.y;
                double z = accelerometerData.acceleration.z;
                if ((x > -0.1 && x < 0.1) &&
                    (y > -0.1 && y < 0.1) &&
                    (z > -1.1 && z < -0.9)) {
                    if(!isPrevSuccess) {
                        isPrevSuccess = YES;

                        if (!_isInBackground && [[AUCapture sharedClient] checkMediaPermissions]) {
                            [self performSelectorOnMainThread:@selector(flatMotion) withObject:nil waitUntilDone:NO];
                        }
                    }
                }else {
                    if(isPrevSuccess) {
                        isPrevSuccess = NO;
                    }
                }

//                static NSObject *lockObj = nil;
//                static int tryTimes = 0;
//                static BOOL isPrevSuccess = NO;
//
//                if(!lockObj) {
//                    lockObj = [[NSObject alloc] init];
//                }
//
//                @synchronized(lockObj) {
//                    double x = accelerometerData.acceleration.x;
//                    double y = accelerometerData.acceleration.y;
////                    double z = accelerometerData.acceleration.z;
//                    if ((x > -0.1 && x < 0.1) &&
//                        (y > -0.1 && y < 0.1) &&
//                        (z > -1.1 && z < -0.9)) {
//                        tryTimes++;
//                        DDLogInfo(@"tryTimes = %@", @(tryTimes));
//                        if (3 == tryTimes && !isPrevSuccess) {
//                            tryTimes = 0;
//                            isPrevSuccess = YES;
//                            [self performSelectorOnMainThread:@selector(flatMotion) withObject:nil waitUntilDone:NO];
//                        }
//                    }else {
//                        tryTimes = 0;
//
//                        if (isPrevSuccess) {
//                            isPrevSuccess = NO;
//                        }
//                    }
//                }
            }
        }];
    }else {
        NSLog(@"This device has no accelerometer!");
    }
}

- (void)flatMotion {
    if ([_netClient isConnected] &&
        !_netClient.isDetecting &&
        _netClient.isRegistered &&
        _menuButton.isEnabled &&
        _flatEnabled &&
        _isInHome) {
        [_netClient detect:AUNetClientTypeDetectInit code:@"false"];
    }
}

- (void)endDetect {
    [_capture stopCapture];
    [_netClient detect:AUNetClientTypeDetectCancelDetection code:nil];
}

- (void)startCapture {
    [_capture startCapture];
}

#pragma mark net
- (void)setupNet {
    [[AUNetClient sharedClient] setupCompletionBlockWithSuccess:^(GDataXMLDocument *xml, AUNetClientType type) {
        _clientType = type;
        switch (type) {
            case AUNetClientTypeDeviceConnect:
                [_netClient sendDevice:AUNetClientTypeDeviceRegister];
                break;

            case AUNetClientTypeDeviceRegister: {
                NSArray *nodes = [xml nodesForXPath:@"//MdmiChannel/Transaction/Connect/Result" error:nil];
                BOOL isSuccess = NO;
                for (GDataXMLElement *ele in nodes) {
                    if ([[ele stringValue] isEqualToString:@"OK"]) {
                        isSuccess = YES;
                        break;
                    }
                }
                if (isSuccess) {
                    JXAlertHUDHide();

                    _statusLabel.text =  [NSString stringWithFormat:@"%@%@", kStringConnectedSuccessfully, [AUNetWifi sharedWifi].pcName]; // kStringConnectedAura90Successfully;
                    [self refreshUIAfterRegisterSuccessfully];
                    // start HTTP server
                    NSError *error = nil;
                    [[AUNetHTTPServer sharedHttpServerEngine] startHTTPServer:error];

                    //_flatEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSlzFlatEnable];
                    if (!_flatEnabled) {
                        [_netClient showMenu:YES];
                    }else {
                        nodes = [xml nodesForXPath:@"//MdmiChannel/Transaction/Connect/MoonDialState" error:nil];
                        BOOL isShowed = NO;
                        for (GDataXMLElement *ele in nodes) {
                            if ([[ele stringValue] compare:@"visible" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                                isShowed = YES;
                                break;
                            }
                        }
                        if (!isShowed) {
                            [_menuButton setEnabled:YES];
                        }
                    }

                    if (!isFirstStartAfterInstall && !_onceGuide) {
                        [self autoScrollHowto];
                    }

                    [[NSNotificationCenter defaultCenter] postNotificationName:kBecomeActiveNotification object:nil];
                }else {
                    // _statusLabel.text = @"连接失败";
                    JXAlertHUDHide();
                    [self showFailureTipsIfNeeded];
                }
                break;
            }
            case AUNetClientTypeDeviceUserchange: {
                NSArray *nodes = [xml nodesForXPath:@"//MdmiChannel/Transaction/Connect/UserCount" error:nil];

                for (GDataXMLElement *ele in nodes) {
                    [TSUserObject sharedUserObject].strUserConnect = [NSString stringWithFormat:@"%@",[ele stringValue]];
                    [self setMultiBut];
                }

                break;
            }
            case AUNetClientTypeMediaQuery: {
                gAU.isConnectionStatus = YES;

                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                if (![userDefaults objectForKey:kSettingLoding]) {
                    [self setSetingShareCotroller];
                }else {
                    gAU.isConnectionInit = YES;
                    [gAU loadDocmentItmes];
                    if (!_onceGuide) {
                        _onceGuide = YES;
                        [UIView animateWithDuration:2.0 animations:^{
                            [_hotoScrollView setContentOffset:CGPointMake(_hotoScrollView.bounds.size.width, 0)];
                        } completion:^(BOOL finished) {
                            [_howtoPageControl setCurrentPage:1];
                        }];
                    }
                }
            }
                break;
            case AUNetClientTypeMenuHide: {
                NSArray *nodes = [xml nodesForXPath:@"//MdmiChannel/Transaction/Setting" error:nil];
                BOOL isSuccess = NO;
                for (GDataXMLElement *ele in nodes) {
                    if ([[[ele attributeForName:@"Value"] stringValue] isEqualToString:@"False"]) {
                        isSuccess = YES;
                        break;
                    }
                }

                if (isSuccess) {
                    [_menuButton setEnabled:YES];
                }
            }
                break;
            case AUNetClientTypeShakeCompleted: {
                AUAlertHUDTips(kStringAllPhotosHaveBeenSharedToAura);
                break;
            }
            case AUNetClientTypeDetectBeginReset: {
                //                [_hud hide:NO];
                //                _hud.mode = MBProgressHUDModeIndeterminate;
                //                _hud.labelText = kStringRecognizingWithEllipsis;
                //                _hud.detailsLabelText = kStringRecognizingGestureWCommaPleaseDonotMovePhoneWPeriod;
                //                [_hud show:YES];

                [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window]
                                     animated:YES

                                 hideAnimated:YES
                                    hideDelay:0
                                         mode:MBProgressHUDModeIndeterminate
                                         type:0
                                   customView:nil
                                    labelText:kStringRecognizingWithEllipsis
                             detailsLabelText:kStringRecognizingGestureWCommaPleaseDonotMovePhoneWPeriod
                                       square:NO
                                dimBackground:NO
                                        color:nil
                    removeFromSuperViewOnHide:NO
                                    labelFont:18.0
                             detailsLabelFont:14.0];
                [self performSelector:@selector(startCapture) withObject:nil afterDelay:1];
                break;
            }
            case AUNetClientTypeDetectPatternPrepared: {
                [_capture startCapture];
                break;
            }
            case AUNetClientTypeDetectDetectionSuccess: {
                [_menuButton setEnabled:NO];
                JXAlertHUDHide();
                [_capture stopCapture];
                break;
            }
            case AUNetClientTypeDetectDetectionFailed: {
                JXAlertHUDHide();

                NSArray *nodes = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhoneDetect/DetectionCode" error:nil];
                NSString *reason;
                for (GDataXMLElement *ele in nodes) {
                    reason = [ele stringValue];
                    break;
                }

                if ([reason isEqualToString:@"NotInShell"]) {
                    AUAlertHUDTips(kStringCannotBeDetectedPleaseFlatPhoneOnAura);
                }else if ([reason isEqualToString:@"TimeOut"]) {
                    AUAlertHUDTips(kStringPleaseReplacePhoneSuchAsFailureRepeatPleaseCloseIt);
                }else {
                    if (reason.length > 0) {
                        AUAlertHUDTips(reason);
                    }
                }

                [self endDetect];
                break;
            }

            case AUNetClientTypeScanRetry: {
                [[NSNotificationCenter defaultCenter]postNotificationName:kCaptureRetryNotification object:nil];
                break;
            }
            case AUNetClientTypeScanFailed: {
                [[NSNotificationCenter defaultCenter]postNotificationName:kCaptureFailedNotification object:nil];
                break;
            }

            case AUNetClientTypeScanSucceed: {
                [[NSNotificationCenter defaultCenter]postNotificationName:kCaptureSucceedNotification object:nil];
                break;
            }
            case AUNetClientTypePhotoMerge: {
                NSArray *nodes = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhotoMerge/MergeTimeout" error:nil];
                if (nodes && [nodes count] > 0) {
                    for (GDataXMLElement *ele in nodes) {
                        _isRequest = YES;
                        [self.class cancelPreviousPerformRequestsWithTarget:self];
                        AUAlertHUDHide();
                        if (_timer) {
                            dispatch_source_cancel(_timer);
                        }
                        [self.multiButton setTitle:kStringTakePhotoWithPeoples forState:UIControlStateNormal];

                        NSString *strTimeNumber = [ele stringValue];
                        AUGphotoViewController *controller = [[AUGphotoViewController alloc]init];
                        controller.strTaskID = _strTaskID;
                        controller.strTimeNumber = strTimeNumber;
                        [self.navigationController pushViewController:controller animated:YES];
                        break;
                    }
                    break;
                }
//                if (_strTaskID) {
//                    break;
//                }
                nodes = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhotoMerge" error:nil];
                for (GDataXMLElement *ele1 in nodes) {
                    NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
                    if ([cmdAttr isEqualToString:@"MergeProcessing"]) {
                        if (_isRequest) {
                            AUAlertCaptureHUDTips(kStringGroupPhotoInvitePeople);
                            [self setMultiTime];
                        }
                        break;
                    }
                }
                break;
            }
            case AUNetClientTypeMergeProcessQuit: {
                NSArray *nodes = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhotoMerge" error:nil];
                for (GDataXMLElement *ele1 in nodes) {
                    NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
                    if ([cmdAttr isEqualToString:@"MergeProcessQuit"]) {
                        if (_timer) {
                            dispatch_source_cancel(_timer);
                        }
                        [self.multiButton setTitle:kStringTakePhotoWithPeoples forState:UIControlStateNormal];
                        break;
                    }
                }
                break;
            }
            case AUNetClientTypeMergeSucceed:
            case AUNetClientTypeCopyCanceled:
            case AUNetClientTypeCopyToPhone: {
                static AFHTTPRequestOperation *operation;

                if (_clientType == AUNetClientTypeCopyCanceled) {
                    if (operation) {
                        [operation cancel];
                    }
                    break;
                }

                k_MediaType mediaType;
                NSString *identifier;
                NSString *sourceIP;
                NSString *sourceURL;
                NSString *type;
                NSString *path;
                NSString *taskid;
                NSString *cdata;
                NSString *strName;
                NSArray *arr1 = nil;
                if (_clientType == AUNetClientTypeMergeSucceed)
                    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhotoMerge/FileItem" error:nil];
                else
                    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/FileCopy/FileList/FileItem" error:nil];

                for (GDataXMLElement *ele1 in arr1) {
                    sourceIP = [[ele1 attributeForName:@"SourceIP"] stringValue];
                    sourceURL = [[ele1 attributeForName:@"SourceURL"] stringValue];
                    cdata  = [ele1 stringValue];
                    NSRange range1 = [cdata rangeOfString:@">Path<"];
                    NSRange range2 = [cdata rangeOfString:@">Length<"];
                    path = [cdata substringWithRange:NSMakeRange(range1.location + range1.length,
                                                                 range2.location - range1.location - range1.length)];

                    range1 = [cdata rangeOfString:@"Type<"];
                    range2 = [cdata rangeOfString:@">ID<"];
                    type = [cdata substringWithRange:NSMakeRange(range1.location + range1.length,
                                                                 range2.location - range1.location - range1.length)];

                    range1 = [cdata rangeOfString:@">ID<"];
                    range2 = [cdata rangeOfString:@">Path<"];
                    identifier = [cdata substringWithRange:NSMakeRange(range1.location + range1.length,
                                                                       range2.location - range1.location - range1.length)];
                    break;
                }
                if (_clientType == AUNetClientTypeMergeSucceed)
                    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhotoMerge" error:nil];
                else
                    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/FileCopy" error:nil];

                for (GDataXMLElement *ele1 in arr1) {
                    taskid = [[ele1 attributeForName:@"TaskID"] stringValue];
                    break;
                }
                strName = [[path componentsSeparatedByString:@"\\"] lastObject];
                if ([type isEqualToString:@"Photo"]) {
                    mediaType = MediaPhtot;
                } else if ([type isEqualToString:@"PhotoMerge"]) {
                    mediaType = PhotoMerge;
                } else if ([type isEqualToString:@"Video"]) {
                    mediaType = MediaVideo;
                } else {
                    mediaType = MediaMusic;
                }
                if (mediaType == MediaMusic) {
                    [_netClient sendCopyerrorMessageWithTaskid:taskid fileitemCData:cdata];
                    break;
                }

                GDataXMLNode *downloadCData = [GDataXMLNode createCData:path];

                GDataXMLElement *downloadElement = [GDataXMLNode elementWithName:@"Download"];
                GDataXMLElement *idAttr = [GDataXMLNode attributeWithName:@"ID" stringValue:identifier];
                GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:type];
                GDataXMLElement *isThumbnailAttr = [GDataXMLNode attributeWithName:@"IsThumbnail" stringValue:@"False"];
                [downloadElement addAttribute:idAttr];
                [downloadElement addAttribute:typeAttr];
                [downloadElement addAttribute:isThumbnailAttr];
                [downloadElement addChild:downloadCData];

                GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:downloadElement];
                NSString *downloadString = [[NSString alloc] initWithData:[xmlDoc XMLData] encoding:NSUTF8StringEncoding];
                NSLog(@"downloadString = %@", downloadString);

                //                BOOL isDeviceCommunication = YES;
                //                NSRange rangeFile= [sourceURL rangeOfString:@"file"];
                //                if (rangeFile.length > 0)
                //                {
                //
                //                     if (mediaType == MediaPhtot) {
                //                         isDeviceCommunication = NO;
                //                         sourceURL =  [sourceURL stringByAppendingString:@"/image"];
                //                     }
                //                }
                //
                //                NSRange rangeMedia= [sourceURL rangeOfString:@"streaming"];
                //                if (rangeMedia.length > 0)
                //                {
                //                    if (mediaType == MediaVideo) {
                //                        isDeviceCommunication = NO;
                //                        sourceURL =  [sourceURL stringByAppendingString:@"/video"];
                //                    }
                //                    if (mediaType == MediaMusic) {
                //                        isDeviceCommunication = NO;
                //                        sourceURL =  [sourceURL stringByAppendingString:@"/music"];
                //                    }
                //                }

                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:sourceURL]];
                request.HTTPBody = [xmlDoc XMLData];
                request.HTTPMethod = @"POST";
                //[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

                __block int mbs = 1;
                __block long long countForLast = 0;
//                __block AUNetClient *netInBlock = _netClient;
//                __block AUHomeViewController *homeInBlock = self;
//                __block NSDictionary *infoInBlock = _dicCaptureInfo;
                operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [_netClient sendCopyCompletedMessageWithTaskid:taskid
                                                          sourceIP:sourceIP
                                                     fileitemCData:cdata];
                    if (_clientType == AUNetClientTypeMergeSucceed) {
                        _dicCaptureInfo = @{@"imageName": strName,@"imageData":responseObject};
                        g_isBlcokResultCapture = NO;
//                        AUUtil *util = [[AUUtil alloc]init];
                        [self setCaptureResults:_dicCaptureInfo];

//                        [[NSNotificationCenter defaultCenter] postNotificationName:kResultsNotification object:_dicCaptureInfo];
                    }
                    if (mediaType == MediaPhtot || mediaType == MediaVideo) {
                        [AUUtil saveToAlbumWithMetadata:nil fileData:responseObject fileName:strName customAlbumName:@"AuraU" mediaType:mediaType completionBlock:^{
                            //DDLogInfo(@"responseObject = %@", responseObject);
                            if (mediaType == MediaPhtot) {
//                                NSString *strFilePath = [AUSerialization getFilePhoto];
//                                NSArray *arrayGroups = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];
//                                strFilePath = [NSString stringWithFormat:@"%@/%@",strFilePath,@"Aurau"];
//                                if ([arrayGroups containsObject:@"Aurau"]) {
//                                    NSString *imagePath = [strFilePath stringByAppendingPathComponent:strName];
//                                    NSData *imageData = responseObject;
//                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                        if(![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
//                                        {
//                                            [imageData writeToFile:imagePath atomically:YES];
//                                            [gAU loadDocmentItmes];
//                                        }
//                                    });
//                                }
                            }

                        } failureBlock:^(NSError *error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //添加失败一般是由用户不允许应用访问相册造成的，这边可以取出这种情况加以判断一下
                                if([error.localizedDescription rangeOfString:@"User denied access"].location != NSNotFound ||[error.localizedDescription rangeOfString:@"用户拒绝访问"].location!=NSNotFound){

                                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];

                                    [alert show];
                                }
                            });
                        }];
                    }


                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    DDLogInfo(@"%s: error = %@", __func__, error);
                }];
                if (_clientType == AUNetClientTypeCopyToPhone)
                {
                    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//                        DDLogInfo(@"bytesRead = %@, totalBytesRead = %@, totalBytesExpectedToRead = %@", @(bytesRead), @(totalBytesRead), @(totalBytesExpectedToRead));
                        if (totalBytesExpectedToRead < kSizeForOneMb) {
                            return;
                        }

                        if (totalBytesRead / mbs >= kSizeForOneMb) {
                            mbs++;
                            [_netClient copyProcessing:AUNetClientTypeCopyProcessing
                                                taskID:taskid
                                            sourceIP:sourceIP
                                              progress:JXIntToString(totalBytesExpectedToRead)
                                                 delta:JXIntToString(totalBytesRead - countForLast)
                                                 cdata:cdata];
                            countForLast = totalBytesRead;
                        }
                    }];
                }
                [operation start];

                break;
            }
            case AUNetClientTypeDeviceUnregister: {
                //_isRegistered = NO;
                [_netClient disconnect];
                if (!_isInBackground) {
                    AUAlertHUDProcessing(kStringReconnecting);
                    [_netClient connect];
                }
                break;
            }
            case AUNetClientTypeMergeReject: {
                _isRequest = YES;
                [self.class cancelPreviousPerformRequestsWithTarget:self];
                AUAlertHUDHide();
                [[[UIAlertView alloc]initWithTitle:kStringPeopleNeedToBeDoneInTheAuraDesktopPhoto
                                           message:nil
                                          delegate:nil
                                 cancelButtonTitle:kStringOK
                                 otherButtonTitles: nil] show];
                break;
            }
            case AUNetClientTypeFullUser: {
                _isRequest = YES;
                [self.class cancelPreviousPerformRequestsWithTarget:self];
                AUAlertHUDHide();
                [[[UIAlertView alloc]initWithTitle:kStringFunctionCanOnlyBeFourPeopleAtTheSameTimeUse
                                           message:nil
                                          delegate:nil
                                 cancelButtonTitle:kStringOK
                                 otherButtonTitles: nil] show];
                break;
            }

            default:
                break;
        }
    } failure:^(NSError *error) {
        AUAlertHUDHide();
        //if (3 == error.code || kErrorForRegisterTimeout == error.code) {
        // _statusLabel.text = @"连接超时，请重连Wifi后再次尝试！";
        // [self showFailureTipsIfNeeded];
        //}
         g_isBlcokResultCapture = NO;
        [_netClient disconnect];
        [self showTipsForWifiState];

        DDLogInfo(@"failure:^(NSError *error): %ld, %@", (long)error.code, [error localizedDescription]);
        // _statusLabel.text = [error localizedFailureReason];
    }];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", responseText);
}

- (void)settingItemPressed:(id)sender {
    AUSettingViewController *settingVC = [[AUSettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark func
- (void)refreshUIAfterRegisterSuccessfully {
    //[_menuButton setEnabled:YES];
    [_scanButton setEnabled:YES];
    [_multiButton setEnabled:YES];
}

- (void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediaTypes = [UIImagePickerController
                           availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:
         sourceType] && [mediaTypes count] > 0) {
        NSArray *mediaTypes = [UIImagePickerController
                               availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = nil; // self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:picker animated:YES completion:NULL];
    } else {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:kStringAccessError
                                   message:kStringYourDeviceNotSupportThisFunction
                                  delegate:nil
                         cancelButtonTitle:kStringCancel
                         otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark other
//- (void)showHint:(NSString *)hint mode:(MBProgressHUDMode)mode {
//    NSLog(@"%s: %@", __func__, hint);
//    [_hud hide:NO];
//    _hud.mode = mode;
//    _hud.labelText = nil;
//    _hud.detailsLabelText = hint;
//    [_hud show:YES];
////    [_hud showAnimated:YES whileExecutingBlock:^{
////        sleep(1.2);
////    } completionBlock:^{
////        [_hud hide:YES];
////    }];
//
//    [_hud hide:YES afterDelay:kHUDHideDelayTime];
//}

- (void)setMultiTime
{
    __block int timeout= 60;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.multiButton setTitle:kStringTakePhotoWithPeoples forState:UIControlStateNormal];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *strContent = [NSString stringWithFormat:@"%@ %ds", kStringTakePhotoWithPeoples, timeout];
                [self.multiButton setTitle:strContent forState:UIControlStateNormal];
            });
            timeout--;

        }
    });
    dispatch_resume(_timer);
}

- (void)setMultiBut
{
    if ([[TSUserObject sharedUserObject].strUserConnect integerValue] >= 2)
        [self.multiButton setEnabled:YES];
}

- (void)autoScrollHowto {
    if (!_onceGuide) {
        _onceGuide = YES;
        [UIView animateWithDuration:1.2 animations:^{
            [_hotoScrollView setContentOffset:CGPointMake(_hotoScrollView.bounds.size.width, 0)];
        } completion:^(BOOL finished) {
            _howtoLabel.text = _howtoTips[1];
            [_howtoPageControl setCurrentPage:1];
        }];
    }
}

#pragma mark - Action methods
- (IBAction)shakeButtonPressed:(id)sender {
    [[AUNetClient sharedClient] shake:AUNetClientTypeShakeReset];
    [_shareButton setEnabled:NO];
    AUAlertHUDTips(kStringAgainShakeWillBeginFromFirstPhoto);
}

- (IBAction)menuButtonPressed:(id)sender {
    [[AUNetClient sharedClient] showMenu:YES];
    [_menuButton setEnabled:NO];
}

- (IBAction)makeCaptureAction:(id)sender {
    if ([[AUCapture sharedClient] checkMediaPermissions]) {
        AUCaptureVIewController *controller = [[AUCaptureVIewController alloc]initWithNibName:@"AUCaptureVIewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)makeGphotoAction:(id)sender {
    if (g_isBlcokResultCapture) {
        AUResultViewController *controller = [[AUResultViewController alloc]init];
        controller.resultsDicCaptureInfo = _dicCaptureInfo;
        _dicCaptureInfo = nil;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
   if ([[AUCapture sharedClient] checkMediaPermissions]) {
       _dicCaptureInfo = nil;
       if ([[TSUserObject sharedUserObject].strUserConnect integerValue] < 2) {
           UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:kStringFunctionShouldBeManyPeopleConnectTheAura
                                                              message:nil
                                                             delegate:nil
                                                    cancelButtonTitle:kStringOK
                                                    otherButtonTitles: nil];
           [alertView show];
           [self.multiButton setEnabled:NO];
           return;
       }
       AUAlertHUDProcessing(kStringHandling);
       _isRequest = NO;
       NSTimeInterval timeInter = [[NSDate new] timeIntervalSince1970];
       _strTaskID = [NSString stringWithFormat:@"%.0f",timeInter];
       [[AUNetClient sharedClient] photoMergeTaskID:_strTaskID filePath:nil length:0];
       [self performSelector:@selector(makeCloseHUD) withObject:self afterDelay:5.];
    }

}

- (void)makeCloseHUD
{
    _isRequest = YES;
    AUAlertHUDHide();
    AUAlertHUDTips(kStringRequestFailedPleaseRetry);

}
#pragma mark - Notification methods
- (void)notifyApplicationDidBecomeActive:(NSNotification *)notification {
    NSLog(@"%s", __func__);
    _isInBackground = NO;
    [self setupWifi];
    // [[AUNetWifi sharedWifi] restartWifiChange];

    if (!_onceToken) {
        _onceToken = YES;
        [self performSelector:@selector(handleWifi) withObject:nil afterDelay:0.5];
        //[self handleWifi];
    }

    //    if ([_netClient isConnected] &&
    //        _netClient.isRegistered) {
    //        [_netClient showMenu:YES];
    //        [_menuButton setEnabled:NO];
    //    }
}

- (void)notifyApplicationWillResignActive:(NSNotification *)notification {
    NSLog(@"%s", __func__);
    _onceToken = NO;
    _isInBackground = YES;
    //    if ([_netClient isConnected] &&
    //        _netClient.isRegistered) {
    //        // [_netClient showMenu:NO];
    //        //[_menuButton setEnabled:YES];
    //        [_netClient sendDevice:AUNetClientTypeDeviceUnregister];
    //    }

    [[AUNetWifi sharedWifi] setupChangeBlock:nil];
}

- (void)notifyResetGuideViewForiOS6:(NSNotification *)notification {
    [_hotoScrollView setContentOffset:CGPointMake(0, 0)];
    _howtoLabel.text = _howtoTips[0];
    [_howtoPageControl setCurrentPage:0];
}

- (void)metaItmesSuccess {
    NSArray *array = [gAU.metadataItems copy];
    [[AUNetClient sharedClient] metadataCount:array.count];
    [[AUNetClient sharedClient] metadataList:array listActionType:MediaActionInit];

}

- (void)metaItmesAdd {
    NSArray *array = [gAU.addMetadataItems copy];

    [[AUNetClient sharedClient] metadataList:array listActionType:MediaActionAdd];

}

- (void)metaItmesRemove {
    NSArray *array = [gAU.removeMetadataItems copy];;
    [[AUNetClient sharedClient] metadataList:array listActionType:MediaActionRemove];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger selected = lround(scrollView.contentOffset.x / scrollView.contentSize.width * 2);
    _howtoLabel.text = _howtoTips[selected];
    [_howtoPageControl setCurrentPage:selected];
}

#pragma mark AUCaptureDeleagate
- (void)AUCapture:(AUCapture *)capture isCaptureImage:(UIImage *)image {
    static BOOL onceToken = NO;
    if (onceToken) {
        return;
    }
    onceToken = YES;

    IplImage *img = [AUScanline convertToIplImage:image];
    switch (_clientType) {
        case AUNetClientTypeDetectBeginReset: {
            static NSInteger i = 0;
            int test = [AUScanline TestEV:img];
            NSLog(@"%s: TestEV = %ld", __func__, (long)test);
            if (0 == test) {
                i = 0;
                [_capture stopCapture];
                [_netClient detect:AUNetClientTypeDetectEndReset code:_netClient.detectionCode];
            }else {
                if (++i == 5) {
                    i = 0;
                    [_capture stopCapture];
                    [_netClient detect:AUNetClientTypeDetectCancelDetection code:nil];
                    AUAlertHUDTips(kStringCannotBeDetectedPleaseFlatPhoneOnAura);
                }
            }
        }
            break;
        case AUNetClientTypeDetectPatternPrepared: {
            int code = [AUScanline GetCode:img];
            if (0 != code) {
                [_netClient detect:AUNetClientTypeDetectTakeReady code:JXIntToString(code)];
            }
        }
            break;
        default: {
            [_capture stopCapture];
        }
            break;
    }
    [AUScanline releaseImage:img];

    onceToken = NO;
}


- (void)setCaptureResults:(NSDictionary *)dic
{
    
    _dicInfo = dic;
    _resultsView = [[AUResultsView alloc] init];

    UIViewController *controller = [JXUtil getCurrentRootViewController];
    [controller presentPopupViewController:_resultsView
                             animationType:MJPopupViewAnimationFade bgclickEnabled:NO];
    UIImage *image = [[UIImage alloc] initWithData:_dicInfo[@"imageData"]];
    _resultsView.imageView.image = image;
    _resultsView.delegate = self;

}


#pragma mark  - AUResultsView
- (void)AUResultsViewIsCancelButtonClicked:(AUResultsView *)resultsView
{
    g_isBlcokResultCapture = NO;
    UIViewController *controller = [JXUtil getCurrentRootViewController];
    [controller dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCancelButtonClicked object:nil];

}

- (void)AUResultsViewIsOkButtonClicked:(AUResultsView *)resultsView {
    [AUUtil saveToAlbumWithMetadata:nil fileData:_dicInfo[@"imageData"] fileName:_dicInfo[@"imageName"] customAlbumName:@"AuraU" mediaType:PhotoMerge completionBlock:^{
        //        NSString *strFilePath = [AUSerialization getFilePhoto];
        //        NSArray *arrayGroups = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];
        //        strFilePath = [NSString stringWithFormat:@"%@/%@",strFilePath,@"Aurau"];
        //        if ([arrayGroups containsObject:@"Aurau"]) {
        //            NSString *imagePath = [strFilePath stringByAppendingPathComponent:_dicInfo[@"imageName"]];
        //            NSData *imageData = _dicInfo[@"imageData"];
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                if(![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        //                {
        //                    [imageData writeToFile:imagePath atomically:YES];
        //                    [gAU loadDocmentItmes];
        //                }
        //            });
        //        }
    } failureBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //添加失败一般是由用户不允许应用访问相册造成的，这边可以取出这种情况加以判断一下
            if([error.localizedDescription rangeOfString:@"User denied access"].location != NSNotFound ||[error.localizedDescription rangeOfString:@"用户拒绝访问"].location!=NSNotFound){

                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];

                [alert show];
            }
        });
    }];

    g_isBlcokResultCapture = NO;
    UIViewController *controller = [JXUtil getCurrentRootViewController];
    [controller dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
     [[NSNotificationCenter defaultCenter] postNotificationName:kOkButtonClicked object:nil];
}

@end
