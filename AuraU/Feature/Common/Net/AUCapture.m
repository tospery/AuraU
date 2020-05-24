//
//  AUCapture.m
//  AuraU
//
//  Created by Army on 15-3-12.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUCapture.h"

BOOL gIsForFlat = NO;

@implementation AUCapture

#pragma mark - Class methods
+ (instancetype)sharedClient {
    static AUCapture *_sharedCapture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCapture = [[AUCapture alloc] init];
    });

    return _sharedCapture;
}

#pragma mark - AVCaptureDevice
- (void)toggleCamera {

    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];

    if (cameraCount > 1) {

        NSError *error;

        AVCaptureDeviceInput *newVideoInput;

        AVCaptureDevicePosition position = [[self.captureInput device] position];

        if (position == AVCaptureDevicePositionBack)

            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];

        else if (position == AVCaptureDevicePositionFront)

            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];

        else

            return;

        if (newVideoInput != nil) {

            [self.captureSession beginConfiguration];

            [self.captureSession removeInput:self.captureInput];

            if ([self.captureSession canAddInput:newVideoInput]) {

                [self.captureSession addInput:newVideoInput];

                [self setCaptureInput:newVideoInput];

            } else {

                [self.captureSession addInput:self.captureInput];

            }

            [self.captureSession commitConfiguration];

        } else if (error) {

            NSLog(@"toggle carema failed, error = %@", error);

        }

    }

}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }

    return nil;

}

- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];

}

- (AVCaptureDevice *)backCamera {

    return [self cameraWithPosition:AVCaptureDevicePositionBack];

}

- (AVCaptureDevice *)getFrontCameraIsDeviceMediaType:(BOOL)deviceMediaType
{
    if (deviceMediaType) {
        return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    } else {
        NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in cameras)
        {
            if (device.position == AVCaptureDevicePositionFront)
                return device;
        }
        return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)checkMediaPermissions
{
    if (JXiOSVersionGreaterThanOrEqual(7.0)) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            NSLog(@"相机权限受限");
            dispatch_async(dispatch_get_main_queue(), ^{
                AUAlertHUDTips(kStringPleaseOpenTheCameraInTheSetPermissions);
            });

            return NO;
        }
    }
     return YES;
}
- (void)initCaptureLoadView:(UIView *)view
{
    BOOL cameraIsDeviceMediaType = view ? NO :YES;

    if (![self checkMediaPermissions]) {
        return;
    }

    if (!self.captureSession ) {
         self.captureSession = [[AVCaptureSession alloc] init];
    }

    self.inputDevice =  [self getFrontCameraIsDeviceMediaType:cameraIsDeviceMediaType];
    NSError *error = nil;
    if ([self.inputDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] && [self.inputDevice lockForConfiguration:&error]) {
        [self.inputDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [self.inputDevice unlockForConfiguration];
    }

    if (!self.inputDevice) {
        return;
    }
    if (self.captureInput) {
        [self.captureSession removeInput:self.captureInput];
    }  
    if (self.captureOutput) {
        [self.captureSession removeOutput:self.captureOutput];
    }
    self.captureInput = [AVCaptureDeviceInput deviceInputWithDevice:self.inputDevice error:nil];
    [self.captureSession addInput:self.captureInput];
    self.captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.captureOutput.alwaysDiscardsLateVideoFrames = YES;
    [self.captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    NSString* key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [self.captureOutput setVideoSettings:videoSettings];
    [self.captureSession addOutput:self.captureOutput];
    NSString* preset = 0;
    if (JXiOSVersionGreaterThanOrEqual(7.0) && view) {
        if (NSClassFromString(@"NSOrderedSet") && // Proxy for "is this iOS 5" ...
            [UIScreen mainScreen].scale > 1 &&
            [self.inputDevice
             supportsAVCaptureSessionPreset:AVCaptureSessionPreset1280x720]) {
                // NSLog(@"960");
                preset = AVCaptureSessionPreset1280x720;
            }
    } else {
        if (NSClassFromString(@"NSOrderedSet") && // Proxy for "is this iOS 5" ...
            [UIScreen mainScreen].scale > 1 &&
            [self.inputDevice
             supportsAVCaptureSessionPreset:AVCaptureSessionPreset352x288]) {
                // NSLog(@"960");
                preset = AVCaptureSessionPreset352x288;
            }
    }

    if (!preset) {
        // NSLog(@"MED");
        preset = AVCaptureSessionPresetMedium;
    }
    self.captureSession.sessionPreset = preset;

    if (!self.captureVideoPreviewLayer) {
        self.captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    }
    // NSLog(@"prev %p %@", self.prevLayer, self.prevLayer);

    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    if (view) {
        self.captureVideoPreviewLayer.frame = view.bounds;
        [view.layer addSublayer: self.captureVideoPreviewLayer];
        [self startCapture];
    }
}

- (void)startCapture
{
    [self.captureSession startRunning];
}

- (void)stopCapture
{
    [self.captureSession stopRunning];
}

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef buffer;
    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(buffer, 0);

    //从 CVImageBufferRef 取得影像的细部信息
    uint8_t *base;
    size_t width, height, bytesPerRow;
    base = CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);

    //利用取得影像细部信息格式化 CGContextRef
    CGColorSpaceRef colorSpace;
    CGContextRef cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);

    //透过 CGImageRef 将 CGContextRef 转换成 UIImage
    CGImageRef cgImage;
    UIImage *image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);

    CVPixelBufferUnlockBaseAddress(buffer, 0);

    return image;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    AVCaptureConnection *videoConnection = NULL;
    for ( AVCaptureConnection *connections in [captureOutput connections] )
    {
        for ( AVCaptureInputPort *port in [connections inputPorts] )
        {
            if ( [[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connections;
                if ([videoConnection isVideoOrientationSupported])
                {
                    [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                }
                
            }
        }
    }
    if ([self.deleagte respondsToSelector:@selector(AUCapture:isCaptureImage:)]) {
        UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
        [self.deleagte AUCapture:self isCaptureImage:image];
    }
}

@end
