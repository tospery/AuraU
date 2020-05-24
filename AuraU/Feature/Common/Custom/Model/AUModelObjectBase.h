//
//  AUModelObjectBase.h
//  AuraU
//
//  Created by Army on 15-2-12.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<AssetsLibrary/AssetsLibrary.h>
#import "VideoLibrary.h"
#import <MediaPlayer/MediaPlayer.h>

@class TSAssetsGroupObject;
@interface AUPhotoAlbum : NSObject
{
    
}

typedef void (^metadataItemsBlock)(void);
typedef void (^metadataNumber50Block)(void);

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *arrayPhotoGruop;
@property (nonatomic, strong) NSMutableArray *arrayHttpItems;

+ (AUPhotoAlbum *)sharedPhotoAlbum;

- (void)getAssetsLibraryGroupsObject:(TSAssetsGroupObject *)assetsGroup onBlock:(metadataItemsBlock)block Number50Block:(metadataNumber50Block)metadatablock;
- (UIImage *)transformSize:(CGSize)size image:(UIImage *)image;


@end

@interface TSAssetsGroupObject : NSObject

@property (nonatomic,strong)UIImage *image;
@property (nonatomic,strong)NSString *strTitle,*strNumber;
@property (nonatomic,assign)k_enum_Choose isChoose;
@property (nonatomic,strong)ALAssetsGroup *assetsGroup;

@property (nonatomic,strong) NSMutableArray *arrayAssect;

@end

@interface TSMusicObject : NSObject

@property (nonatomic,strong)NSString *strMusicName;
@property (nonatomic,strong)NSURL *strmusicUrl;
@property (nonatomic,assign)k_enum_Choose isChoose;
@property (nonatomic,strong)MPMediaItemArtwork *mediaItme;
@property (nonatomic,strong)NSString *albumTitle; //专辑名
@property (nonatomic,strong)NSString *artist; //歌手名


@end

@interface TSUserObject : NSObject

@property (nonatomic,strong)NSString *strUserConnect;

+ (TSUserObject *)sharedUserObject;

@end
