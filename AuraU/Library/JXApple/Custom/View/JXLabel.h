//
//  JXLabel.h
//  MyiOS
//
//  Created by Thundersoft on 10/20/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

// TODO 需重新设计该类
typedef NS_ENUM(NSInteger, JXLabelLineType) {
    JXLabelLineTypeNone,        // 无划线
    JXLabelLineTypeUp,          // 上划线
    JXLabelLineTypeMiddle,      // 中划线
    JXLabelLineTypeDown,        // 下划线
    JXLabelLineTypeAround       // 周围划线
};

@class JXLabel;

@protocol JXLabelDelegate <NSObject>
@optional
- (void)label:(JXLabel *)label didSelected:(BOOL)aaa;
@end


@interface JXLabel : UILabel
@property (assign, nonatomic) JXLabelLineType lineType;
@property (strong, nonatomic) UIColor *lineColor;

@property (weak) id<JXLabelDelegate> delegate;
@end
