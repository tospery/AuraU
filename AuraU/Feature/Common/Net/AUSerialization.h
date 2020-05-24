//
//  AUSerialization.h
//  AuraU
//
//  Created by Army on 15-3-1.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AUSerialization : NSObject
+ (NSString *)getFileDocument;
+ (NSString *)getFilePhoto;
+ (NSString *)getFileVideo;
+ (NSString *)getFileMusic;
+ (NSString *)getFileCapture;
+ (NSString *)getFileNormal;
@end
