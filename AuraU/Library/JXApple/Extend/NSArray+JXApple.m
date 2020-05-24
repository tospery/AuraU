//
//  NSArray+JXApple.m
//  MantleTutorial
//
//  Created by Thundersoft on 15/1/30.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "NSArray+JXApple.h"

@implementation NSArray (JXApple)
- (NSString *)exStringValue {
    NSMutableString *result = [NSMutableString string];
    for (id value in self) {
        if ([value isKindOfClass:[NSString class]]) {
            [result appendString:value];
        }else if ([value isKindOfClass:[NSValue class]]) {
            [result appendString:[value stringValue]];
        }else {
            [result appendString:[value description]];
        }
    }
    return result;
}
@end
