//
//  AUCaptureVIewController.m
//  AuraU
//
//  Created by Army on 15-3-5.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUCaptureVIewController.h"
#import "GDataXMLNode.h"

@interface AUCaptureVIewController ()<AUCaptureDeleagate>
{
    AUCapture *_capture;
    BOOL  _captureStatus;
}

@property (nonatomic, strong)IBOutlet UIView *viewContent;
@property (nonatomic, assign) CGFloat minOffset;
@property (nonatomic, assign) CGFloat maxOffset;
@property (nonatomic, assign) CGFloat curOffset;
@property (nonatomic, strong) NSTimer *indicatorTimer;
@property (nonatomic, weak) IBOutlet UILabel *topTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *bottomTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView * indicatorImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * indicatorConstraint;
@end

@implementation AUCaptureVIewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _captureStatus = YES;
    JXDimension *dimension = [JXDimension currentDimension];
    if (dimension.screenResolution == JXDimensionScreenResolution640x960) {
        _minOffset = 2.0f;
        _maxOffset = 264.0f;
    }else if (dimension.screenResolution == JXDimensionScreenResolution750x1334) {
        _minOffset = 20.0f;
        _maxOffset = 404.0f;
    }else if (dimension.screenResolution == JXDimensionScreenResolution1242x2208) {
        _minOffset = 30.0f;
        _maxOffset = 454.0f;
    }else {
        _minOffset = 8.0f;
        _maxOffset = 330.0f;
    }
    _curOffset = _minOffset;
    _indicatorConstraint.constant = _curOffset;

    self.title = kStringScanFace;
    _topTitleLabel.text = kStringScanYourFaceThenYourPhotoWillShowInAura;
    _bottomTitleLabel.text = kStringPleaseScanYourFace;

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(captureFaile)
                                                name:kCaptureFailedNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(captureSucceed)
                                                name:kCaptureSucceedNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(captureRetry)
                                                name:kCaptureRetryNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];


    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"camera_switch_pressed.png"] style:UIBarButtonItemStyleDone target:self action:@selector(markCaptureAction)];
    self.navigationItem.rightBarButtonItem = backItem;
    // Do any additional setup after loading the view from its nib.
}

- (void)dealloc {
    [_indicatorTimer invalidate];
    _indicatorTimer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!_capture) {
        _capture = [AUCapture sharedClient];
        _capture.deleagte = self;
        [_capture initCaptureLoadView:self.viewContent];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_capture startCapture];
    _indicatorTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(indicatorTimerSchedule) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[AUCapture sharedClient] stopCapture];

    if (!JXiOSVersionGreaterThanOrEqual(7.0)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyResetGuideViewForiOS6 object:nil];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)indicatorTimerSchedule {
    if (_indicatorImageView.isHidden) {
        [_indicatorImageView setHidden:NO];
    }

    CGFloat nextOffset = _indicatorConstraint.constant + 4.0;
    if (nextOffset >= _maxOffset) {
        nextOffset = _minOffset;
    }
    _indicatorConstraint.constant = nextOffset;
}

#pragma mark - Action
//前后摄像头切换
- (void)markCaptureAction
{
    [_capture toggleCamera];
}

- (void)AUCapture:(AUCapture *)capture isCaptureImage:(UIImage *)image
{
    if (_captureStatus) {
        _captureStatus = NO;
        NSData *imageData = UIImagePNGRepresentation(image);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *strFilePath = [AUSerialization getFileCapture];
            if (![[NSFileManager defaultManager] fileExistsAtPath:strFilePath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:strFilePath withIntermediateDirectories:YES attributes:nil error:nil];
            }

            NSString *strListName =  [[[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil] lastObject];
            if (strListName) {
                NSString *strRemoveFileUrl = [strFilePath stringByAppendingPathComponent:strListName];
                [[NSFileManager defaultManager] removeItemAtPath:strRemoveFileUrl error:nil];

            }
            NSDate *date  = [NSDate new];
            NSTimeInterval timeInter = [date timeIntervalSince1970];
            NSString *strFileNmae = [NSString stringWithFormat:@"%@_%@.jpg",file_CapName,[NSString stringWithFormat:@"%.0f",timeInter]];
            NSString *imagePath = [strFilePath stringByAppendingPathComponent:strFileNmae];

            dispatch_async(dispatch_get_main_queue(), ^{
                [imageData writeToFile:imagePath atomically:YES];
                
                [[AUNetClient sharedClient] scan:AUNetClientTypeScanStart taskID:[NSString stringWithFormat:@"%.0f",timeInter] filePath:strFileNmae length:imageData.length];
            });
        });
    }
}

#define mark NSNotificationCenter
- (void)captureFaile {
    AUAlertCaptureHUDTips(kStringCaptureFaile);
    [_capture stopCapture];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)captureSucceed
{
    AUAlertCaptureHUDTips(kStringScanSuccess);
    [_capture stopCapture];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)captureRetry
{
    _captureStatus = YES;
}

- (void)makeBackground
{
    [_capture stopCapture];
    [self.navigationController popViewControllerAnimated:YES];
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
