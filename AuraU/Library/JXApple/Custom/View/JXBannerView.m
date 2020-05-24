//
//  JXBannerView.m
//  MyiOS
//
//  Created by Thundersoft on 10/20/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import "JXBannerView.h"

@implementation JXBannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setLoadDataImages:(NSArray *)arrarImage
{
    _imagesArray = [[NSArray alloc] initWithArray:arrarImage];
    [self addScrollContent:arrarImage];
}

- (void)setContentWithViews:(NSArray *)views
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [views count],
                                             self.scrollView.frame.size.height);

    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;

    _pageControl.numberOfPages = views.count;
    _pageControl.currentPage = 0;
    _pageControl.enabled = NO;

    NSArray *subViews = [self.scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }

    for (int i = 0; i < [views count]; i++) {
        UIView *view = views[i];
        view.frame = CGRectOffset(self.scrollView.frame, self.scrollView.frame.size.width * i, 0);
        [self.scrollView addSubview:view];
    }
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
}

- (void)refreshScrollView {

    NSArray *subViews = [self.scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }

    for (int i = 0; i < [_imagesArray count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.scrollView.frame];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        [imageView addGestureRecognizer:singleTap];

        imageView.userInteractionEnabled = YES;

        // TODO 下载图片
//        TSAsynImageDownload *imageDown = [[TSAsynImageDownload alloc]init];
//        [imageDown didDownLoadImageIsUrl:_imagesArray[i][@"image"] completion:^(UIImage *image) {
//            dispatch_async(dispatch_get_main_queue(), ^ {
//                imageView.image = image;
//            });
//        }];

        imageView.frame = CGRectOffset(imageView.frame, self.scrollView.frame.size.width * i, 0);

        [self.scrollView addSubview:imageView];
    }
    [self.scrollView setContentOffset:CGPointMake(0, 0)];

}

#pragma mark - ScrollView content
- (void)addScrollContent:(NSArray *)imageArray
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [imageArray count],
                                             self.scrollView.frame.size.height);

    [_scrollView setPagingEnabled:YES];
    [_pageControl setNumberOfPages:[imageArray count]];
    [_pageControl setCurrentPage:0];
    [_pageControl setEnabled:NO];
    [self refreshScrollView];
}

#pragma mark - ScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    int page = aScrollView.contentOffset.x / 320;
    [_pageControl setCurrentPage:page];

}

- (void)handleTap:(UITapGestureRecognizer *)tap {

    if ([self.delegate respondsToSelector:@selector(ADScrollView:withTapGesturePage:)]) {
        [self.delegate ADScrollView:self withTapGesturePage:_pageControl.currentPage];
    }
}
@end
