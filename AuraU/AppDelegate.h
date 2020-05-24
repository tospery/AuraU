//
//  AppDelegate.h
//  iOSBase02（获取尺寸信息）
//
//  Created by Thundersoft on 10/17/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *_navController;
}

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate *)appDelegate;
- (void)makeController;

extern BOOL g_isBlcokResultCapture;

@end
