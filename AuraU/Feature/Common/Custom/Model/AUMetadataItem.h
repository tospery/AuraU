//
//  AUMetadataItem.h
//  AuraU
//
//  Created by Thundersoft on 15/3/6.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AUMetadataItemType){
    AUMetadataItemTypePhoto,
    AUMetadataItemTypeMusic,
    AUMetadataItemTypeVideo,
    AUMetadataItemTypeMerge,
    AUMetadataItemTypeFaceScan
};

@interface AUMetadataItem : NSObject </*NSCoding, */NSCopying>
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) AUMetadataItemType type;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *albumTitle; //专辑名
@property (nonatomic, strong) NSString *artist; //歌手名
@property (nonatomic, assign) NSUInteger lengthBytes; //文件字节大小

+ (NSArray *)typeRepresents;
@end
