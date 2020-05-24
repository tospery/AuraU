//
//  AUGlobal.m
//  AuraU
//
//  Created by Thundersoft on 15/3/6.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUGlobal.h"
#import "AUMetadataItem.h"
#import "AUModelObjectBase.h"

#include <sys/stat.h>
#include <dirent.h>

NSMutableDictionary *gNameDict;
NSMutableDictionary *gURLDict;

BOOL gMediaArrangeFinished;

@interface AUGlobal ()
{
    NSObject  *_syncObj;
    AVAssetExportSession *_exportSession;
    NSMutableArray *_arrayMedia;

    NSMutableArray *_arrayPhoto;
    NSMutableArray *_arrayVideo;
    NSMutableArray *_arrayMusic;

    NSMutableArray *_arrayGroups;

    __block NSMutableArray *_arrayImageName;
    __block NSMutableArray *_arrayContainsGroup;

    VideoLibrary *_videoLibrary;
    NSInteger _contentNumbuer;
    double _progressNumber;

    NSInteger _startIndex;
    //    NSMutableArray *_arrayVideo;
    //    NSMutableArray *_arrayMusic;

}

@end


@implementation AUGlobal
+ (instancetype)sharedInstance {
    static AUGlobal *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AUGlobal alloc] init];
    });

    return _sharedInstance;
}

+ (void)load {
    [super load];
    gAU = [AUGlobal sharedInstance];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        gNameDict = [NSMutableDictionary dictionaryWithCapacity:100];
        gURLDict = [NSMutableDictionary dictionaryWithCapacity:100];
        self.isOperatingState = YES;
        self.metadataItems = [[NSMutableArray alloc]init];
        _syncObj = [[NSObject alloc] init];
        _arrayMedia = [[NSMutableArray alloc]init];
        _startIndex  = kIndex;
        _arrayPhoto = [[NSMutableArray alloc]init];
        _arrayVideo = [[NSMutableArray alloc]init];
        _arrayMusic = [[NSMutableArray alloc]init];
        _arrayGroups = [[NSMutableArray alloc]init];
        _arrayImageName = [[NSMutableArray alloc]init];
        _dic_FileId = [[NSMutableDictionary alloc]init];
        _arrayAssetsLibraryChanged = [[NSMutableArray alloc]init];
        _arrayContainsGroup = [[NSMutableArray alloc]init];

        _addMetadataItems = [[NSMutableArray alloc]init];
        _removeMetadataItems = [[NSMutableArray alloc]init];
        //        [[NSNotificationCenter defaultCenter]addObserver:self
        //                                                selector:@selector(becomeActiveNotification)
        //                                                    name:UIApplicationDidBecomeActiveNotification
        //                                                  object:nil];
        //
        //        self.assetsLibrary = [self defaultAssetsLibrary];
        //        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        //            if (group) {
        //                [_arrayGroups addObject:group];
        //            }
        //
        //        } failureBlock:^(NSError *error) {
        //        }];
        //
        //        [[NSNotificationCenter defaultCenter] addObserver:self
        //                                                 selector:@selector(assetsLibraryChangedNotification:)
        //                                                     name: ALAssetsLibraryChangedNotification
        //                                                   object:nil];
    }

    return self;
}

- (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}


#pragma mark - NSNotificationCenter
- (void)becomeActiveNotification
{
    if ([_arrayAssetsLibraryChanged count] > 0) {
        for (TSAssetsGroupObject *object in _arrayAssetsLibraryChanged) {
            NSString *strFilePath = [AUSerialization getFilePhoto];
            strFilePath = [NSString stringWithFormat:@"%@/%@",strFilePath,object.strTitle];
            dispatch_async(dispatch_get_main_queue(), ^{
                if([[NSFileManager defaultManager] fileExistsAtPath:strFilePath])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:strFilePath error:nil];
                }
            });
        }
        _arrayPhoto = _arrayAssetsLibraryChanged;
        [self arrayFileManage];
    }
}

- (void)assetsLibraryChangedNotification:(NSNotification *)notif
{
    if ([notif userInfo] && [notif.userInfo count] > 0) {
        NSSet *insertedGroupURLs = [[notif userInfo] objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
        NSURL *assetURL = [insertedGroupURLs anyObject];
        if (assetURL) {
            __strong __block AUGlobal *globle = self;
            if (!globle.arrayAssetsLibraryChanged) {
                globle.arrayAssetsLibraryChanged = [[NSMutableArray alloc]init];
            }
            [self.assetsLibrary groupForURL:assetURL resultBlock:^(ALAssetsGroup *group) {
                ALAssetsGroup *assetsGroup = group;
                NSString *strFilePath = [AUSerialization getFilePhoto];
                strFilePath = [NSString stringWithFormat:@"%@/%@",strFilePath,[assetsGroup valueForProperty:ALAssetsGroupPropertyName]];

                dispatch_async(dispatch_get_main_queue(), ^{
                    if([[NSFileManager defaultManager] fileExistsAtPath:strFilePath])
                    {
                        TSAssetsGroupObject *assetsGroupObject = [[TSAssetsGroupObject alloc]init];
                        assetsGroupObject.strTitle = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
                        assetsGroupObject.strNumber = [NSString stringWithFormat:@"%ld", (long)assetsGroup.numberOfAssets];
                        assetsGroupObject.isChoose = enum_isChoose;
                        assetsGroupObject.assetsGroup = group;
                        BOOL isb = YES;
                        for (TSAssetsGroupObject *object in globle.arrayAssetsLibraryChanged) {
                            if ([object.strTitle isEqualToString:assetsGroupObject.strTitle]) {
                                isb = NO;
                            }
                        }
                        if (isb) {
                            [globle.arrayAssetsLibraryChanged addObject:assetsGroupObject];
                        }
                    }
                });
            } failureBlock:^(NSError *error) {

            }];
        }
    }
}

#pragma mark - MedaiaManage
//主要管理所选的写入文件
- (void)makeMedaiaManage
{
    self.isOperatingState = NO;

    if ([_arrayMedia count] == 0) {
        NSLog(@"完成所有媒体导入！！！！");
        // YJX_TODO Crash
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_completionBlock) {
                _completionBlock();
            }
            [self loadDocmentItmes];
            [self withExportViewHidden];
            _exportSession = nil;
            self.isOperatingState = YES;
        });

        return;
    }
    //_arrayMedia数组里面用完一个对象就删除一个对象，直到没有对象了返回
    id objc = _arrayMedia[0];
    if ([objc isKindOfClass:[AssetItem class]]) {
        [self initMediaExportView:objc outputFileType:enum_Video];
    } else if([objc isKindOfClass:[TSMusicObject class]]) {
        [self initMediaExportView:objc outputFileType:enum_Music];
    } else {
        [self initMediaExportView:objc outputFileType:enum_Photo];
    }
}

