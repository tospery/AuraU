//
//  JXPhone.h
//  MyiOS
//
//  Created by Thundersoft on 10/20/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXPhone : NSObject
+ (BOOL)supportCall;
+ (void)dialNumber:(NSString *)mobile;
@end
