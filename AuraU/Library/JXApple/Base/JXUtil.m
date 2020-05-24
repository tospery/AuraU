//
//  JXUtil.m
//  iOSLibrary
//
//  Created by 杨建祥 on 15/1/10.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "JXUtil.h"
#import "JXApple.h"

@implementation JXUtil
+ (NSString *)verifyInput:(NSString *)input least:(NSInteger)least hint:(NSString *)hint {
    if (0 == input.length) {
        return [NSString stringWithFormat:@"%@%@！", kStringPleaseInput, hint];
    }
    
    NSString *pure = [input trim];
    if (0 == pure.length) {
        return [NSString stringWithFormat:@"%@%@", hint, kStringCantIsAllWhitespaceCharsWithEMark];
    }
    
    if (pure.length < least) {
        return [NSString stringWithFormat:@"%@%ld%@", kStringPleaseInputAtLeast, (long)least, kStringNumCharsWithEMark];
    }
    
    return nil;
}

+ (NSString *)getAppVersion
{
     NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    return appVersion;
}

+ (UIViewController *)getCurrentRootViewController {

    UIViewController *result;

    // Try to find the root view controller programmically

    // Find the top window (that is not an alert view or other window)

    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];

    if (topWindow.windowLevel != UIWindowLevelNormal) {

        NSArray *windows = [[UIApplication sharedApplication] windows];

        for(topWindow in windows) {

            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }

    }

    UIView *rootView = [[topWindow subviews] objectAtIndex:0];

    id nextResponder = [rootView nextResponder];

    if ([nextResponder isKindOfClass:[UIViewController class]])

        result = nextResponder;

    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)

        result = topWindow.rootViewController;

    else

        NSAssert(NO, @"ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
    
    return result;
    
}


@end
