//
//  AUNetWifi.m
//  AuraU
//
//  Created by Thundersoft on 15/2/15.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUNetWifi.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AdSupport/AdSupport.h>

Reachability *wifiReachability;

@interface AUNetWifi ()
@property (nonatomic, copy) void(^changeBlock)(NetworkStatus status);
@end

@implementation AUNetWifi
//- (NSString *)mac {
//    if (![self isEnabled]) {
//        return nil;
//    }
//
//    int                    mib[6];
//    size_t                len;
//    char                *buf;
//    unsigned char        *ptr;
//    struct if_msghdr    *ifm;
//    struct sockaddr_dl    *sdl;
//
//    mib[0] = CTL_NET;
//    mib[1] = AF_ROUTE;
//    mib[2] = 0;
//    mib[3] = AF_LINK;
//    mib[4] = NET_RT_IFLIST;
//
//    if ((mib[5] = if_nametoindex("en0")) == 0) {
//        return NULL;
//    }
//
//    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
//        return NULL;
//    }
//
//    if ((buf = malloc(len)) == NULL) {
//        return NULL;
//    }
//
//    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
//        return NULL;
//    }
//
//    ifm = (struct if_msghdr *)buf;
//    sdl = (struct sockaddr_dl *)(ifm + 1);
//    ptr = (unsigned char *)LLADDR(sdl);
//    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
//    free(buf);
//
//    return [outstring uppercaseString];
//}

- (NSString *)ssid {
    if (![self isEnabled]) {
        return nil;
    }

    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    NSString *ssid;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        ssid = [(NSDictionary *)info objectForKey:@"SSID"];
    }
    return ssid;
}

- (NSString *)mac {
    if (![self isEnabled]) {
        return nil;
    }
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}

- (NSString *)ipForDestination {
    if (![self isEnabled]) {
        return nil;
    }
    
    NSDictionary *ifs = [self fetchSSIDInfo];
    NSString *ssid = [[ifs objectForKey:@"SSID"] lowercaseString];
    NSString *hex = [ssid substringFromIndex:ssid.length - 2];
    NSString *ip = [NSString stringWithFormat:@"192.168.%@.1", [hex exHexToDec]];
    return ip;
}

- (NSString *)pcName {
    if (![self isEnabled]) {
        return nil;
    }

    NSDictionary *ifs = [self fetchSSIDInfo];
    NSString *ssid = [[ifs objectForKey:@"SSID"] lowercaseString];
    NSArray *result = [ssid componentsSeparatedByString:@"_"];
    return result[1];
}

- (NSString *)ip {
    if (![self isEnabled]) {
        return nil;
    }

    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }

            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);

    return address;
}

- (BOOL)isEnabled {
    return [Reachability reachabilityForLocalWiFi].currentReachabilityStatus == ReachableViaWiFi;
}

- (BOOL)isAuraHotspot {
    if (![self isEnabled]) {
        return NO;
    }

    NSString *ssid = [AUNetWifi sharedWifi].ssid;
    if (!ssid || ![ssid hasPrefix:kWifiNamePrefix]) {
        return NO;
    }

    return YES;
}

- (void)setupChangeBlock:(void (^)(NetworkStatus))change {
    _changeBlock = change;
}


-(id)fetchSSIDInfo {
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    return info;
}

- (NSString *)currentWifiSSID {
    // Does not work on the simulator.
    NSString *ssid = nil;
    NSArray *ifs = (__bridge   id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"dici：%@",[info  allKeys]);
        if (info[@"SSIDD"]) {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
}

#pragma mark - Notification methods
- (void)notifyReachabilityChanged:(NSNotification *)notification {
    Reachability* currentReachability = [notification object];
    NetworkStatus networkStatus = currentReachability.currentReachabilityStatus;
    if (_changeBlock) {
        _changeBlock(networkStatus);
    }
}

- (void)restartWifiChange {
    [wifiReachability stopNotifier];
    [wifiReachability startNotifier];
}

#pragma Class methods
+ (void)load {
    [super load];

    AUNetWifi *wifi = [AUNetWifi sharedWifi];
    [[NSNotificationCenter defaultCenter] addObserver:wifi selector:@selector(notifyReachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    wifiReachability = [Reachability reachabilityForLocalWiFi];
    [wifiReachability startNotifier];
}

+ (instancetype)sharedWifi {
    static AUNetWifi *_sharedWifi = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWifi = [[AUNetWifi alloc] init];
    });

    return _sharedWifi;
}
@end
