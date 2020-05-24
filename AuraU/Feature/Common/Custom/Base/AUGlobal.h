//
//  AUGlobal.h
//  AuraU
//
//  Created by Thundersoft on 15/3/6.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUMetadataItem.h"
#import <AVFoundation/AVFoundation.h>
#import "AssetItem.h"

@class AUGlobal;
AUGlobal *gAU;

typedef NS_ENUM(int, k_enum_fileType) {
    enum_Video,
    enum_Music,
    enum_Photo
};

@interface AUGlobal : NSObject<UIAlertViewDelegate>

{
    UIView *_exportView;
    UIProgressView *_exprotProgressView;
    UILabel *_exportStateLabel;
    
    MBProgressHUD *_hud;
    NSTimer *_exportTimer;
    void (^_completionBlock)(void);
    NSInteger _lodingIndex;
}
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSMutableArray *metadataItems;
@property (nonatomic, assign) BOOL isOperatingState;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *arrayAssetsLibraryChanged;
@property (nonatomic, strong) NSMutableDictionary *dic_FileId;

@property (nonatomic, strong) NSMutableArray *addMetadataItems;
@property (nonatomic, strong) NSMutableArray *removeMetadataItems;

@property (nonatomic, assign) BOOL isConnectionStatus;

@property (nonatomic, assign) BOOL isConnectionInit;

- (void)loadDocmentItmes;

- (void)initMediaExportView:(id)object outputFileType:(k_enum_fileType)fileType;

- (ALAssetsLibrary *)defaultAssetsLibrary;

- (void)arrayFileManage;

- (void)makeArrayPhoto:(NSMutableArray *)arrayPhoto arrayVideo:(NSMutableArray *)arrayVideo  arrayMusic:(NSMutableArray *)arrayMusic completion:(void (^)(void))completion;

- (void)checkMedia;

- (void)setWriteImage:(NSString *)strPath successCallBackCompletion:(void(^)(NSString *path))completion;

@end
