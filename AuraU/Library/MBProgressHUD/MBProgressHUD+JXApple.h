//
//  MBProgressHUD+JXApple.h
//  MBProgressHUDTutorial
//
//  Created by Thundersoft on 15/3/18.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "MBProgressHUD.h"

typedef NS_ENUM(NSInteger, MBProgressHUDType){
    MBProgressHUDTypeNone,
    MBProgressHUDTypeSuccess,
    MBProgressHUDTypeFailure,
    MBProgressHUDTypeTips,
    MBProgressHUDTypeAll
};

@interface MBProgressHUD (JXApple)
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
                 detailsLabelFont:(CGFloat)detailsLabelFont;

+ (MB_INSTANCETYPE)exShowHUDProcessingWithMessage:(NSString *)message
                                           detail:(NSString *)detail
                              whileExecutingBlock:(dispatch_block_t)block
                                  completionBlock:(MBProgressHUDCompletionBlock)completion;
@end
