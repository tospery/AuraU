//
//  JXErrorHandler.h
//  MySystem02（错误处理）
//
//  Created by 杨建祥 on 15/1/24.
//  Copyright (c) 2015年 杨建祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXErrorHandler : NSObject
@property (nonatomic, assign) BOOL fatal;
@property (nonatomic, strong) NSError *error;

- (instancetype)initWithError:(NSError *)error fatal:(BOOL)fatal;

+ (void)handleError:(NSError *)error fatal:(BOOL)fatal;
@end
