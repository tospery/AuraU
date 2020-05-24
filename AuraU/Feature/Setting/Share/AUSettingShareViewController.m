//
//  AUSettingShareViewController.m
//  AuraU
//
//  Created by Thundersoft on 15/2/10.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUSettingShareViewController.h"

#import "TSShareCell.h"

extern NSMutableDictionary *gNameDict;

typedef NS_ENUM(NSInteger, SHARETYPE){
    SHARETYPEPHONE = 1,
    SHARETYPEVIDEO,
    SHARETYPEMUSIC
};

@interface AUSettingShareViewController ()<UITableViewDataSource,UITableViewDelegate,TSShareCellDelegate>
{
    UIButton *_but;
    VideoLibrary *_videoLibrary;
    UIButton* _backButton;
    NSInteger _lodingIndex;
    dispatch_queue_t _queue;
    dispatch_group_t _group;

}
@property (strong, nonatomic) IBOutlet UIButton *but_Phone;
@property (strong, nonatomic) IBOutlet UIButton *but_video;
@property (strong, nonatomic) IBOutlet UIButton *but_music;
@property (strong, nonatomic) IBOutlet UIImageView *imageVew_line;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, weak) IBOutlet UIButton *buttonSend;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, assign)SHARETYPE type;

@end

@implementation AUSettingShareViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _group = dispatch_group_create();
    [_buttonSend setTitle:kStringOK forState:UIControlStateNormal];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActiveNotification)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [self.buttonSend exSetBorder:[UIColor clearColor] width:kJXSizeForBorderWidthSmall radius:kJXSizeForCornerRadiusSmall];
    [self.buttonSend setBackgroundImage:[UIImage genWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:kSettingLoding]) {
        [self.buttonSend setEnabled:NO];
        [_buttonSend setHidden:YES];
    } else {
        [self.buttonSend setEnabled:YES];
        [_buttonSend setHidden:NO];
        [userDefaults setObject:kSettingLoding forKey:kSettingLoding];
        [userDefaults synchronize];
    }
    
    self.title = kStringSetSharedDirectory;

    _arrayPhones = [[NSMutableArray alloc]init];
    _arrayPhoneGroup = [[NSMutableArray alloc]init];
    _arrayVideo = [NSMutableArray array];
    _arrayMusic = [NSMutableArray array];
    [self setXibData];
    _but = self.but_Phone;
    _type = SHARETYPEPHONE;
    _lodingIndex  = 0;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getPhotoImages];
    [self loadVideo];
    [self loadMusic];
    self.navigationItem.rightBarButtonItem = [self actionButton];

    if (self.firstLoding) {
        [_backButton setSelected:YES];
    }
    // Do any additional setup after loading the view from its nib.
}

- (UIBarButtonItem *)actionButton
{
    UIImage *image = [UIImage imageNamed:@"option_all_normal.png"];
    UIImage *imageAll = [UIImage imageNamed:@"option_all_hl.png"];
    CGRect backframe = CGRectMake(0, 0, image.size.width, image.size.height);
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = backframe;
    [_backButton setBackgroundImage:image forState:UIControlStateNormal];
    [_backButton setBackgroundImage:imageAll forState:UIControlStateSelected];
    [_backButton addTarget:self action:@selector(markSelectAllAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:_backButton];
    return backBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setType:(SHARETYPE)type
{
    _type = type;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_type == SHARETYPEPHONE) {
            if ([_arrayPhoneGroup count] == 0) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [self.table setHidden:YES];
                [self getPhotoImages];
            } else {
                self.table.backgroundView = nil;
                [self.table reloadData];
                [self checkIsSelectAll];
            }

        } else if (_type == SHARETYPEVIDEO) {
            if ([_arrayVideo count] == 0) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [self.table setHidden:YES];
                [self loadVideo];
            } else {
                self.table.backgroundView = nil;
                [self.table reloadData];
                [self checkIsSelectAll];
            }

        } else {
            if ([_arrayMusic count] == 0) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [self.table setHidden:YES];
                [self loadMusic];
            } else {
                self.table.backgroundView = nil;
                [self.table reloadData];
                 [self checkIsSelectAll];
            }
        }
    });

}

- (void)setXibData
{
    [self.but_Phone setTitle:kStringForgotPhoto forState:UIControlStateNormal];
    [self.but_video setTitle:kStringForgotVideo forState:UIControlStateNormal];
    [self.but_music setTitle:kStringForgotMusic forState:UIControlStateNormal];
}