//检测图片的选择和未选择
- (void)arrayFileManage
{
    _contentNumbuer =  0;
    _progressNumber = 0;
    [self.removeMetadataItems removeAllObjects];
    [self.addMetadataItems removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *strFilePath = [AUSerialization getFilePhoto];
        NSArray *arrayGroups = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];
        //    __block NSInteger index = 0;
        //            AUAlertHUDProcessing(@"正在准备");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *view = self.contentView;
            if (!view) {
                view =  [JXUtil getCurrentRootViewController].view;
            }
            [MBProgressHUD showHUDAddedTo:view animated:YES];
        });

        for (TSAssetsGroupObject *assetsGroupObject in _arrayPhoto) {
            BOOL b = YES;

            for (NSString *strGroupName  in arrayGroups) {
                NSArray *arrayImages = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",strFilePath,strGroupName] error:nil];
                if ([assetsGroupObject.strTitle isEqualToString:strGroupName] && [arrayImages count] > 0) {
                    b = NO;
                    break;
                }
            }

            //没有选在的情况下删除沙盒对应路径下面的文件
            if ( assetsGroupObject.isChoose == enum_notChoose) {
                NSString *groupPath = [NSString stringWithFormat:@"%@/%@",strFilePath,assetsGroupObject.strTitle];
                NSArray *arrayImages = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:groupPath error:nil];
                for (NSString *strName  in arrayImages) {
                    AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
                    NSString *strKey = [NSString stringWithFormat:@"%@_%@",assetsGroupObject.strTitle,strName];
                    NSString *strID = _dic_FileId[strKey];
                    if (!strID) {
                        @synchronized(_syncObj) {
                            strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
                            [_dic_FileId setObject:strID forKey:strKey];
                        }
                    }
                    metadataItem.identifier = strID;
                    metadataItem.type = AUMetadataItemTypePhoto;
                    metadataItem.path = [NSString stringWithFormat:@"%@/%@",assetsGroupObject.strTitle,strName];
                    [self.removeMetadataItems addObject:metadataItem];
                }
                NSError *error;
                NSFileManager *fileManager = [[NSFileManager alloc]init];
                [fileManager removeItemAtPath:groupPath error:&error];
            }
            //检测到有选择 添加到 _arrayMedia 数组里面
            if (b && assetsGroupObject.isChoose == enum_isChoose) {

                [_arrayMedia addObject:assetsGroupObject];
                _contentNumbuer = _contentNumbuer + [assetsGroupObject.arrayAssect count];

            }
        }
        [self arrarFileVideoManage];
    });

}
//检测视频的选择和未选择
- (void)arrarFileVideoManage
{
    [_arrayAssetsLibraryChanged removeAllObjects];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = self.contentView;
        if (!view) {
            view =  [JXUtil getCurrentRootViewController].view;
        }
        [MBProgressHUD hideHUDForView:view animated:YES];
    });
    //如果视频没有就直接进入音乐文件检测
    if ([_arrayVideo count] == 0) {
        [self arrayFileMusicManage];
        return;
    }
    NSString *strFilePath = [AUSerialization getFileVideo];
    NSArray *arrayVideos = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];
    __block NSInteger index = 0;
    for (AssetItem *assetsItem in _arrayVideo) {
        BOOL b = YES;
        NSString *name = assetsItem.title;
        NSURL *url = assetsItem.assetURL;
        for (NSString *videoName  in arrayVideos) {
            NSURL *myURL = [gURLDict objectForKey:videoName];
            if ([url isEqual:myURL]) {
                b = NO;
                break;
            }
        }

        if ( assetsItem.isChoose == enum_notChoose && !b) {
            NSString *groupPath = [NSString stringWithFormat:@"%@/%@",strFilePath,name];

            AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
            NSString *strKey = [NSString stringWithFormat:@"%@",name];
            NSString *strID = _dic_FileId[strKey];
            if (!strID) {
                @synchronized(_syncObj) {
                    strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
                    [_dic_FileId setObject:strID forKey:strKey];
                }
            }
            metadataItem.identifier = strID;
            metadataItem.type = AUMetadataItemTypeVideo;
            metadataItem.path = [NSString stringWithFormat:@"%@",name];
            [self.removeMetadataItems addObject:metadataItem];

            NSError *error;
            DDLogInfo(@"删除本地视频文件：%@", groupPath);
            [[NSFileManager defaultManager] removeItemAtPath:groupPath error:&error];

        }
        if (b && assetsItem.isChoose == enum_isChoose) {
            [_arrayMedia addObject:assetsItem];
            _contentNumbuer ++;
        } else {
            ++index;
        }

    }
    [self arrayFileMusicManage];
}

//检测音乐的选择和未选择
- (void)arrayFileMusicManage
{

    NSString *strFilePath = [AUSerialization getFileMusic];
    NSArray *arrayMusics = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];
    __block NSInteger index = 0;
    for (TSMusicObject *assetsObject in _arrayMusic) {
        BOOL b = YES;

        for (NSString *videoName  in arrayMusics) {
            NSRange range = [videoName rangeOfString:assetsObject.strMusicName];
            if (range.length > 0)
            {
                b = NO;
                break;
            }
        }

        if ( assetsObject.isChoose == enum_notChoose && !b) {
            NSString *groupPath = [NSString stringWithFormat:@"%@/%@.wav",strFilePath,assetsObject.strMusicName];

            AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
            NSString *strKey = [NSString stringWithFormat:@"%@.wav",assetsObject.strMusicName];
            NSString *strID = _dic_FileId[strKey];
            if (!strID) {
                @synchronized(_syncObj) {
                    strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
                    [_dic_FileId setObject:strID forKey:strKey];
                }
            }
            metadataItem.identifier = strID;
            metadataItem.type = AUMetadataItemTypeMusic;
            metadataItem.path = [NSString stringWithFormat:@"%@.wav",assetsObject.strMusicName];
            [self.removeMetadataItems addObject:metadataItem];

            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:groupPath error:&error];
        }

        if (b && assetsObject.isChoose == enum_isChoose) {
            [_arrayMedia addObject:assetsObject];
            _contentNumbuer ++;
        } else {
            ++index;
        }

    }
    //照片，视频，音乐都检测完了 ，进去进行文件写入
    [self makeMedaiaManage];

}

