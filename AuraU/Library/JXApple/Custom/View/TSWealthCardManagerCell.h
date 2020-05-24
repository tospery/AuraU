//
//  TSWealthCardManagerCell.h
//  CMBCEcosphere
//
//  Created by Thundersoft on 10/6/14.
//  Copyright (c) 2014 Zhou , Hongjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBannerView.h"

@class TSManager;

@interface TSWealthCardManagerCell : UITableViewCell
@property (strong, nonatomic) TSManager *manager;
@property (strong, nonatomic) IBOutlet JXBannerView *adScrollView;

+ (CGFloat)height;
+ (NSString *)identifier;
@end