#pragma mark - Action
- (void)markSelectAllAction
{
    [self checkIsSelectAll:!_backButton.selected];
}

- (void)checkIsSelectAll
{
    BOOL selected = YES;
    if (_type == SHARETYPEPHONE) {
        for ( TSAssetsGroupObject *assetsGroupObject in _arrayPhoneGroup) {
            if (assetsGroupObject.isChoose == enum_notChoose) {
                selected = NO;
                break;
            }
        }
    }
    if (_type == SHARETYPEVIDEO) {
        for (  AssetItem *assetItem in _arrayVideo) {
            if (assetItem.isChoose == enum_notChoose) {
                selected = NO;
                break;
            }
        }
    }

    if (_type == SHARETYPEMUSIC) {
        for ( TSMusicObject *musicObject in _arrayMusic) {
            if (musicObject.isChoose == enum_notChoose) {
                selected = NO;
                break;
            }
        }
    }

    [_backButton setSelected:selected];
}

- (void)checkIsSelectAll:(BOOL)selectAll
{

    if (_type == SHARETYPEPHONE) {
        for ( TSAssetsGroupObject *assetsGroupObject in _arrayPhoneGroup) {
            assetsGroupObject.isChoose = selectAll;
        }
    }
    if (_type == SHARETYPEVIDEO) {
        for (  AssetItem *assetItem in _arrayVideo) {
            assetItem.isChoose = selectAll;
        }
    }

    if (_type == SHARETYPEMUSIC) {
        for ( TSMusicObject *musicObject in _arrayMusic) {
            musicObject.isChoose = selectAll;
        }
    }
    [self.table reloadData];
    [_backButton setSelected:selectAll];
}

- (IBAction)makeSendAction:(id)sender
{
    NSLog(@"makeSendAction");
    __block AUSettingShareViewController *controllr = self;
    gAU.contentView = controllr.view;
    [gAU makeArrayPhoto:_arrayPhoneGroup arrayVideo:_arrayVideo arrayMusic:_arrayMusic completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [controllr.navigationController dismissViewControllerAnimated:YES completion:nil];
        });

    }];
}

- (void)makeBack
{
    
    __block AUSettingShareViewController *controllr = self;
    gAU.contentView = self.view.window;
    [gAU makeArrayPhoto:_arrayPhoneGroup arrayVideo:_arrayVideo arrayMusic:_arrayMusic completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [controllr.navigationController popViewControllerAnimated:YES];
        });

    }];
}


- (IBAction)makeButtonAction:(UIButton *)sender
{
    [_but setSelected:NO];
    _but = sender;
    [_but setSelected:YES];
    self.type = sender.tag;
    [UIView animateWithDuration:.2 animations:^{
        CGRect rect = self.imageVew_line.frame;
        rect.origin.x = _but.frame.origin.x;
        //        rect.size.height = _but.frame.origin.x;
        self.imageVew_line.frame = rect;
    }];
}

