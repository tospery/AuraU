//
//  AUHomeViewController.h
//  AuraU
//
//  Created by Thundersoft on 15/2/15.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AUCapture.h"

typedef NS_ENUM(NSInteger, AUHomeTipsType){
    AUHomeTipsTypeNone,
    AUHomeTipsTypeUnopened,
    AUHomeTipsTypeUnconnected,
    AUHomeTipsTypeFailure,
};

@interface AUHomeViewController : UIViewController <UIScrollViewDelegate, AUCaptureDeleagate>
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end
