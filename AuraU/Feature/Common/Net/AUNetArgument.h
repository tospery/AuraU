//
//  AUNetArgument.h
//  AuraU
//
//  Created by Thundersoft on 15/2/15.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AUNetArgument : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *ipForDestination;


+ (instancetype)sharedArgument;
@end
