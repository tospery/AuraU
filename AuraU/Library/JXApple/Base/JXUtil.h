//
//  JXUtil.h
//  iOSLibrary
//
//  Created by 杨建祥 on 15/1/10.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXUtil : NSObject
+ (NSString *)verifyInput:(NSString *)input least:(NSInteger)least hint:(NSString *)hint;

+ (NSString *)getAppVersion;

+ (UIViewController *)getCurrentRootViewController;
@end
