//
//  AUScanline.h
//  AuraU
//
//  Created by Thundersoft on 15/3/13.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "opencv2/core/types_c.h"

#define OTSU_TRRESHOLD 1
#define THRESHOLD_S    128     //value for segment foreground
#define THRESHOLD_V    100     //value for segment foreground
#define THRESHOLD_2    0.08    //ratio of foreground

@interface AUScanline : NSObject
//  0 -> success
// -2 -> failure
//  1 -> increase EV
// -1 -> decrease EV
+ (int)TestEV:(IplImage *)img;

+ (int)GetCode:(IplImage *)img;
+ (IplImage *)convertToIplImage:(UIImage *)image;
+ (void)releaseImage:(IplImage *)img;
@end
