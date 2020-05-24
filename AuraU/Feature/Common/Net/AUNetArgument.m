//
//  AUNetArgument.m
//  AuraU
//
//  Created by Thundersoft on 15/2/15.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUNetArgument.h"
#import "AUNetWifi.h"

@implementation AUNetArgument
- (instancetype)init {
    if (self = [super init]) {
        _name = [[UIDevice currentDevice] name];
        _version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    return self;
}

- (NSString *)ip {
    return [AUNetWifi sharedWifi].ip;
}

- (NSString *)mac {
    return [AUNetWifi sharedWifi].mac;
}

- (NSString *)ipForDestination {
    return [AUNetWifi sharedWifi].ipForDestination;
}

+ (instancetype)sharedArgument {
    static AUNetArgument *_sharedArgument = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedArgument = [[AUNetArgument alloc] init];
    });

    return _sharedArgument;
}
@end
