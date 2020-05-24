//
//  UIView+JXApple.h
//  MyiOS
//
//  Created by Thundersoft on 10/19/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JXApple)
- (UIView *)circle;
- (void)circleWithColor:(UIColor *)color border:(CGFloat)border;
- (UIView *)exSetBorder:(UIColor *)color width:(CGFloat)width radius:(CGFloat)radius;

// 约束方法
- (void)addConstraintsForFillSuperview;
- (void)addConstraintsForAroundSuperviewWithLeadingSpace:(CGFloat)leadingSpace
                                             topSpace:(CGFloat)topSpace
                                        trailingSpace:(CGFloat)trailingSpace
                                          bottomSpace:(CGFloat)bottomSpace;
- (void)addConstraintForLeadingSpace:(CGFloat)space view:(UIView *)view priority:(UILayoutPriority)priority;
- (void)addConstraintForTopSpace:(CGFloat)space view:(UIView *)view priority:(UILayoutPriority)priority;
- (void)addConstraintForTrailingSpace:(CGFloat)space view:(UIView *)view priority:(UILayoutPriority)priority;
- (void)addConstraintForBottomSpace:(CGFloat)space view:(UIView *)view priority:(UILayoutPriority)priority;
- (void)addConstraintForFixedWidth:(CGFloat)width priority:(UILayoutPriority)priority;
- (void)addConstraintForFixedHeight:(CGFloat)height priority:(UILayoutPriority)priority;

- (void)layoutAroundSuperview;
@end