#pragma mark - loadData
-(void)getPhotoImages
{

    __block AUSettingShareViewController *controller = self;
    dispatch_async(dispatch_get_main_queue(), ^{

        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
            NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
            if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
            }else{
                NSLog(@"相册访问失败.");
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showNotAllowed];
            [self.table setHidden:NO];
            [self.table reloadData];
            return ;
        };
        NSString *strFilePath = [AUSerialization getFilePhoto];
        NSArray *arrayGroups = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];
        ALAssetsLibraryGroupsEnumerationResultsBlock
        libraryGroupsEnumeration = ^(ALAssetsGroup* group,BOOL* stop) {
            if (group) {
                __block ALAssetsGroup *assetsGroup = group;
                if ([assetsGroup numberOfAssets] > 0) {

                    __block int i = 0;
                    __block UIImage *posterImage = nil;
                    __block NSMutableArray *arrayAsset = [[NSMutableArray alloc]init];
                    ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result,NSUInteger index, BOOL *stop){

                        if (result!=NULL) {
                            //获取照片分组里面的具体照片添加到arrayAsset数组里面
                            if ([[result valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypePhoto]) {
                                i ++;
                                posterImage = [UIImage imageWithCGImage:result.thumbnail];
                                
                                [arrayAsset addObject:result];
                            }
                        } else {
                            //获取照片分组
                            if (![[assetsGroup valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"AuraU"]) {
                                TSAssetsGroupObject *assetsGroupObject = [[TSAssetsGroupObject alloc]init];
                                assetsGroupObject.strTitle = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
                                assetsGroupObject.strNumber = [NSString stringWithFormat:@"%ld", (long)i];
                                assetsGroupObject.image = posterImage;
                                //第一次安装auraU 默认全选
                                if (self.firstLoding) {
                                    assetsGroupObject.isChoose = enum_isChoose;
                                } else {
                                    NSArray *arrayImages = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",strFilePath,assetsGroupObject.strTitle] error:nil];
                                    if ([arrayGroups containsObject:assetsGroupObject.strTitle] && [arrayImages count] > 0) {
                                        assetsGroupObject.isChoose = enum_isChoose;
                                    } else {
                                         assetsGroupObject.isChoose = enum_notChoose;
                                    }
                                }
                                assetsGroupObject.assetsGroup = assetsGroup ;
                                assetsGroupObject.arrayAssect = arrayAsset;
                                [controller.arrayPhoneGroup addObject:assetsGroupObject];
                            }
                        }
                    };
                    [assetsGroup enumerateAssetsUsingBlock:groupEnumerAtion];

                }
            } else { //获取完全部分组
                //选择照片栏
                if (_type == SHARETYPEPHONE) {
                    [self.table setHidden:NO];
                    [self.table reloadData];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
//                    if ([_arrayPhoneGroup count]  > 0) {
//                        self.table.backgroundView = nil;
//                    }
                    if ([_arrayPhoneGroup count] == 0) {
                        [self showNoAssets];
                    } else {
                        self.table.backgroundView = nil;
                    }
                }
                //三次加载完更新ui，
                _lodingIndex ++;
                if (_lodingIndex == 3) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.buttonSend setEnabled:YES];
                    [self setPhonePage];
                }
                [self checkIsSelectAll];

            }
        };

        if (!self.assetsLibrary)
            self.assetsLibrary = [gAU defaultAssetsLibrary];
        [ self.assetsLibrary enumerateGroupsWithTypes:(ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos)
                               usingBlock:libraryGroupsEnumeration
                             failureBlock:failureblock];
        
    });  

}

//获取系统视频文件 判断选在和未选择在VideoLibrary 里面
- (void)loadVideo {
    dispatch_async(dispatch_get_main_queue(), ^{
        _videoLibrary = [[VideoLibrary alloc] initWithLibraryChangedHandler:^{
        } firstLoding:self.firstLoding];
        [_videoLibrary loadLibraryWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                _arrayVideo = _videoLibrary.assetItems;
                _lodingIndex ++;
                if (_lodingIndex == 3) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.buttonSend setEnabled:YES];
                    [self setPhonePage];
                }

                [self checkIsSelectAll];
                if (_type == SHARETYPEVIDEO) {
                    if ([_arrayVideo count] == 0) {
                        [self showNoAssets];
                    } else {
                        self.table.backgroundView = nil;
                    }
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.table setHidden:NO];
                    [self.table reloadData];
                }
            });
        }];
    });
}

//获取系统音乐
-(void)loadMusic {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPMediaQuery *listQuery = [MPMediaQuery songsQuery];
        NSArray *playlist = [listQuery collections];
        NSString *strFilePath = [AUSerialization getFileMusic];
        NSArray *arrayMusics = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:strFilePath error:nil];
        for (MPMediaPlaylist * list in playlist) {
            NSArray *songs = [list items];//歌曲数组

            for (MPMediaItem *song in songs) {
                NSString *title =[song valueForProperty:MPMediaItemPropertyTitle];//歌曲名
                NSURL *url =[song valueForProperty:MPMediaItemPropertyAssetURL];//歌曲名
                //专辑名
                NSString *albumTitle =[song valueForProperty:MPMediaItemPropertyAlbumTitle];
                //歌手名
                NSString *artist =[[song valueForProperty:MPMediaItemPropertyArtist] uppercaseString];

                MPMediaItemArtwork *artwork =
                [song valueForProperty: MPMediaItemPropertyArtwork];
                NSString *stitle = [title stringByAppendingString:@".wav"];
                TSMusicObject *musciObiect = [[TSMusicObject alloc] init];
                BOOL b = [arrayMusics containsObject:stitle];
                if (!b) {
                    NSString *origtitle = [gNameDict objectForKey:url];
                    b = [arrayMusics containsObject:origtitle];
                }

                if (self.firstLoding)
                    musciObiect.isChoose = enum_isChoose;
                else
                    musciObiect.isChoose = b == YES ? enum_isChoose : enum_notChoose;
                musciObiect.strMusicName = title;
                musciObiect.strmusicUrl = url;
                musciObiect.mediaItme = artwork;
                musciObiect.albumTitle = albumTitle;
                musciObiect.artist = artist;
                [_arrayMusic addObject:musciObiect];

                 [self checkIsSelectAll];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _lodingIndex ++;
            if (_lodingIndex == 3) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.buttonSend setEnabled:YES];
                [self setPhonePage];
            }
            if (_type == SHARETYPEMUSIC) {
                if ([_arrayMusic count] == 0) {
                    [self showNoAssets];
                } else {
                    self.table.backgroundView = nil;
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.table setHidden:NO];
                [self.table reloadData];
            }
        });
    });
}


