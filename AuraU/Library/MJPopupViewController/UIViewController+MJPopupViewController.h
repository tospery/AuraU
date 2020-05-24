//
//  UIViewController+MJPopupViewController.h
//  MJModalViewController
//
//  Created by Martin Juhasz on 11.05.12.
//  Copyright (c) 2012 martinjuhasz.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MJPopupBackgroundView;

typedef enum {
    MJPopupViewAnimationFade = 0,
    MJPopupViewAnimationSlideBottomTop = 1,
    MJPopupViewAnimationSlideBottomBottom,
    MJPopupViewAnimationSlideTopTop,
    MJPopupViewAnimationSlideTopBottom,
    MJPopupViewAnimationSlideLeftLeft,
    MJPopupViewAnimationSlideLeftRight,
    MJPopupViewAnimationSlideRightLeft,
    MJPopupViewAnimationSlideRightRight,
} MJPopupViewAnimation;

@interface UIViewController (MJPopupViewController)
@property (nonatomic, assign) BOOL bgclickEnabled;
@property (nonatomic, retain) UIViewController *mj_popupViewController;
@property (nonatomic, retain) MJPopupBackgroundView *mj_popupBackgroundView;

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(MJPopupViewAnimation)animationType bgclickEnabled:(BOOL)bgclickEnabled;
- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(MJPopupViewAnimation)animationType bgclickEnabled:(BOOL)bgclickEnabled dismissed:(void(^)(void))dismissed;
- (void)dismissPopupViewControllerWithanimationType:(MJPopupViewAnimation)animationType;
- (void)dismissPopupViewControllerWithanimationTypeWithNoAnimated:(MJPopupViewAnimation)animationType;
@end
