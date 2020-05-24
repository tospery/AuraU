//
//  JXTool.h
//  MyiOS
//
//  Created by Thundersoft on 10/17/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#ifndef MyiOS_JXTool_h
#define MyiOS_JXTool_h

#import "JXString.h"

// Localize
#ifdef JXLOCALIZATION_ON
#define JXT(local, display)                   local
#else
#define JXT(local, display)                   display
#endif

// System version
#define JXiOSVersionGreaterThanOrEqual(x)   ([[[UIDevice currentDevice] systemVersion] floatValue] >= (x))

// Degree&Radian
#define JXDegreeToRadian(x)                 (M_PI * (x) / 180.0)

#define JXIntToString(x)                    ([NSString stringWithFormat:@"%lld", ((long long)x)])

// Color
#define JXRGBColor(r, g, b)                 [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define JXRGBAColor(r, g, b, a)             [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]
#define JXHexRGBColor(rgbValue)             [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define JXHexRGBAColor(rgbValue,a)          [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

// Loading
#define JXShowProcessing(superview)         [JXLoadingView showProcessingAddedTo:(superview) activityProcessingViewColor:nil gifProcessingImageName:nil]
#define JXShowFailed(superview, statements) [JXLoadingView showFailedAddedTo:(superview) failedMessage:nil failedImageName:nil retry:^{statements;}]
#define JXHideLoading(superview)            [JXLoadingView hideForView:(superview)]

#pragma mark - Alert
// System Alert
#define JXAlertSystem(msg)                      \
[[[UIAlertView alloc] initWithTitle:kStringTips message:msg delegate:nil cancelButtonTitle:kStringOK otherButtonTitles: nil]show]
// HUD Alert
#define JXAlertHUDSuccess(msg)                  \
[MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES hideAnimated:YES hideDelay:1.2 mode:0 type:MBProgressHUDTypeSuccess customView:nil labelText:nil detailsLabelText:(msg) square:NO dimBackground:NO color:nil removeFromSuperViewOnHide:NO labelFont:16.0f detailsLabelFont:12.0f];
#define JXAlertHUDFailure(msg)                  \
[MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES hideAnimated:YES hideDelay:1.2 mode:0 type:MBProgressHUDTypeFailure customView:nil labelText:nil detailsLabelText:(msg) square:NO dimBackground:NO color:nil removeFromSuperViewOnHide:NO labelFont:16.0f detailsLabelFont:12.0f];
#define JXAlertHUDTips(msg)                     \
[MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES hideAnimated:YES hideDelay:1.2 mode:0 type:MBProgressHUDTypeTips customView:nil labelText:nil detailsLabelText:(msg) square:NO dimBackground:NO color:nil removeFromSuperViewOnHide:NO labelFont:16.0f detailsLabelFont:12.0f];
#define JXAlertHUDProcessing(msg)               \
[MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES hideAnimated:YES hideDelay:0 mode:MBProgressHUDModeIndeterminate type:0 customView:nil labelText:(msg) detailsLabelText:nil square:NO dimBackground:NO color:nil removeFromSuperViewOnHide:NO labelFont:16.0f detailsLabelFont:12.0f];
#define JXAlertHUDHide()                        \
[MBProgressHUD hideAllHUDsForView:[[UIApplication sharedApplication].delegate window] animated:YES];
// Notify Alert
#define JXAlertNotifySuccess(msg)               \
[JDStatusBarNotification showWithStatus:(msg) dismissAfter:1.2 styleName:JDStatusBarStyleSuccess]
#define JXAlertNotifyFailure(msg)               \
[JDStatusBarNotification showWithStatus:(msg) dismissAfter:1.2 styleName:JDStatusBarStyleError]
#define JXAlertNotifyTips(msg)                  \
[JDStatusBarNotification showWithStatus:(msg) dismissAfter:1.2 styleName:JDStatusBarStyleDefault]

// Log
#define JXLogError(msg)                     NSLog(@"%@%@\n\tfile: %s\n\tline: %d\n\tfunc: %s", kStringErrorWithGuillemet, msg, __FILE__, __LINE__,  __func__)

#define JXTerminate(msg)             \
NSAssert(NO, @"%@%@", kStringErrorWithGuillemet, msg)

// Device
#define JXDeviceIsPad                  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define JXDeviceIsPhone                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#endif









