//
//  TSShareCell.m
//  AuraU
//
//  Created by Army on 15-2-11.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "TSShareCell.h"
#import<AssetsLibrary/AssetsLibrary.h>

#define kThumbnailLength    78.0f

@implementation TSShareCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setArrayPhotoGuoup:(NSArray *)arrayPhotoGuoup
{
   
    _arrayPhotoGuoup = arrayPhotoGuoup;
    NSInteger index = 0;
    for (int i = 0; i < 3; i++) {
        UIView *viewBg = self.array_view_option[i];
        UILabel *lableTitle = self.array_lable_title[i];
        if (i < [arrayPhotoGuoup count]) {
            [viewBg setHidden:NO];
            [lableTitle setHidden:NO];
        } else {
            [viewBg setHidden:YES];
            [lableTitle setHidden:YES];
        }

    }
    for (TSAssetsGroupObject *assetsGroupObject in arrayPhotoGuoup) {
        [self.array_img_option[index] setHighlighted:assetsGroupObject.isChoose];
        [self.array_button_option[index] setBackgroundImage:assetsGroupObject.image forState:UIControlStateNormal];
        UILabel *lableTitle = self.array_lable_title[index];
        lableTitle.text = assetsGroupObject.strTitle;
        UIView *viewNumber = self.array_view_number[index];
        [viewNumber setHidden:NO];
        UILabel *lableNumber = self.array_lable_number[index];
        lableNumber.text = assetsGroupObject.strNumber;
        index ++;
    }

}

- (void)setArrayMusic:(NSArray *)arrayMusic
{

    _arrayMusic = arrayMusic;
    NSInteger index = 0;
    for (int i = 0; i < 3; i++) {
        UIView *viewBg = self.array_view_option[i];
        UILabel *lableTitle = self.array_lable_title[i];
        if (i < [arrayMusic count]) {
            [viewBg setHidden:NO];
            [lableTitle setHidden:NO];
        } else {
            [viewBg setHidden:YES];
            [lableTitle setHidden:YES];
        }

    }
    for (TSMusicObject *musicObject in arrayMusic) {
        UIImageView *imageView = self.array_img_option[index];

        [imageView setHighlighted:musicObject.isChoose];

        UIButton *button = self.array_button_option[index];

        UIImage *artworkImage = [ musicObject.mediaItme imageWithSize: CGSizeMake(74 ,74)];


        [button setBackgroundImage:artworkImage forState:UIControlStateNormal];
        UILabel *lableTitle = self.array_lable_title[index];
        lableTitle.text = musicObject.strMusicName;
        UIView *viewNumber = self.array_view_number[index];
        [viewNumber setHidden:YES];
        index ++;
    }
    
}


- (void)setArrayVideo:(NSArray *)arrayVideo
{
    _arrayVideo = arrayVideo;
    NSInteger index = 0;
    for (int i = 0; i < 3; i++) {

        UIView *viewBg = self.array_view_option[i];
        UILabel *lableTitle = self.array_lable_title[i];
        if (i < [arrayVideo count]) {
            [viewBg setHidden:NO];
            [lableTitle setHidden:NO];
        } else {
            [viewBg setHidden:YES];
            [lableTitle setHidden:YES];
        }

    }
    for ( AssetItem *assetItem in arrayVideo) {
        [self.array_img_option[index] setHighlighted:assetItem.isChoose];

        if (!assetItem.thumbnail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [assetItem loadThumbnailWithCompletionHandler:^{
                      [self.array_button_option[index] setBackgroundImage:assetItem.thumbnail forState:UIControlStateNormal];
                     [self setNeedsLayout];
                }];
            });
        } else {
              [self.array_button_option[index] setBackgroundImage:assetItem.thumbnail forState:UIControlStateNormal];
        }

        UILabel *lableTitle = self.array_lable_title[index];
        lableTitle.text = assetItem.title;
        UIView *viewNumber = self.array_view_number[index];
        [viewNumber setHidden:YES];
         [self setNeedsLayout];
        index ++;
    }
    
}

+ (CGFloat)height
{
    return 108.0f;
}

#pragma mark - IBAcion
- (IBAction)makeButtonAction:(UIButton *)sender
{
    UIImageView *imageView = self.array_img_option[sender.tag - 1];
    [imageView setHighlighted:!imageView.highlighted];
    if ([self.delegate respondsToSelector:@selector(TSShareCell:isChooseIndex:)]) {
        [self.delegate TSShareCell:self isChooseIndex:sender.tag];
    }
}

@end



