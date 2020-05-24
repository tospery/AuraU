//
//  JXInputLimit.h
//  UE05_InputLimit（输入限制）
//
//  Created by 杨建祥 on 15/1/9.
//  Copyright (c) 2015年 杨建祥. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JXInputLimitType){
    JXInputLimitTypeCompatible = 0,         // 不区分
    JXInputLimitTypeDistinguish             // 1个汉字占2个字符
};

@interface UITextField (JXInputLimitCategory)
- (void)exSetupLimit:(NSUInteger)limit;
@end

@interface UITextView (JXInputLimitCategory)
- (void)exSetupLimit:(NSUInteger)limit;
@end

@interface JXInputLimit : NSObject
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) JXInputLimitType type;

- (void)setupExceedBlock:(void(^)(UIView *inputView, NSUInteger exceed))exceedBlock countBlock:(void(^)(UIView *inputView, NSUInteger count))countBlock;
+ (JXInputLimit *) sharedInstance;
@end
