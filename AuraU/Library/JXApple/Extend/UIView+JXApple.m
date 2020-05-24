//
//  UIView+JXApple.m
//  MyiOS
//
//  Created by Thundersoft on 10/19/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import "UIView+JXApple.h"
#import "JXPredef.h"

@implementation UIView (JXApple)
- (UIView *)circle
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width / 2.0;
    self.layer.borderWidth = 0.2;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    return self;
}

- (void)circleWithColor:(UIColor *)color border:(CGFloat)border {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width / 2.0;
    self.layer.borderWidth = border;
    self.layer.borderColor = color.CGColor;
}

- (UIView *)exSetBorder:(UIColor *)color width:(CGFloat)width radius:(CGFloat)radius
{
    self.layer.masksToBounds = YES;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
    self.layer.cornerRadius = radius;
    return self;
}

- (void)addConstraintsForFillSuperview {
    if (!self.superview) {
        return;
    }

    UIView *thisView = self;
    UIView *container = self.superview;

    //    static NSMutableArray *selfConstraints;
    //    if (selfConstraints) {
    //        [container removeConstraints:selfConstraints];
    //        [selfConstraints removeAllObjects];
    //    }else {
    //        selfConstraints = [NSMutableArray array];
    //    }

    NSMutableArray *constraints = [NSMutableArray array];
    // Leading
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:thisView
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:container
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1
                                                                          constant:0];
    [constraints addObject:leadingConstraint];
    // Top
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:thisView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:container
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:0];
    [constraints addObject:topConstraint];
    // Trailing
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:thisView
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:container
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1
                                                                           constant:0];
    [constraints addObject:trailingConstraint];
    // Bottom
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:thisView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:container
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:0];
    [constraints addObject:bottomConstraint];

    [container addConstraints:constraints];
}

- (void)addConstraintsForAroundSuperviewWithLeadingSpace:(CGFloat)leadingSpace
                                                topSpace:(CGFloat)topSpace
                                           trailingSpace:(CGFloat)trailingSpace
                                             bottomSpace:(CGFloat)bottomSpace {
    if (!self.superview) {
        return;
    }

    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.superview
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1.0f
                                                                   constant:leadingSpace];
    [self.superview addConstraint:constraint];

    constraint = [NSLayoutConstraint constraintWithItem:self
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.superview
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:topSpace];
    [self.superview addConstraint:constraint];

    constraint = [NSLayoutConstraint constraintWithItem:self
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.superview
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0f
                                               constant:trailingSpace];
    [self.superview addConstraint:constraint];

    constraint = [NSLayoutConstraint constraintWithItem:self
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.superview
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                               constant:bottomSpace];
    [self.superview addConstraint:constraint];
}

- (void)addConstraintForLeadingSpace:(CGFloat)space view:(UIView *)view priority:(UILayoutPriority)priority {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1.0f
                                                                   constant:space];
    constraint.priority = priority;
    [view addConstraint:constraint];
}

- (void)addConstraintForTopSpace:(CGFloat)space view:(UIView *)view priority:(UILayoutPriority)priority {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0f
                                                                   constant:space];
    constraint.priority = priority;
    [view addConstraint:constraint];
}

- (void)addConstraintForTrailingSpace:(CGFloat)space view:(UIView *)view priority:(UILayoutPriority)priority {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeTrailing
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0f
                                                                   constant:space];
    constraint.priority = priority;
    [view addConstraint:constraint];
}

- (void)addConstraintForBottomSpace:(CGFloat)space view:(UIView *)view priority:(UILayoutPriority)priority {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0f
                                                                   constant:space];
    constraint.priority = priority;
    [view addConstraint:constraint];
}

- (void)addConstraintForFixedWidth:(CGFloat)width priority:(UILayoutPriority)priority {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0f
                                                                   constant:width];
    constraint.priority = priority;
    [self addConstraint:constraint];
}

- (void)addConstraintForFixedHeight:(CGFloat)height priority:(UILayoutPriority)priority {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0f
                                                                   constant:height];
    constraint.priority = priority;
    [self addConstraint:constraint];
}

- (void)layoutAroundSuperview{
//    UIView *view = self;
//    UIView *superview = view.superview;
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(superview.mas_leading).offset(0.0f);
//        make.top.equalTo(superview.mas_top).offset(0.0f);
//        make.trailing.equalTo(superview.mas_trailing).offset(0.0f);
//        make.bottom.equalTo(superview.mas_bottom).offset(0.0f);
//    }];
}
@end