- (void)reloadData
{
    if (_arrayPhoneGroup.count == 0)
        [self showNoAssets];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.table reloadData];
}

- (void)setPhonePage
{
    if (_type == SHARETYPEPHONE) {
        [self.table setHidden:NO];
        [self.table reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([_arrayPhoneGroup count]  > 0) {
            self.table.backgroundView = nil;
        }

    }
}

#pragma mark - Not allowed / No assets

- (void)showNotAllowed
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        [self setEdgesForExtendedLayout:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom];

    self.title              = nil;

    UIImageView *padlock    = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ZYQAssetPicker.Bundle/Images/AssetsPickerLocked@2x.png"]]];
    padlock.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *title          = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.preferredMaxLayoutWidth = 304.0f;

    UILabel *message        = [UILabel new];
    message.translatesAutoresizingMaskIntoConstraints = NO;
    message.preferredMaxLayoutWidth = 304.0f;

    title.text              = kStringAppCannotUseYourPictureOrVideo;
    title.font              = [UIFont boldSystemFontOfSize:17.0];
    title.textColor         = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;

    message.text            = kStringYouCanEnableItAtPrivicySetting;
    message.font            = [UIFont systemFontOfSize:14.0];
    message.textColor       = [UIColor colorWithRed:129.0/255.0 green:136.0/255.0 blue:148.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;

    [title sizeToFit];
    [message sizeToFit];

    UIView *centerView = [UIView new];
    centerView.translatesAutoresizingMaskIntoConstraints = NO;
    [centerView addSubview:padlock];
    [centerView addSubview:title];
    [centerView addSubview:message];

    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(padlock, title, message);

    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:padlock attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:centerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:padlock attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:message attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:padlock attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[padlock]-[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];

    UIView *backgroundView = [UIView new];
    [backgroundView addSubview:centerView];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];

    self.table.backgroundView = backgroundView;
}

- (void)showNoAssets
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        [self setEdgesForExtendedLayout:UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom];

    UILabel *title          = [UILabel new];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.preferredMaxLayoutWidth = 304.0f;
    UILabel *message        = [UILabel new];
    message.translatesAutoresizingMaskIntoConstraints = NO;
    message.preferredMaxLayoutWidth = 304.0f;


    title.font              = [UIFont systemFontOfSize:26.0];
    title.textColor         = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    title.textAlignment     = NSTextAlignmentCenter;
    title.numberOfLines     = 5;
    if (_type == SHARETYPEPHONE) {
        title.text              = kStringNoPicture;
        message.text            = kStringYouCanUseiTunesToSycPictureToiPhone;
    } else if(_type == SHARETYPEVIDEO){
        title.text              = kStringNoVideo;
        message.text            = kStringYouCanUseiTunesToSycVideoToiPhone;
    } else {
        title.text              = kStringNoMusic;
        message.text            = kStringYouCanUseiTunesToSycMusicToiPhone;
    }

    message.font            = [UIFont systemFontOfSize:18.0];
    message.textColor       = [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1];
    message.textAlignment   = NSTextAlignmentCenter;
    message.numberOfLines   = 5;

    [title sizeToFit];
    [message sizeToFit];

    UIView *centerView = [UIView new];
    centerView.translatesAutoresizingMaskIntoConstraints = NO;
    [centerView addSubview:title];
    [centerView addSubview:message];

    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(title, message);

    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:centerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraint:[NSLayoutConstraint constraintWithItem:message attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:title attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [centerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]-[message]|" options:0 metrics:nil views:viewsDictionary]];

    UIView *backgroundView = [UIView new];
    [backgroundView addSubview:centerView];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:centerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:backgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];

    self.table.backgroundView = backgroundView;
}