- (void)setIsConnectionStatus:(BOOL)isConnectionStatus
{
    _isConnectionStatus = isConnectionStatus;
    if (!_isConnectionStatus && _exportSession) {
        [_exportSession cancelExport];
    }
}
#pragma mark  - loadDocment
//获取沙盒下面的所有媒体文件
- (void)loadDocmentItmes
{
    if (self.isConnectionInit) {
        _lodingIndex = 0;

        if (self.metadataItems == nil) {
            self.metadataItems = [[NSMutableArray alloc]init];
        }
        [self.metadataItems removeAllObjects];

        NSString *strFilePath = [AUSerialization getFilePhoto];
        NSArray *arrayGroups = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];

        if (arrayGroups) {
            for (NSString *groupName in arrayGroups)
            {
                NSArray *arrayImages = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",strFilePath,groupName] error:nil];
                if ([arrayImages count] > 0) {
                    for (NSString *iamgeName in arrayImages) {

                        NSString *srtUrl = [[NSUserDefaults standardUserDefaults]objectForKey:iamgeName];
                        if (!srtUrl) {
                            continue;
                        }

                        AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
                        NSString *strKey = [NSString stringWithFormat:@"%@_%@",groupName,iamgeName];
                        NSString *strID = _dic_FileId[strKey];
                        if (!strID) {
                            @synchronized(_syncObj) {
                                strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
                                [_dic_FileId setObject:strID forKey:strKey];
                            }
                        }
                        metadataItem.identifier = strID;
                        metadataItem.type = AUMetadataItemTypePhoto;
                        metadataItem.path = [NSString stringWithFormat:@"%@/%@",groupName,iamgeName];
                        metadataItem.lengthBytes = [[[NSUserDefaults standardUserDefaults] objectForKey:[iamgeName stringByAppendingString:@"length"]] unsignedIntegerValue];

                        [self.metadataItems addObject:metadataItem];
                    }
                }
            }
        }
        [self loadMediaItems];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.removeMetadataItems count] > 0) {
                [[NSNotificationCenter defaultCenter]postNotificationName:kMetaItmesRemoveNotification object:nil];
            }
            if ([self.addMetadataItems count] > 0) {
                [[NSNotificationCenter defaultCenter]postNotificationName:kMetaItmesAddNotification object:nil];
            }
        });
    }
    @synchronized(self) {
        gMediaArrangeFinished = YES;
    }
}
- (void)loadMediaItems
{
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *strVideoFilePath = [AUSerialization getFileVideo];
    NSArray *arrayVideos = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strVideoFilePath error:nil];
    for (NSString *videoName in arrayVideos) {
        AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
        NSString *strID = _dic_FileId[videoName];
        if (!strID) {
            @synchronized(_syncObj) {
                strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
                [_dic_FileId setObject:strID forKey:videoName];
            }
        }
        metadataItem.identifier = strID;
        metadataItem.type = AUMetadataItemTypeVideo;
        metadataItem.path = [NSString stringWithFormat:@"%@",videoName];
        NSString *strVideoPath = [strVideoFilePath stringByAppendingFormat:@"/%@",videoName];
        NSFileManager *fm  = [NSFileManager defaultManager];
        NSError *error = nil;
        NSDictionary* dictFile = [fm attributesOfItemAtPath:strVideoPath error:&error];
        if (!error) {
            metadataItem.lengthBytes = (unsigned long)[dictFile fileSize];
        }else {
            DDLogWarn(@"获取视频大小失败: %@", error);
        }
        [self.metadataItems addObject:metadataItem];
    }

    NSString *strMusicFilePath = [AUSerialization getFileMusic];
    NSArray *arrayMusics = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strMusicFilePath error:nil];
    for (NSString *musicName in arrayMusics) {
        AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
        NSString *strID = _dic_FileId[musicName];
        if (!strID) {
            @synchronized(_syncObj) {
                strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
                [_dic_FileId setObject:strID forKey:musicName];
            }
        }
        metadataItem.identifier = strID;

        //        metadataItem.identifier = [NSString stringWithFormat:@"%ld",(long)++startIndex];;
        metadataItem.type = AUMetadataItemTypeMusic;
        metadataItem.path = [NSString stringWithFormat:@"%@",musicName];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *strInfo = [defaults objectForKey:musicName];
        NSArray *arrayInfo = [strInfo componentsSeparatedByString:@"__"];
        metadataItem.albumTitle = [arrayInfo firstObject];
        metadataItem.artist =  [arrayInfo lastObject];
        //if (JXiOSVersionGreaterThanOrEqual(7.0)) {
        NSString *strMusicPath = [strMusicFilePath stringByAppendingFormat:@"/%@",musicName];
        NSFileManager *fm  = [NSFileManager defaultManager];
        NSError *error = nil;
        NSDictionary* dictFile = [fm attributesOfItemAtPath:strMusicPath error:&error];
        if (!error) {
            metadataItem.lengthBytes = (unsigned long)[dictFile fileSize];
        }else {
            DDLogWarn(@"获取音乐大小失败: %@", error);
        }
        //}
        [self.metadataItems addObject:metadataItem];
    }

    if ([self.metadataItems count] > 0) {
        DDLogInfo(@"_dic_FileId = %@", _dic_FileId); // 加上这个
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:kMetaItmesSuccessNotification object:nil];
        });
    }
    //});
}

