//
//  JXDimension.h
//  MyiOS
//
//  Created by Thundersoft on 10/17/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kJXDimensionStatusBarHeight                     (20)

typedef NS_ENUM(NSInteger, JXDimensionScreenWidth){
    JXDimensionScreenWidth320 = 320,
    JXDimensionScreenWidth375 = 375,
    JXDimensionScreenWidth414 = 414
};

typedef NS_ENUM(NSInteger, JXDimensionScreenHeight){
    JXDimensionScreenHeight480 = 480,
    JXDimensionScreenHeight568 = 568,
    JXDimensionScreenHeight667 = 667,
    JXDimensionScreenHeight736 = 736
};

typedef NS_ENUM(NSInteger, JXDimensionNavBarHeight){
    JXDimensionNavBarHeightStandalone = 44,
    JXDimensionNavBarHeightIntertwine = 64
};

typedef NS_ENUM(NSInteger, JXDimensionScreenResolution){
    JXDimensionScreenResolutionNone,
    JXDimensionScreenResolution640x960,         // earlier than iPhone 5
    JXDimensionScreenResolution640x1136,        // iPhone 5/5S
    JXDimensionScreenResolution750x1334,        // iPhone 6
    JXDimensionScreenResolution1242x2208        // iPhone 6 Plus
};

@interface JXDimension : NSObject
@property (assign, nonatomic, readonly) JXDimensionScreenResolution screenResolution;
@property (assign, nonatomic, readonly) CGSize screenSize;
@property (assign, nonatomic, readonly) CGSize appFrame;
@property (assign, nonatomic, readonly) CGFloat statusBarHeight;
@property (assign, nonatomic, readonly) CGFloat navBarHeight;

+ (JXDimension *)currentDimension;
@end
