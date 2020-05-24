//
//  JXPhone.m
//  MyiOS
//
//  Created by Thundersoft on 10/20/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import "JXPhone.h"
#import "JXString.h"
#import "JXTool.h"
#import <UIKit/UIKit.h>

@implementation JXPhone
+ (BOOL)supportCall {
    BOOL result = NO;
    if([[UIDevice currentDevice].model isEqualToString:kStringiPhone])
    {
        result = YES;
    }
    return result;
}

+ (void)dialNumber:(NSString *)mobile {
    if (![[self class] supportCall]) {
        JXLogError(kStringYourDeviceNotSupportCallFunctionWithExclam);
        JXAlertSystem(kStringYourDeviceNotSupportCallFunctionWithExclam);
        return;
    }

    NSURL *mobileURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", mobile]];
    static UIWebView *callWebView;
    if (!callWebView) {
        callWebView = [[UIWebView alloc]initWithFrame:CGRectZero];
    }
    [callWebView loadRequest:[NSURLRequest requestWithURL:mobileURL]];
}
@end
