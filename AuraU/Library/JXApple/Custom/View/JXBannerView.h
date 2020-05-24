//
//  JXBannerView.h
//  MyiOS
//
//  Created by Thundersoft on 10/20/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

// TODO 用自动布局重构该类
@class JXBannerView;

@protocol JXBannerViewDelegate <NSObject>
- (void)ADScrollView:(JXBannerView *)adView withTapGesturePage:(NSInteger)page;
@end

@interface JXBannerView : UIView<UIScrollViewDelegate>
{
    NSArray *_imagesArray;               // 存放所有需要滚动的图片 UIImage
    //    NSMutableArray *curImages;          // 存放当前滚动的三张图片
    int totalPage;
    int curPage;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) id<JXBannerViewDelegate>delegate;

- (void)setLoadDataImages:(NSArray *)arrarImage;
- (void)setContentWithViews:(NSArray *)views;
@end