//
//  UIFont+JXApple.m
//  MyiOS
//
//  Created by Thundersoft on 14-11-5.
//  Copyright (c) 2014年 Thundersoft. All rights reserved.
//

#import "UIFont+JXApple.h"

@implementation UIFont (JXApple)
+ (UIFont *)thonburiFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Thonburi" size:size];
}

+ (UIFont *)thonburiBoldFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Thonburi-Bold" size:size];
}

+ (UIFont *)thonburiLightFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Thonburi-Light" size:size];
}

+ (UIFont *)timesNewRomanPSBoldItalicMTFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:size];
}

+ (UIFont *)timesNewRomanPSMTFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"TimesNewRomanPSMT" size:size];
}

+ (UIFont *)timesNewRomanPSBoldMTFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:size];
}

+ (UIFont *)timesNewRomanPSItalicMTFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:size];
}
@end
