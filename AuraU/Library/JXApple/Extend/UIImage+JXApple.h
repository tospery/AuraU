//
//  UIImage+JXApple.h
//  MyiOS
//
//  Created by Thundersoft on 10/20/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JXApple)
- (UIImage *)drawText:(NSString *)text font:(UIFont *)font color:(UIColor *)color size:(CGSize)size;
- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage *)exStretchCenter;

+ (UIImage *)genWithColor:(UIColor *)color;
@end
