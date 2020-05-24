//
//  TSWealthCardManagerView.h
//  CMBCEcosphere
//
//  Created by Thundersoft on 10/6/14.
//  Copyright (c) 2014 Zhou , Hongjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSWealthCardManagerView;

@protocol TSWealthCardManagerViewDelegate <NSObject>
@required
- (void)managerView:(TSWealthCardManagerView *)view didSelectGotoHere:(/*CLLocationCoordinate2D*/double)coordinate;
- (void)managerView:(TSWealthCardManagerView *)view didSelectCallManager:(NSString *)phone;
@end

@class TSManager;

@interface TSWealthCardManagerView : UIView
//@property (strong, nonatomic) TSManager *manager;
//
//@property (weak, nonatomic) id<TSWealthCardManagerViewDelegate>  delegate;
@end
