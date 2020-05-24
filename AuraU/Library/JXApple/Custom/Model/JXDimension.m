//
//  JXDimension.m
//  MyiOS
//
//  Created by Thundersoft on 10/17/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import "JXDimension.h"
#import "JXTool.h"
#import "JXString.h"

static JXDimension *dimension = nil;

@interface JXDimension ()
@property (assign, nonatomic, readwrite) JXDimensionScreenResolution screenResolution;
@property (assign, nonatomic, readwrite) CGSize screenSize;
@property (assign, nonatomic, readwrite) CGSize appFrame;
@property (assign, nonatomic, readwrite) CGFloat statusBarHeight;
@property (assign, nonatomic, readwrite) CGFloat navBarHeight;
@end

@implementation JXDimension
#pragma mark - Class methods
+ (JXDimension *)currentDimension {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        dimension = [[[self class] alloc] init];
    });
    return dimension;
}

#pragma mark - Override methods
- (instancetype)init {
    if (self = [super init]) {
        CGSize resolution = [UIScreen mainScreen].currentMode.size;
        if (CGSizeEqualToSize(resolution, CGSizeMake(640, 960))) {
            _screenResolution = JXDimensionScreenResolution640x960;
        }else if (CGSizeEqualToSize(resolution, CGSizeMake(640, 1136))) {
            _screenResolution = JXDimensionScreenResolution640x1136;
        }else if (CGSizeEqualToSize(resolution, CGSizeMake(750, 1334))) {
            _screenResolution = JXDimensionScreenResolution750x1334;
        }else if (CGSizeEqualToSize(resolution, CGSizeMake(1242, 2208))) {
            _screenResolution = JXDimensionScreenResolution1242x2208;
        }else {
            JXLogError(kStringNotSupportThisDeviceWithExclam);
            JXAlertSystem(kStringNotSupportThisDeviceWithExclam);
            JXTerminate(kStringParameterExceptionWithEMark);
        }

        _screenSize = [UIScreen mainScreen].bounds.size;
        _appFrame = [UIScreen mainScreen ].applicationFrame.size;

        _statusBarHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
        if (JXiOSVersionGreaterThanOrEqual(7.0)) {
            _navBarHeight = JXDimensionNavBarHeightIntertwine; // combine with status bar
        }else {
            _navBarHeight = JXDimensionNavBarHeightStandalone; // don't combine with status bar
        }
    }
    return self;
}

- (NSString *)description {
    NSString *desc = [NSString stringWithFormat:@"<%@: %p>, detail->\nscreenResolution: %ld\nscreenSize: (%.2f, %.2f)\nappFrame: (%.2f, %.2f)\nstatusBarHeight: %.2f\nnavBarHeight: %.2f", NSStringFromClass(self.class), self, (long)_screenResolution, _screenSize.width, _screenSize.height, _appFrame.width, _appFrame.height, _statusBarHeight, _navBarHeight];
    return desc;
}
@end