//操作文件的写入
- (void)initMediaExportView:(id)object outputFileType:(k_enum_fileType)fileType
{
    //@autoreleasepool {

    //    NSTimeInterval seconds = 0.5;
    NSURL *outputURL = nil;
    NSURL *mediaURL = nil;
    NSString *name = nil;
    NSString *strFilePath = nil;
    NSString *imageCoverPath = nil;
    NSString *strCoverPath = [AUSerialization getFileNormal];
    //写视频封面照片
    if (fileType == enum_Video) {
        AssetItem *assetItem = object;
        mediaURL = assetItem.assetURL;

        NSString *strType = [[[[[[[mediaURL absoluteString] componentsSeparatedByString:@"?"] firstObject] componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] lastObject];
        name = assetItem.title;
        if (![name hasSuffix:strType]) {
            name = [name stringByAppendingFormat:@".%@",strType];
        }

        strFilePath = [NSString stringWithFormat:@"%@/%@",[AUSerialization getFileVideo],name];
        outputURL = [NSURL fileURLWithPath:strFilePath];
        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:mediaURL options:nil];

        imageCoverPath = [strCoverPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",name]];
        if (!assetItem.thumbnail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [assetItem loadThumbnailWithCompletionHandler:^{
                    dispatch_async(dispatch_get_main_queue(), ^{

                        if(![[NSFileManager defaultManager] fileExistsAtPath:imageCoverPath])
                        {
                            @autoreleasepool {
                                NSData *imageData = UIImagePNGRepresentation(assetItem.thumbnail);
                                [imageData writeToFile:imageCoverPath atomically:YES];
                                imageData = nil;
                            }
                        }
                    });
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(![[NSFileManager defaultManager] fileExistsAtPath:imageCoverPath])
                {
                    @autoreleasepool {
                        NSData *imageData = UIImagePNGRepresentation(assetItem.thumbnail);
                        [imageData writeToFile:imageCoverPath atomically:YES];
                        imageData = nil;
                    }
                }
            });
        }

        NSRange range = [name rangeOfString:@"3gp"];
        if (range.length > 0) {
            _exportSession = [[AVAssetExportSession alloc]initWithAsset:videoAsset
                                                             presetName:AVAssetExportPresetPassthrough];
        } else {
            _exportSession = [[AVAssetExportSession alloc]initWithAsset:videoAsset
                                                             presetName:AVAssetExportPresetHighestQuality];
        }

        //写音乐封面照片
    }
    else if (fileType == enum_Music) {
        TSMusicObject *musicObject = object;
        mediaURL = musicObject.strmusicUrl;
        name = [NSString stringWithFormat:@"%@.%@",musicObject.strMusicName,@"wav"];
        strFilePath = [NSString stringWithFormat:@"%@/%@",[AUSerialization getFileMusic],name];
        outputURL = [NSURL fileURLWithPath:strFilePath];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSString stringWithFormat:@"%@__%@",musicObject.albumTitle,musicObject.artist]
                     forKey:name];
        [defaults synchronize];

        imageCoverPath = [strCoverPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",name]];
        UIImage *artworkImage = [ musicObject.mediaItme imageWithSize: CGSizeMake(74 ,74)];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(![[NSFileManager defaultManager] fileExistsAtPath:imageCoverPath])
            {
                @autoreleasepool {
                    NSData *imageData = UIImagePNGRepresentation(artworkImage);
                    [imageData writeToFile:imageCoverPath atomically:YES];
                    imageData = nil;
                }
            }
        });


        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:mediaURL options:nil];
        _exportSession = [[AVAssetExportSession alloc]initWithAsset:videoAsset
                                                         presetName:AVAssetExportPresetPassthrough];
    }

    //如果沙盒里面本身存在要写入的这个文件，就停止写入进行下一条数据对比
    if ([[NSFileManager defaultManager] fileExistsAtPath:strFilePath]) {
        [_arrayMedia removeObject:object];
        [self makeMedaiaManage];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        //进度条
        if (!_exportView) {
            UIView *view =  [[UIApplication sharedApplication].delegate window];
            _exportView = [[UIView alloc] initWithFrame:view.frame];
            [_exportView setBackgroundColor:[UIColor clearColor]];
            [view addSubview:_exportView];
            _exportView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];

            _exprotProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 300, [[UIScreen mainScreen] bounds].size.width - 20, 31)];
            [_exportView addSubview:_exprotProgressView];

            _exportStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 260, [[UIScreen mainScreen] bounds].size.width - 20, 31)];
            //        _exportStateLabel.text = kStringPreparingAndWaiting;
            _exportStateLabel.textColor = [UIColor whiteColor];
            [_exportStateLabel setBackgroundColor:[UIColor clearColor]];
            [_exportView addSubview:_exportStateLabel];
            _exportView.alpha = 0.00;
            [UIView animateWithDuration:0.3 animations:^{
                _exportView.alpha = 1.0f;
            }];
            _exportView.hidden = NO;
            _exprotProgressView.progress = 0.01;
            dispatch_async(dispatch_get_main_queue(), ^{
                _exportStateLabel.text = kStringMediaArraging;
            });
        }
    });

    //照片文件的写入
    if (fileType == enum_Photo) {
        TSAssetsGroupObject *assetsGroup = object;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (ALAsset *result in assetsGroup.arrayAssect) {
                NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url

                NSRange range1=[urlstr rangeOfString:@"id="];
                NSString *resultName=[urlstr substringFromIndex:range1.location+3];
                resultName=[resultName stringByReplacingOccurrencesOfString:@"&ext=" withString:@"."];//格式demo:123456.png

                [[NSUserDefaults standardUserDefaults] setObject:urlstr forKey:resultName];

                //写入到本地沙盒的图片
                UIImage *image  = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                if (!image) {
                    //取原图
                    image = [UIImage imageWithCGImage:result.defaultRepresentation.fullResolutionImage];
                }
                //计算图片大小
                NSUInteger lengthBytes;
                @autoreleasepool {
                    UIImage *fullResolutionImage ;
                    fullResolutionImage = [UIImage imageWithCGImage:result.defaultRepresentation.fullResolutionImage];
                    if (!fullResolutionImage) {
                        DDLogWarn(@"获取原图失败！！！！bbbbb");
                        fullResolutionImage = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                    }
                    NSData *data = UIImageJPEGRepresentation(fullResolutionImage, 1);
                    lengthBytes = data.length;

                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:lengthBytes] forKey:[resultName stringByAppendingString:@"length"]];
                    data = nil;
                    fullResolutionImage = nil;
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
                //                JXDimension *dimension = [JXDimension currentDimension];
                //                if ([[[UIDevice currentDevice] systemVersion] floatValue] < (7.0) && dimension.screenResolution == JXDimensionScreenResolution640x960) {
                //                    image = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                //                } else {
                //                    image = [UIImage imageWithCGImage:result.defaultRepresentation.fullResolutionImage];
                ////                    image = [self imageWithImage:image scaledToSize:CGSizeMake(image.size.width / 2, image.size.height / 2)];
                //                    scaleToSize = [image scaleToSize:CGSizeMake(image.size.width / 3, image.size.height / 3)];
                //
                ////                    image = [self transformSize:CGSizeMake(image.size.width / 2, image.size.height / 2) image:image];
                //                }

                AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
                NSString *strKey = [NSString stringWithFormat:@"%@_%@",assetsGroup.strTitle,resultName];
                NSString *strID = _dic_FileId[strKey];
                if (!strID) {
                    @synchronized(_syncObj) {
                        strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
                        [_dic_FileId setObject:strID forKey:strKey];
                    }
                }
                metadataItem.identifier = strID;
                metadataItem.type = AUMetadataItemTypePhoto;
                metadataItem.path = [NSString stringWithFormat:@"%@/%@",assetsGroup.strTitle,resultName];
                metadataItem.lengthBytes = lengthBytes;
                [self.addMetadataItems addObject:metadataItem];

                NSString *strFilePath = [AUSerialization getFilePhoto];
                strFilePath = [NSString stringWithFormat:@"%@/%@",strFilePath,assetsGroup.strTitle];
                if (![[NSFileManager defaultManager] fileExistsAtPath:strFilePath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:strFilePath withIntermediateDirectories:YES attributes:nil error:nil];
                }
                NSString *imagePath = [strFilePath stringByAppendingPathComponent:resultName];

                [self setProgress];

                @autoreleasepool {
                    NSData *imageData = UIImagePNGRepresentation(image);
                    if(![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
                    {
                        [imageData writeToFile:imagePath atomically:YES];
                    }
                    imageData = nil;
                }

                if (!_isConnectionStatus) {
                    [_arrayMedia removeAllObjects];
                    [self makeMedaiaManage];
                    break;
                }

            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_arrayMedia removeObject:object];
                [self makeMedaiaManage];
            });
        });
    }
    else {
        //音乐和视频文件的写入
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:kMediaFilePath];
        [userDefaults setObject:strFilePath forKey:kMediaFilePath];
        [userDefaults synchronize];

        _exportSession.outputURL = outputURL;
        _exportSession.shouldOptimizeForNetworkUse = NO;

        NSString *mediaDirectory;
        if (fileType == enum_Video){
            mediaDirectory = [AUSerialization getFileVideo];
            if ([_exportSession.presetName isEqualToString:AVAssetExportPresetPassthrough])
                _exportSession.outputFileType = AVFileType3GPP;
            else
                _exportSession.outputFileType = AVFileTypeMPEG4;

        } else {
            mediaDirectory = [AUSerialization getFileMusic];
            _exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        }
        __weak AUGlobal* weakSelf = self;
        NSArray *preMedias = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:mediaDirectory error:nil];
        [_exportSession exportAsynchronouslyWithCompletionHandler:^{
            [_arrayMedia removeObject:object];
            switch ([_exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf setProgress];
                        [weakSelf removeMovie];
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:[NSString stringWithFormat:@"%@ %@",name,[[_exportSession error] localizedDescription]]
                                                                       delegate:weakSelf
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles: nil];
                        [alert show];

                    });

                    break;
                }
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    [weakSelf setProgress];
                    [weakSelf removeMovie];
                    if (!_isConnectionStatus) {
                        [_arrayMedia removeAllObjects];
                        [self makeMedaiaManage];
                    }
                    //                [weakSelf withExportViewHidden];
                    _exportSession = nil;
                    break;
                case AVAssetExportSessionStatusCompleted: {
                    NSArray *currentMedias = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:mediaDirectory error:nil];
                    NSMutableArray *mCurrentMedias = [NSMutableArray arrayWithArray:currentMedias];
                    [mCurrentMedias removeObjectsInArray:preMedias];
                    if (mCurrentMedias.count == 1) {
                        [gNameDict setObject:mCurrentMedias[0] forKey:mediaURL];
                        [gURLDict setObject:mediaURL forKey:mCurrentMedias[0]];
                    }
                }
                    [self addMediaForName:name type:fileType];
                    [weakSelf setProgress];
                    [self makeMedaiaManage];
                    NSLog(@"Successful!");
                    break;
                default:
                    break;
            }
        }];
    }
    //}
}

