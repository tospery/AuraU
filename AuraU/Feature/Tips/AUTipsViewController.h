//
//  AUTipsViewController.h
//  AuraU
//
//  Created by Thundersoft on 15/4/13.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AUTipsViewControllerType){
    AUTipsViewControllerTypeUnopened,
    AUTipsViewControllerTypeUnconnected,
    AUTipsViewControllerTypeFailure
};

@interface AUTipsViewController : UIViewController
@property (nonatomic, assign) AUTipsViewControllerType type;

- (void)setReconnectBlock:(void(^)())reconnectBlock;
@end
