//
//  AppDelegate.m
//  iOSBase02（获取尺寸信息）
//
//  Created by Thundersoft on 10/17/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import "AppDelegate.h"
#import "TSAdvertiseController.h"
#import "AUHomeViewController.h"
#import "AUIntroViewController.h"
#import "JXLogFormatter.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"



BOOL isFirstStartAfterInstall = NO;

BOOL g_isBlcokResultCapture = NO;

@interface AppDelegate ()
@property (nonatomic, strong) Reachability *hostReachability;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self configLog];
    [AUNetArgument sharedArgument];
    [self configureWindow];
    // [self entryGuide];
    [self entryHome];

    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [userDefaults objectForKey:kAppVersion];
    if ([version isEqualToString:appVersion]) {
        [self makeController];
    } else {
        isFirstStartAfterInstall = YES;
        [self loadAdvertiseView];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    UIApplication *app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid) {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [gAU checkMedia];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[AUNetClient sharedClient] disconnect];
}

#pragma mark - Private
- (void)configureWindow {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

- (void)entryGuide {
    // self.window.rootViewController = [[AUGuideViewController alloc] init];
    //[self.window makeKeyAndVisible];
}

- (void)loadAdvertiseView {
    AUIntroViewController *advertise = [[AUIntroViewController alloc] init];
    self.window.rootViewController = advertise;
    [self.window makeKeyAndVisible];
}

- (void)entryHome {
    _navController = [[UINavigationController alloc] initWithRootViewController:[[AUHomeViewController alloc] init]];
    if (JXiOSVersionGreaterThanOrEqual(7.0)) {
        _navController.navigationBar.translucent = NO;
//        _navController.navigationBar.barTintColor = [UIColor orangeColor];
        _navController.navigationBar.tintColor = [UIColor whiteColor];
        [_navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_backImage.png"] forBarMetrics:UIBarMetricsDefault];
    } else {
        [_navController.navigationBar setBackgroundImage:[UIImage genWithColor:[UIColor orangeColor]] forBarMetrics:UIBarMetricsDefault];
    }
    _navController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [UIColor whiteColor], NSForegroundColorAttributeName, nil];
}

- (void)makeController {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.5;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionFade;
    NSUInteger green = [[self.window  subviews] indexOfObject:self.window.rootViewController];
    NSUInteger blue = [[self.window  subviews] indexOfObject:_navController];
    [self.window exchangeSubviewAtIndex:green withSubviewAtIndex:blue];
    [[self.window layer] addAnimation:animation forKey:@"animation"];
    self.window.rootViewController = _navController;

    [self.window makeKeyAndVisible];
}

- (void)configLog {
    //JXLogFormatter *formatter = [[JXLogFormatter alloc] init];

    //[[DDASLLogger sharedInstance] setLogFormatter:formatter];
    [DDLog addLogger:[DDASLLogger sharedInstance]];

    //[[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    [DDTTYLogger sharedInstance].colorsEnabled = YES;
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *logsDirectory = [baseDir stringByAppendingPathComponent:@"Logs"];
    DDLogFileManagerDefault *logFileManagerDefault = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logsDirectory];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManagerDefault];
    //fileLogger.logFormatter = formatter;
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.maximumFileSize  = 1024 * 1024 * 1;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
}


#pragma mark - Class methods
+ (AppDelegate *)appDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

@end
