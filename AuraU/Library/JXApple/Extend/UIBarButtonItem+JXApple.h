//
//  UIBarButtonItem+JXApple.h
//  MyiOS
//
//  Created by Thundersoft on 10/20/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJXBarButtonItemIconNormal                  (@"kJXBarButtonItemIconNormal")
#define kJXBarButtonItemIconHighlighted             (@"kJXBarButtonItemIconHighlighted")
#define kJXBarButtonItemIconDisabled                (@"kJXBarButtonItemIconDisabled")
#define kJXBarButtonItemIconSelected                (@"kJXBarButtonItemIconSelected")


@interface UIBarButtonItem (JXApple)
+ (UIBarButtonItem *)genWithImage:(UIImage *)image target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)genWithImages:(NSDictionary *)images target:(id)target action:(SEL)action;
@end
