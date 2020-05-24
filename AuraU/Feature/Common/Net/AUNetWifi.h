//
//  AUNetWifi.h
//  AuraU
//
//  Created by Thundersoft on 15/2/15.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AUNetWifi : NSObject
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *ipForDestination;
@property (nonatomic, strong) NSString *pcName;

- (void)restartWifiChange;
- (BOOL)isEnabled;
- (BOOL)isAuraHotspot;
- (void)setupChangeBlock:(void (^)(NetworkStatus status))change;

+ (instancetype)sharedWifi;
@end
