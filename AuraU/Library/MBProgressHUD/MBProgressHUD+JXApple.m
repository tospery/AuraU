//
//  MBProgressHUD+JXApple.m
//  MBProgressHUDTutorial
//
//  Created by Thundersoft on 15/3/18.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "MBProgressHUD+JXApple.h"

@implementation MBProgressHUD (JXApple)
+ (MB_INSTANCETYPE)showHUDAddedTo:(UIView *)view
                         animated:(BOOL)animated
                     hideAnimated:(BOOL)hideAnimated
                        hideDelay:(NSTimeInterval)hideDelay
                             mode:(MBProgressHUDMode)mode
                             type:(MBProgressHUDType)type
                       customView:(UIView *)customView
                        labelText:(NSString *)labelText
                 detailsLabelText:(NSString *)detailsLabelText
                           square:(BOOL)square
                    dimBackground:(BOOL)dimBackground
                            color:(UIColor *)color
        removeFromSuperViewOnHide:(BOOL)removeFromSuperViewOnHide
                        labelFont:(CGFloat)labelFont
                 detailsLabelFont:(CGFloat)detailsLabelFont {
    [[self class] hideAllHUDsForView:view animated:YES];

    MBProgressHUD *hud = [[self alloc] initWithView:view];

    hud.mode = mode;
    hud.customView = customView;
    if (type >= 1 && type <= 3) {
        hud.mode = MBProgressHUDModeCustomView;
        NSString *typeImageName = [[NSString alloc] initWithFormat:@"ic_symbol_hud%ld", (long)type];
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:typeImageName]];
    }
    hud.labelText = labelText;
    hud.detailsLabelText = detailsLabelText;
    hud.square = square;
    hud.dimBackground = dimBackground;
    hud.color = color;
    hud.removeFromSuperViewOnHide = removeFromSuperViewOnHide;
    hud.labelFont = [UIFont boldSystemFontOfSize:labelFont];
    hud.detailsLabelFont = [UIFont boldSystemFontOfSize:detailsLabelFont];

    [view addSubview:hud];
    [hud show:animated];
    if (hideDelay > 0) {
        [hud hide:hideAnimated afterDelay:hideDelay];
    }

    return hud;
}

+ (MB_INSTANCETYPE)exShowHUDProcessingWithMessage:(NSString *)message
                                           detail:(NSString *)detail
              whileExecutingBlock:(dispatch_block_t)block
                  completionBlock:(MBProgressHUDCompletionBlock)completion {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [[self class] hideAllHUDsForView:window animated:YES];

    MBProgressHUD *hud = [[self alloc] initWithView:window];
    hud.labelText = message;
    hud.labelFont = [UIFont boldSystemFontOfSize:18];
    hud.detailsLabelText = detail;
    hud.detailsLabelFont = [UIFont boldSystemFontOfSize:14];
    [window addSubview:hud];

    [hud showAnimated:YES
  whileExecutingBlock:^{
      if (block) {
          block();
      }
  } completionBlock:^{
      if (completion) {
          completion();
      }
  }];

    return hud;
}
@end
