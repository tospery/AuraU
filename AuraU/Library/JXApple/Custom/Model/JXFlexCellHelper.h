//
//  JXFlexCellHelper.h
//  MyTable01（可折叠Cell的实现）
//
//  Created by 杨建祥 on 14/12/14.
//  Copyright (c) 2014年 杨建祥. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJXFlexCellHelperHeightFixed                      (@"kJXFlexCellHelperHeightFixed")
#define kJXFlexCellHelperHeightCollapsed                  (@"kJXFlexCellHelperHeightCollapsed")
#define kJXFlexCellHelperHeightExpanded                   (@"kJXFlexCellHelperHeightExpanded")


typedef NS_ENUM(NSInteger, JXFlexCellHelperMode) {
    JXFlexCellHelperModeFixed,
    JXFlexCellHelperModeCollapsed,
    JXFlexCellHelperModeExpanded
};

@interface JXFlexCellHelper : NSObject
@property (nonatomic, assign, readonly) JXFlexCellHelperMode mode;
@property (nonatomic, strong, readonly) NSDictionary *heightDict;

- (instancetype)initWithMode:(JXFlexCellHelperMode)mode
                 fixedHeight:(CGFloat)fixedHeight
             collapsedHeight:(CGFloat)collapsedHeight
              expandedHeight:(CGFloat)expandedHeight;
- (void)reverseMode;
@end