#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_type == SHARETYPEPHONE) {
         return ceil(_arrayPhoneGroup.count * 1.0 / 3);
    } else if(_type == SHARETYPEVIDEO){
        return ceil(_arrayVideo.count * 1.0 / 3);
    } else {
        return ceil(_arrayMusic.count * 1.0 / 3);
    }

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TSShareCell height];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (_type == SHARETYPEPHONE) {
        static NSString *identifiercell = @"cellPhoto";
        TSShareCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiercell];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TSShareCell" owner:self options:nil] lastObject];
            UINib *goodsCellNib= [UINib nibWithNibName:@"TSShareCell" bundle:[NSBundle mainBundle]];
            [tableView registerNib:goodsCellNib forCellReuseIdentifier:identifiercell];
        }

        cell.delegate = self;
        NSMutableArray *tempAssets=[[NSMutableArray alloc] init];
        for (int i = 0; i < 3; i++) {
            NSInteger index = indexPath.row * 3 + i ;
            if (index < [_arrayPhoneGroup count]) {
                [tempAssets addObject:_arrayPhoneGroup[index]];
            }
        }
        cell.arrayPhotoGuoup = tempAssets;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;

    } else if (_type == SHARETYPEVIDEO) {
        static NSString *identifiercell = @"cellDideo";
        TSShareCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiercell];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TSShareCell" owner:self options:nil] lastObject];
            UINib *goodsCellNib= [UINib nibWithNibName:@"TSShareCell" bundle:[NSBundle mainBundle]];
            [tableView registerNib:goodsCellNib forCellReuseIdentifier:identifiercell];
        }

        cell.delegate = self;
        NSMutableArray *arrar=[[NSMutableArray alloc] init];
        for (int i = 0; i < 3; i++) {
            NSInteger index = indexPath.row * 3 + i ;
            if (index < [_arrayVideo count]) {
                [arrar addObject:_arrayVideo[index]];
            }
        }
        cell.arrayVideo = arrar;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;

    } else {
        static NSString *identifiercell = @"cellMusic";
        TSShareCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiercell];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TSShareCell" owner:self options:nil] lastObject];
            UINib *goodsCellNib= [UINib nibWithNibName:@"TSShareCell" bundle:[NSBundle mainBundle]];
            [tableView registerNib:goodsCellNib forCellReuseIdentifier:identifiercell];
        }

        cell.delegate = self;
        NSMutableArray *arrar=[[NSMutableArray alloc] init];
        for (int i = 0; i < 3; i++) {
            NSInteger index = indexPath.row * 3 + i ;
            if (index < [_arrayMusic count]) {
                [arrar addObject:_arrayMusic[index]];
            }
        }
        cell.arrayMusic = arrar;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    return nil;
}

#pragma mark - TSShareCellDelegate
- (void)TSShareCell:(TSShareCell *)cell isChooseIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.table indexPathForCell:cell];
    NSInteger indexArray = indexPath.row * 3 + index - 1;
    if (_type == SHARETYPEPHONE) {
        TSAssetsGroupObject *assetsGroupObject = _arrayPhoneGroup[indexArray];
        assetsGroupObject.isChoose = assetsGroupObject.isChoose == enum_notChoose ? enum_isChoose : enum_notChoose;
        [_arrayPhoneGroup replaceObjectAtIndex:indexArray withObject:assetsGroupObject];
    } else if(_type == SHARETYPEVIDEO){
        AssetItem *assetsItem = _arrayVideo[indexArray];
        assetsItem.isChoose = assetsItem.isChoose == enum_notChoose ? enum_isChoose : enum_notChoose;
        [_arrayVideo replaceObjectAtIndex:indexArray withObject:assetsItem];
    } else {
        TSMusicObject *musicObject = _arrayMusic[indexArray];
        musicObject.isChoose = musicObject.isChoose == enum_notChoose ? enum_isChoose : enum_notChoose;
        [_arrayMusic replaceObjectAtIndex:indexArray withObject:musicObject];
    }
    [self checkIsSelectAll];
}


#pragma mark - Notification
- (void)becomeActiveNotification
{
//    [_arrayPhoneGroup removeAllObjects];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
