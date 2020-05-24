//
//  TSShareCell.h
//  AuraU
//
//  Created by Army on 15-2-11.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TSShareCell;
@protocol TSShareCellDelegate <NSObject>

- (void)TSShareCell:(TSShareCell *)cell isChooseIndex:(NSInteger)index;

@end
@interface TSShareCell : UITableViewCell

@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray *array_img_option;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *array_lable_number;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *array_lable_title;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *array_view_option;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *array_button_option;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *array_view_number;

@property (nonatomic, strong) NSArray *arrayPhotoGuoup;
@property (nonatomic, strong) NSArray *arrayVideo;
@property (nonatomic, strong) NSArray *arrayMusic;
@property (nonatomic, weak) id<TSShareCellDelegate>delegate;
+ (CGFloat)height;
@end




