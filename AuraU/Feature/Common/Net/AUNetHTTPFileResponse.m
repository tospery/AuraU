//
//  AUNetHTTPFileResponse.m
//  AuraU
//
//  Created by Thundersoft on 15/3/16.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUNetHTTPFileResponse.h"

@implementation AUNetHTTPFileResponse
- (NSDictionary *)httpHeaders {
    NSString *key = @"Content-Disposition";
    NSString *value = [NSString stringWithFormat:@"attachment; filename=\"%@\"", [filePath lastPathComponent]];

    return [NSDictionary dictionaryWithObjectsAndKeys:value, key, nil];
}
@end
