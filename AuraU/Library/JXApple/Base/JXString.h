//
//  JXString.h
//  MyiOS
//
//  Created by Thundersoft on 10/19/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#ifndef MyiOS_JXString_h
#define MyiOS_JXString_h

#import "JXTool.h"

// 1字
#define kStringNone                                                         \
JXT(NSLocalizedString(@"None", @"无"), @"无")
#define kStringiPhone                                                       \
JXT(NSLocalizedString(@"iPhone", @"iPhone"), @"iPhone")


// 2个字
#define kStringOK                                                           \
JXT(NSLocalizedString(@"OK", @"确定"), @"确定")
#define kStringCancel                                                       \
JXT(NSLocalizedString(@"Cancel", @"取消"), @"取消")
#define kStringTips                                                         \
JXT(NSLocalizedString(@"Tips", @"提示"), @"提示")
#define kStringNumCharsWithEMark                                            \
JXT(NSLocalizedString(@"chars", @"个字！"), @"个字！")
#define kStringErrorWithGuillemet                                           \
JXT(NSLocalizedString(@"【Error】", @"【错误】"), @"【错误】")
#define kStringDismiss                                                      \
JXT(NSLocalizedString(@"Dismiss", @"忽略"), @"忽略")
#define kStringReport                                                       \
JXT(NSLocalizedString(@"Report", @"报告"), @"报告")
#define kStringExit                                                         \
JXT(NSLocalizedString(@"Exit", @"退出"), @"退出")
#define kStringSetting                                                         \
JXT(NSLocalizedString(@"Setting", @"设置"), @"设置")
#define kStringSuccess                                                         \
JXT(NSLocalizedString(@"Success", @"成功"), @"成功")
#define kStringFailure                                                         \
JXT(NSLocalizedString(@"Failure", @"失败"), @"失败")
#define kStringHint                                                        \
JXT(NSLocalizedString(@"Hint", @"提醒"), @"提醒")


// 3个字
#define kStringPleaseInput                                                  \
JXT(NSLocalizedString(@"Please input", @"请输入"), @"请输入")


// 4个字
#define kStringParameterExceptionWithEMark                                  \
JXT(NSLocalizedString(@"Parameter exception!", @"参数异常！"), @"参数异常！")
#define kStringSoSorry                                                      \
JXT(NSLocalizedString(@"So sorry", @"非常抱歉"), @"非常抱歉")
#define kStringExceptionReport                                              \
JXT(NSLocalizedString(@"Exception report", @"异常报告"), @"异常报告")
#define kStringHandling                                                     \
JXT(NSLocalizedString(@"Handling", @"正在处理"), @"正在处理")


// More
#define kStringExceptionExitAtPreviousRuningWithEMark                                                               \
JXT(NSLocalizedString(@"An error occurred on the previous run", @"程序在上次异常退出！"), @"程序在上次异常退出！")
#define kStringLoadFailedWithCommaClickToRetryWithExclam                                                            \
JXT(NSLocalizedString(@"Load failed, click to retry!", @"加载失败，点击重试！"), @"加载失败，点击重试！")
#define kStringYourDeviceNotSupportCallFunctionWithExclam                                                           \
JXT(NSLocalizedString(@"Your device doesn't support the call!", @"您的设备不支持电话功能！"), @"您的设备不支持电话功能！")
#define kStringNotSupportThisDeviceWithExclam                                                                       \
JXT(NSLocalizedString(@"Don't support this device!", @"不支持该设备！"), @"不支持该设备！")
#define kStringPleaseInputAtLeast                                                                                   \
JXT(NSLocalizedString(@"PleaseInput", @"请输入至少"), @"请输入至少")
#define kStringCantIsAllWhitespaceCharsWithEMark                                                                    \
JXT(NSLocalizedString(@"CantIsAllWhitespaceCharWithEMark", @"不能全为空格或换行符！"), @"不能全为空格或换行符！")
#define kStringUnhandledError                                                                                       \
JXT(NSLocalizedString(@"UnhandledError", @"未处理错误"), @"未处理错误")
#define kStringRequestFailedPleaseRetry                                                                                       \
JXT(NSLocalizedString(@"RequestFailedPleaseRetry", @"请求失败，请重新请求"), @"请求失败，请重新请求")



#endif