//音乐和视频添加
- (void)addMediaForName:(NSString *)mediaName type:(k_enum_fileType)fileType
{

    AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
    NSString *strKey = [NSString stringWithFormat:@"%@",mediaName];
    NSString *strID = _dic_FileId[strKey];
    if (!strID) {
        @synchronized(_syncObj) {
            strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
            [_dic_FileId setObject:strID forKey:strKey];
        }
    }
    metadataItem.identifier = strID;
    NSString *strFilePath;
    if (fileType == enum_Video) {
        metadataItem.type = AUMetadataItemTypeVideo;
        strFilePath = [AUSerialization getFileVideo];
    } else {
        metadataItem.type = AUMetadataItemTypeMusic;
        strFilePath = [AUSerialization getFileMusic];
    }

    metadataItem.path = [NSString stringWithFormat:@"%@",mediaName];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strInfo = [defaults objectForKey:strKey];
    NSArray *arrayInfo = [strInfo componentsSeparatedByString:@"__"];
    metadataItem.albumTitle = [arrayInfo firstObject];
    metadataItem.artist =  [arrayInfo lastObject];

    NSString *strPath = [strFilePath stringByAppendingFormat:@"/%@",strKey];
    NSFileManager *fm  = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary* dictFile = [fm attributesOfItemAtPath:strPath error:&error];
    if (!error) {
        metadataItem.lengthBytes = (unsigned long)[dictFile fileSize];
    }else {
        DDLogWarn(@"获取视频/音乐大小失败：strPath = %@, error = %@", strPath, error);
    }

    [self.addMetadataItems addObject:metadataItem];
}

- (void)setProgress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressNumber  = _progressNumber + 1.;
        double progress  = _progressNumber / _contentNumbuer;
        NSString *strProgress = [NSString stringWithFormat:@"%.1f",progress * 100];
        _exportStateLabel.text = [NSString stringWithFormat:@"%@       %@%%", kStringMediaArraging, strProgress];
        _exprotProgressView.progress = _progressNumber / _contentNumbuer;
    });
}

- (void)addMediaVideoIsPathName:(NSString *)strPathName
{

    AUMetadataItem *mItem = [[AUMetadataItem alloc] init];
    mItem.identifier = [NSString stringWithFormat:@"%ld",(long)([self.metadataItems count] + kIndex + 1)];
    if ([[[strPathName componentsSeparatedByString:@"."] lastObject] isEqualToString:@"wav"]) {
        mItem.type = AUMetadataItemTypeMusic;
    } else {
        mItem.type = AUMetadataItemTypeVideo;
    }
    mItem.path = [NSString stringWithFormat:@"%@",strPathName];
    [self.metadataItems addObject:mItem];
}

// Update the export UI depending on the status of the current export
- (void)updateProgress:(NSTimer *)timer
{
    AVAssetExportSession *exportSession = [timer userInfo];
    BOOL finishedExport = [self finishedExport:exportSession];
    _exprotProgressView.progress = exportSession.progress;
    if (finishedExport)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMediaFilePath];

    }
}

- (void)withExportViewHidden
{
    if ([_arrayMedia count] == 0) {
        if (_exportView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAvAssetTimer];
                [UIView animateWithDuration:0.3 animations:^{
                    NSLog(@"_exportView   --  %@",_exportView);
                    _exportView.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    _exportView.hidden = YES;
                    _exportView = nil;
                }];
            });
        }
    }
}

