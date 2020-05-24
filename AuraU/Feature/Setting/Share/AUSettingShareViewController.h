//
//  AUSettingShareViewController.h
//  AuraU
//
//  Created by Thundersoft on 15/2/10.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AUSettingShareViewController : UIViewController
{
    ALAssetsGroup *_assetsGroup;
}
@property (nonatomic,assign) BOOL firstLoding;

@property (nonatomic,strong) NSMutableArray *arrayPhones;
@property (nonatomic,strong) NSMutableArray *arrayPhoneGroup;
@property (nonatomic,strong) NSMutableArray *arrayVideo;
@property (nonatomic,strong) NSMutableArray *arrayMusic;



//@property (nonatomic,strong)ALAssetsGroup *assetsGroup;


//typedef void (^metadataItemsBlock)(NSMutableArray *metadataItems);

- (void)makeBack;
@end
