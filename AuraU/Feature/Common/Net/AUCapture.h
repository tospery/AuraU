//
//  AUCapture.h
//  AuraU
//
//  Created by Army on 15-3-12.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AUCapture;
@protocol AUCaptureDeleagate <NSObject>

- (void)AUCapture:(AUCapture *)capture isCaptureImage:(UIImage *)image;

@end

@interface AUCapture : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *inputDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *captureInput ;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureOutput;

@property (nonatomic, weak) id<AUCaptureDeleagate>deleagte;

+ (instancetype)sharedClient;

//前后镜头切换
- (void)toggleCamera;

//不需要显示设置nil
- (void)initCaptureLoadView:(UIView *)view;

//view设置nil 手动调用开启
- (void)startCapture;

- (void)stopCapture;

//检测摄像头是否可用
- (BOOL)checkMediaPermissions;

@end