- (BOOL)finishedExport:(AVAssetExportSession *)exportSession
{
    BOOL finishedExport = NO;
    AVAssetExportSessionStatus status = exportSession.status;

    if (status == AVAssetExportSessionStatusCompleted)
        finishedExport = YES;

    return finishedExport;
}

- (void)stopAvAssetTimer
{
    if (_exportTimer) {
        [_exportTimer invalidate];
        _exportTimer = nil;
    }
}

- (void)removeMovie
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *filePath = [[NSUserDefaults standardUserDefaults]objectForKey:kMediaFilePath];
        NSFileManager *defaultManager;

        defaultManager = [NSFileManager defaultManager];
        NSError *error;
        if ([defaultManager removeItemAtPath:filePath error:&error] != YES)
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    });

}

- (NSString *)getAssetPathName:(NSURL *)assetURL
{
    NSString *urlstr=[NSString stringWithFormat:@"%@",[[assetURL absoluteString] lastPathComponent]];
    NSRange range1=[urlstr rangeOfString:@"id="];
    NSString *resultName=[urlstr substringFromIndex:range1.location+3];
    resultName=[resultName stringByReplacingOccurrencesOfString:@"&ext=" withString:@"."];
    return resultName;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self makeMedaiaManage];
}


//共享目录按返回操作的方法
- (void)makeArrayPhoto:(NSMutableArray *)arrayPhoto arrayVideo:(NSMutableArray *)arrayVideo  arrayMusic:(NSMutableArray *)arrayMusic completion:(void (^)(void))completion
{

    [self.removeMetadataItems removeAllObjects];
    [self.addMetadataItems removeAllObjects];
    BOOL bFile = YES;
    NSString *strFilePath = [AUSerialization getFilePhoto];
    NSArray *arrayGroups = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];
    for (NSString *groupName in arrayGroups) {
        NSArray *arrayImages = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",strFilePath,groupName] error:nil];
        if ([arrayImages count] > 0) {
            bFile = NO;
            break;
        }
    }
    if (bFile) {
        NSString *strVideoFilePath = [AUSerialization getFileVideo];
        NSArray *arrayVideos = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strVideoFilePath error:nil];
        if ([arrayVideos count] > 0) {
            bFile = NO;
        }

    }
    if (bFile) {
        NSString *strMusicFilePath = [AUSerialization getFileMusic];
        NSArray *arrayMusics = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strMusicFilePath error:nil];
        if ([arrayMusics count] > 0) {
            bFile = NO;
        }
    }
    self.isConnectionInit = bFile;
    _arrayPhoto = arrayPhoto;
    _arrayVideo = arrayVideo;
    _arrayMusic = arrayMusic;
    _completionBlock = completion;

    if (self.isOperatingState) {
        self.isOperatingState = NO;
        [self arrayFileManage];
    } else {
        AUAlertHUDTips(@"本次设置失效，操作过于频繁");
    }
}

#pragma mark - checkMedia

//程序进入后台在进入前台检测系统资源中是否有添加和删除文件
- (void)checkMedia
{
    @synchronized(self) {
        gMediaArrangeFinished = NO;
    }
    if (self.isOperatingState) {
        _lodingIndex = 0;
        [self.removeMetadataItems removeAllObjects];
        [self.addMetadataItems removeAllObjects];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.isConnectionInit = NO;
            [self checkImages];
            [self checkVideo];
            [self checkMusic];
        });
    }
}

-(void)checkImages
{
    //    dispatch_async(dispatch_get_main_queue(), ^{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
            NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
            if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
            }else{
                NSLog(@"相册访问失败.");
            }
        };

        NSString *strFilePath = [AUSerialization getFilePhoto];
        NSArray *arrayGroups = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];
        __block AUGlobal *global = self;
        __block NSMutableArray *arrayALAssetsGroup = [[NSMutableArray alloc]init];
        ALAssetsLibraryGroupsEnumerationResultsBlock
        libraryGroupsEnumeration = ^(ALAssetsGroup* group,BOOL* stop) {
            if (group) {
                ALAssetsGroup *assetsGroup = group;

                if ([assetsGroup numberOfAssets] >= 0) {

                    NSString *strGroupName = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];

                    NSString *sFilePath = [NSString stringWithFormat:@"%@/%@",strFilePath,strGroupName];
                    NSArray *arrayImages = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:sFilePath error:nil];

                    if ([arrayGroups containsObject:strGroupName] && [arrayImages count] > 0) {
                        [_arrayContainsGroup addObject:group];
                    }
                }
                [arrayALAssetsGroup addObject:[assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
            } else {

                for (int i = 0 ; i < [arrayGroups count] ; i++ ) {
                    NSString *strMediaName = arrayGroups[i];
                    if (![arrayALAssetsGroup containsObject:strMediaName]) {

                        NSString *strPath = [NSString stringWithFormat:@"%@/%@",strFilePath,strMediaName];
                        NSArray *arrayImages = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strPath error:nil];
                        for (NSString *strName  in arrayImages) {
                            AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
                            NSString *strKey = [NSString stringWithFormat:@"%@_%@",strMediaName,strName];
                            NSString *strID = _dic_FileId[strKey];
                            if (!strID) {
                                @synchronized(_syncObj) {
                                    strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
                                    [_dic_FileId setObject:strID forKey:strKey];
                                }
                            }
                            metadataItem.identifier = strID;
                            metadataItem.type = AUMetadataItemTypePhoto;
                            metadataItem.path = [NSString stringWithFormat:@"%@/%@",strMediaName,strName];
                            [self.removeMetadataItems addObject:metadataItem];
                        }
                        NSString *path = [strFilePath stringByAppendingPathComponent:strMediaName];
                        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    }
                }
                arrayALAssetsGroup = nil;
                if ([_arrayContainsGroup count] > 0) {
                    ALAssetsGroup *aGroup = _arrayContainsGroup[0];
                    [global enumerateAssetsUsingBlock:aGroup];
                }else {
                    _lodingIndex ++;
                    NSLog(@"_lodingIndex  --checkImages  %ld",(long)_lodingIndex);
                    if (_lodingIndex == 3) {
                        [gAU loadDocmentItmes];
                    }

                    //                    @synchronized(self) {
                    //                        gMediaArrangeProgress++;
                    //                        if (3 == gMediaArrangeProgress) {
                    //                            gMediaArrangeProgress = YES;
                    //                        }
                    //                    }
                }
            }
        };

        if (!self.assetsLibrary)
            self.assetsLibrary = [gAU defaultAssetsLibrary];
        [ self.assetsLibrary enumerateGroupsWithTypes:(ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos)
                                           usingBlock:libraryGroupsEnumeration
                                         failureBlock:failureblock];
    });
}

