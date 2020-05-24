//
//  UIBarButtonItem+JXApple.m
//  MyiOS
//
//  Created by Thundersoft on 10/20/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import "UIBarButtonItem+JXApple.h"

@implementation UIBarButtonItem (JXApple)
+ (UIBarButtonItem *)genWithImage:(UIImage *)image target:(id)target action:(SEL)action {
    CGRect frame = CGRectMake(0, 0, 16, 16);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    if(action) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (UIBarButtonItem *)genWithImages:(NSDictionary *)images target:(id)target action:(SEL)action {
    CGRect frame = CGRectMake(0, 0, 20, 20);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;

    [button setBackgroundImage:[images objectForKey:kJXBarButtonItemIconNormal] forState:UIControlStateNormal];
    [button setBackgroundImage:[images objectForKey:kJXBarButtonItemIconHighlighted] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[images objectForKey:kJXBarButtonItemIconDisabled] forState:UIControlStateDisabled];
    [button setBackgroundImage:[images objectForKey:kJXBarButtonItemIconSelected] forState:UIControlStateSelected];

    if(action) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }

    return [[UIBarButtonItem alloc] initWithCustomView:button];
}
@end
