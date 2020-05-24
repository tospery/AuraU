//
//  AUGphotoViewController.m
//  AuraU
//
//  Created by Thundersoft on 15/3/17.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUGphotoViewController.h"
#import "AUResultViewController.h"

@interface AUGphotoViewController ()<AUCaptureDeleagate,UIAlertViewDelegate>
{
    AUCapture *_capture;
    dispatch_time_t _popTime;
    UIImage *_backImage;

    dispatch_source_t _timer;
}
@property (nonatomic,strong)IBOutlet UIView *cameraView;

@property (nonatomic,strong)IBOutlet UIView *catpureView;
@property (nonatomic,strong)IBOutlet UIView *actionView;

@property (nonatomic,strong)IBOutlet UIButton *button_retake;
@property (nonatomic,strong)IBOutlet UIButton *butotn_ok;

@property (nonatomic,strong)IBOutlet UILabel *lableTime;
@property (nonatomic,strong)IBOutlet UIImageView *imageTimes;
@property (nonatomic,strong)IBOutlet UIView *viewTime;
@end

@implementation AUGphotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = kStringTakePhotoWithPeoples;
    [self loadIB];

    [_butotn_ok setTitle:kStringOK forState:UIControlStateNormal];
    [_button_retake setTitle:kStringRetake forState:UIControlStateNormal];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"camera_switch_pressed.png"] style:UIBarButtonItemStyleDone target:self action:@selector(markCaptureAction)];
    self.navigationItem.rightBarButtonItem = backItem;

    UIBarButtonItem *leftItme  = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backIcon.png"] style:UIBarButtonItemStyleDone target:self action:@selector(makeBack)];
    self.navigationItem.leftBarButtonItem = leftItme;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_capture startCapture];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    if (!JXiOSVersionGreaterThanOrEqual(7.0)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyResetGuideViewForiOS6 object:nil];
    }

    [[AUCapture sharedClient] stopCapture];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!_capture) {
        _capture = [AUCapture sharedClient];
        _capture.deleagte = self;
        [_capture initCaptureLoadView:self.cameraView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadIB
{
    self.button_retake.layer.masksToBounds = YES;
    self.button_retake.layer.borderWidth = kJXSizeForBorderWidthMiddle;
    self.button_retake.layer.borderColor = [UIColor grayColor].CGColor;
    self.button_retake.layer.cornerRadius = kJXSizeForCornerRadiusMiddle;

    self.butotn_ok.layer.masksToBounds = YES;
    self.butotn_ok.layer.borderWidth = kJXSizeForBorderWidthMiddle;
    self.butotn_ok.layer.borderColor = [UIColor grayColor].CGColor;
    self.butotn_ok.layer.cornerRadius = kJXSizeForCornerRadiusMiddle;

    NSInteger tiem = [self.strTimeNumber integerValue];
    if (tiem > 0) {
        [self.viewTime setHidden:NO];

        NSMutableArray *arrayImages = [[NSMutableArray alloc]init];
        double index = 0;
        int i = 5 - floor((tiem / 10));
        if (i < 0)
            i = 0;
        for (int k = i ; k < 6 + i; k++) {
            if (k > 5) {
                index = 5;
            } else {
                index = k;
            }
            NSString *strImageName = [NSString stringWithFormat:@"camera_timer%.0f.png",index];
            UIImage *image = [UIImage imageNamed:strImageName];
            [arrayImages addObject:image];
        }

        self.imageTimes.contentMode = UIViewContentModeScaleToFill;
        self.imageTimes.animationImages = arrayImages;
        self.imageTimes.animationDuration = 60;
        self.imageTimes.animationRepeatCount = 1;
        [self.imageTimes startAnimating];
        __block NSInteger timeout= tiem;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            if(timeout<=0){
                if (_timer) {
                    dispatch_source_cancel(_timer);
                    _timer = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.imageTimes stopAnimating];
                        [self.imageTimes setImage:[UIImage imageNamed:@"camera_timer5.png"]];
                        [[AUNetClient sharedClient] mergeQuitTaskID:_strTaskID];
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:kStringTimeIsUp
                                                                           message:nil
                                                                          delegate:self
                                                                 cancelButtonTitle:kStringOK
                                                                 otherButtonTitles: nil];
                        [alertView show];
                    });
                }

            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.lableTime setText:[NSString stringWithFormat:@"%lds",(long)timeout]];
                });
                timeout--;
                
            }
        });
        dispatch_resume(_timer);
    } else
        [self.viewTime setHidden:YES];

}
#pragma mark - Action
- (void)markCaptureAction
{
    [_capture toggleCamera];
}

- (IBAction)makeTakeImageAction:(id)sender
{
    [_capture stopCapture];
    [self.catpureView setHidden:YES];
    [self.actionView setHidden:NO];

}

- (IBAction)makeOkAction:(id)sender
{

    if (_timer) {
         dispatch_source_cancel(_timer);
    }
    NSString *strFilePath = [AUSerialization getFileCapture];
    if (![[NSFileManager defaultManager] fileExistsAtPath:strFilePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:strFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *strListName =  [[[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil] lastObject];
    if (strListName) {
        NSString *strRemoveFileUrl = [strFilePath stringByAppendingPathComponent:strListName];
        [[NSFileManager defaultManager] removeItemAtPath:strRemoveFileUrl error:nil];
    }

    NSString *strFileNmae = [NSString stringWithFormat:@"%@_%@.jpg",file_CapName,_strTaskID];
    NSString *imagePath = [strFilePath stringByAppendingPathComponent:strFileNmae];

    NSData *imageData = UIImagePNGRepresentation(_backImage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [imageData writeToFile:imagePath atomically:YES];
        [[AUNetClient sharedClient] photoMergeTaskID:_strTaskID filePath:strFileNmae length:imageData.length];
    });
    g_isBlcokResultCapture = YES;
    AUResultViewController *controller = [[AUResultViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)makeRetakeAction:(id)sender
{
    [self.catpureView setHidden:NO];
    [self.actionView setHidden:YES];
    [_capture startCapture];
}

- (void)makeBack
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    [[AUNetClient sharedClient] mergeQuitTaskID:_strTaskID];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - AUCaptureDeleagate
- (void)AUCapture:(AUCapture *)capture isCaptureImage:(UIImage *)image
{
    _backImage = image;
}

#pragma mark - UIAlertViewDelegate
 - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NSNotificationCenter
- (void)makeBackground
{
    [self makeBack];
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