- (void)enumerateAssetsUsingBlock:(ALAssetsGroup *)aGroup
{
    __block AUGlobal *global = self;
    [_arrayImageName removeAllObjects];
    _arrayImageName = [[NSMutableArray alloc]init];
    [aGroup enumerateAssetsUsingBlock:^(ALAsset *result,NSUInteger index, BOOL *stop){
        if (result) {
            if ([[result valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypePhoto]) {
                NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url
                NSRange range1=[urlstr rangeOfString:@"id="];
                NSString *resultName=[urlstr substringFromIndex:range1.location+3];
                resultName=[resultName stringByReplacingOccurrencesOfString:@"&ext=" withString:@"."];//格式demo:123456.png
                NSString *strFilePath = [AUSerialization getFilePhoto];
                NSString *strGroupName = [aGroup valueForProperty:ALAssetsGroupPropertyName];
                strFilePath = [NSString stringWithFormat:@"%@/%@",strFilePath,strGroupName];
                NSArray *arrayImages = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];

                if (![arrayImages containsObject:resultName]) {

                    //                    UIImage *image = nil;
                    if (![[NSFileManager defaultManager] fileExistsAtPath:strFilePath]) {
                        [[NSFileManager defaultManager] createDirectoryAtPath:strFilePath withIntermediateDirectories:YES attributes:nil error:nil];
                    }

                    //                    JXDimension *dimension = [JXDimension currentDimension];
                    //                    if ([[[UIDevice currentDevice] systemVersion] floatValue] < (7.0) && dimension.screenResolution == JXDimensionScreenResolution640x960) {
                    //                        image = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                    //                    } else {
                    //                        image = [UIImage imageWithCGImage:result.defaultRepresentation.fullResolutionImage];
                    //                        image = [[AUPhotoAlbum sharedPhotoAlbum] transformSize:CGSizeMake(image.size.width / 2, image.size.height / 2) image:image];
                    //                    }

                    //取写入到本地沙盒的图片
                    UIImage *image  = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                    if (!image) {
                        //取原图
                        image = [UIImage imageWithCGImage:result.defaultRepresentation.fullResolutionImage];
                    }

                    //计算图片大小
                    NSUInteger lengthBytes;
                    @autoreleasepool {
                        UIImage *fullResolutionImage ;
                        fullResolutionImage = [UIImage imageWithCGImage:result.defaultRepresentation.fullResolutionImage];
                        if (!fullResolutionImage) {
                            DDLogWarn(@"获取原图失败！！！！aaaaa");
                            fullResolutionImage = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                        }
                        NSData *data = UIImageJPEGRepresentation(fullResolutionImage, 1);
                        lengthBytes = data.length;
                        data = nil;
                        fullResolutionImage = nil;
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:lengthBytes] forKey:[resultName stringByAppendingString:@"length"]];
                    }


                    [[NSUserDefaults standardUserDefaults] setObject:urlstr forKey:resultName];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    NSString *imagePath = [strFilePath stringByAppendingPathComponent:resultName];
                    @autoreleasepool {
                        NSData *imageData = UIImagePNGRepresentation(image);
                        if(![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
                        {
                            [imageData writeToFile:imagePath atomically:YES];
                        }
                        imageData = nil;
                    }

                    AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
                    NSString *strKey = [NSString stringWithFormat:@"%@_%@",strGroupName,resultName];
                    NSString *strID = _dic_FileId[strKey];
                    if (!strID) {
                        @synchronized(_syncObj) {
                            strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
                            [_dic_FileId setObject:strID forKey:strKey];
                        }
                    }
                    metadataItem.identifier = strID;
                    metadataItem.type = AUMetadataItemTypePhoto;
                    metadataItem.path = [NSString stringWithFormat:@"%@/%@",strGroupName,resultName];
                    metadataItem.lengthBytes = lengthBytes;
                    [self.addMetadataItems addObject:metadataItem];

                }
                [_arrayImageName addObject:resultName];

            }
        } else {
            [_arrayContainsGroup removeObject:aGroup];
            NSString *strFilePath = [AUSerialization getFilePhoto];
            strFilePath = [NSString stringWithFormat:@"%@/%@",strFilePath,[aGroup valueForProperty:ALAssetsGroupPropertyName]];
            NSArray *arrayImages = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];
            for (int i = 0 ; i < [arrayImages  count] ; i++ ) {
                NSString *strImageName = arrayImages[i];
                //if ([_arrayImageName count] >= 0) {
                if (![_arrayImageName containsObject:strImageName]) {

                    AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
                    NSString *strKey = [NSString stringWithFormat:@"%@_%@",[aGroup valueForProperty:ALAssetsGroupPropertyName],strImageName];
                    NSString *strID = _dic_FileId[strKey];
                    if (!strID) {
                        @synchronized(_syncObj) {
                            strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
                            [_dic_FileId setObject:strID forKey:strKey];
                        }
                    }
                    metadataItem.identifier = strID;
                    metadataItem.type = AUMetadataItemTypePhoto;
                    metadataItem.path = [NSString stringWithFormat:@"%@/%@",[aGroup valueForProperty:ALAssetsGroupPropertyName],strImageName];
                    [self.removeMetadataItems addObject:metadataItem];

                    NSString *imagePath = [strFilePath stringByAppendingPathComponent:strImageName];
                    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
                }
                //}
                if (i == [arrayImages count] - 1) {
                    if ([_arrayContainsGroup count] > 0) {
                        ALAssetsGroup *aGroup = _arrayContainsGroup[0];
                        [_arrayImageName removeAllObjects];
                        [global enumerateAssetsUsingBlock:aGroup];
                    } else {
                        _lodingIndex ++;
                        NSLog(@"_lodingIndex  --enumerate  %ld",(long)_lodingIndex);
                        if (_lodingIndex == 3) {
                            [gAU loadDocmentItmes];
                        }
                    }
                }
            }
        }
    }];
}

- (void)checkVideo {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _videoLibrary = [[VideoLibrary alloc] initWithLibraryChangedHandler:^{
        } firstLoding:NO];
        [_videoLibrary loadLibraryWithCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *strFilePath = [AUSerialization getFileVideo];
                NSArray *arrayVideos = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];
                NSMutableArray *arrayMedia = [[NSMutableArray alloc]init];
                for (AssetItem *assetItem in _videoLibrary.assetItems) {
                    //[arrayMedia addObject:assetItem.title];
                    [arrayMedia addObject:assetItem.assetURL];
                }

                for (int i = 0 ; i < [arrayVideos count] ; i++ ) {
                    NSString *strMediaName = arrayVideos[i];

                    NSURL *myURL = [gURLDict objectForKey:strMediaName];
                    if (![arrayMedia containsObject:myURL]) {
                        AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
                        NSString *strKey = [NSString stringWithFormat:@"%@",strMediaName];
                        NSString *strID = _dic_FileId[strKey];
                        if (!strID) {
                            @synchronized(_syncObj) {
                                strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
                                [_dic_FileId setObject:strID forKey:strKey];
                            }
                        }
                        metadataItem.identifier = strID;
                        metadataItem.type = AUMetadataItemTypeVideo;
                        metadataItem.path = [NSString stringWithFormat:@"%@",strMediaName];
                        [self.removeMetadataItems addObject:metadataItem];

                        NSString *path = [strFilePath stringByAppendingPathComponent:strMediaName];
                        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    }
                }

                _lodingIndex ++;
                NSLog(@"_lodingIndex  --checkVideo  %ld",(long)_lodingIndex);
                if (_lodingIndex == 3) {
                    [gAU loadDocmentItmes];
                }

            });
        }];
    });
}

- (void)checkMusic {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPMediaQuery *listQuery = [MPMediaQuery songsQuery];
        NSArray *playlist = [listQuery collections];
        NSString *strFilePath = [AUSerialization getFileMusic];
        NSArray *arrayMusics = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];
        NSMutableArray *arrayMedia = [[NSMutableArray alloc]init];

        for (MPMediaPlaylist * list in playlist) {
            NSArray *songs = [list items];//歌曲数组
            for (int i = 0 ; i < [songs count] ; i++ ) {
                MPMediaItem *song = songs[i];
//                NSString *title =[song valueForProperty:MPMediaItemPropertyTitle];//歌曲名
//                NSString *stitle = [title stringByAppendingString:@".wav"];
                NSURL *url =[song valueForProperty:MPMediaItemPropertyAssetURL];//歌曲名
                [arrayMedia addObject:url];
            }
        }

        for (int i = 0 ; i < [arrayMusics count] ; i++ ) {
            NSString *strMediaName = arrayMusics[i];

            NSURL *myURL = [gURLDict objectForKey:strMediaName];
            if (![arrayMedia containsObject:myURL]) {
                NSString *path = [strFilePath stringByAppendingPathComponent:strMediaName];

                AUMetadataItem *metadataItem = [[AUMetadataItem alloc] init];
                NSString *strKey = [NSString stringWithFormat:@"%@",strMediaName];
                NSString *strID = _dic_FileId[strKey];
                if (!strID) {
                    @synchronized(_syncObj) {
                        strID = [NSString stringWithFormat:@"%ld",(long)++_startIndex];
                        [_dic_FileId setObject:strID forKey:strKey];
                    }
                }
                metadataItem.identifier = strID;
                metadataItem.type = AUMetadataItemTypeMusic;
                metadataItem.path = [NSString stringWithFormat:@"%@",strMediaName];
                [self.removeMetadataItems addObject:metadataItem];

                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
        }

        _lodingIndex ++;
        NSLog(@"_lodingIndex  --checkMusic  %ld",(long)_lodingIndex);
        if (_lodingIndex == 3) {
            [gAU loadDocmentItmes];
        }
    });
}

- (void)setWriteImage:(NSString *)strPath successCallBackCompletion:(void(^)(NSString *path))completion {
    // 是否是本地图片?
    NSString *strImageName = [[strPath componentsSeparatedByString:@"/"]lastObject];
    NSString *srtUrl = [[NSUserDefaults standardUserDefaults]objectForKey:strImageName];
    if (!srtUrl) {
        DDLogInfo(@"没有对应的图片：%@", strImageName);
        completion(nil);
        return;
    }

    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];

    NSURL *assetURL = [NSURL URLWithString:srtUrl];
    [lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        if (asset) {
            //写入到本地沙盒的图片
            @autoreleasepool {
                UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
                NSData *imageData = UIImageJPEGRepresentation(image, 1);
                if (!imageData) {
                    DDLogInfo(@"找原图失败1：%@", strImageName);
                    completion(nil);
                    return;
                }

                //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *strFilePath = [AUSerialization getFileCapture];
                if (![[NSFileManager defaultManager] fileExistsAtPath:strFilePath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:strFilePath withIntermediateDirectories:YES attributes:nil error:nil];
                }

                NSString *strFileNmae = [NSString stringWithFormat:@"%@.jpg",file_PhotoImageName];
                NSString *imagePath = [strFilePath stringByAppendingPathComponent:strFileNmae];
                if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
                }
                BOOL ret = [imageData writeToFile:imagePath atomically:YES];
                if (!ret) {
                    DDLogInfo(@"找原图失败3：%@", strImageName);
                    completion(nil);
                    return;
                }
                //dispatch_async(dispatch_get_main_queue(), ^{
                completion(imagePath);
            }
        }else {
            [lib enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                [group enumerateAssetsWithOptions:NSEnumerationReverse
                                       usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                           if ([result.defaultRepresentation.url isEqual:assetURL]) {
                                               *stop = YES;
                                               //写入到本地沙盒的图片
                                               @autoreleasepool {
                                                   UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
                                                   NSData *imageData = UIImageJPEGRepresentation(image, 1);
                                                   if (!imageData) {
                                                       DDLogInfo(@"找原图失败1：%@", strImageName);
                                                       completion(nil);
                                                       return;
                                                   }

                                                   //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                   NSString *strFilePath = [AUSerialization getFileCapture];
                                                   if (![[NSFileManager defaultManager] fileExistsAtPath:strFilePath]) {
                                                       [[NSFileManager defaultManager] createDirectoryAtPath:strFilePath withIntermediateDirectories:YES attributes:nil error:nil];
                                                   }

                                                   NSString *strFileNmae = [NSString stringWithFormat:@"%@.jpg",file_PhotoImageName];
                                                   NSString *imagePath = [strFilePath stringByAppendingPathComponent:strFileNmae];
                                                   if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                                                       [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
                                                   }
                                                   BOOL ret = [imageData writeToFile:imagePath atomically:YES];
                                                   if (!ret) {
                                                       DDLogInfo(@"找原图失败3：%@", strImageName);
                                                       completion(nil);
                                                       return;
                                                   }
                                                   //dispatch_async(dispatch_get_main_queue(), ^{
                                                   completion(imagePath);
                                               }
                                           }
                                       }];
            } failureBlock:^(NSError *error) {
                if (completion) {
                    DDLogInfo(@"找原图失败3：%@", strImageName);
                    completion(nil);
                }
            }];
        }
     } failureBlock:^(NSError *error) {
         if (completion) {
             DDLogInfo(@"找原图失败2：%@", strImageName);
             completion(nil);
         }
     }];
}

@end
