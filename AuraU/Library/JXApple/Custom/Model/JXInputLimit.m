//
//  JXInputLimit.m
//  UE05_InputLimit（输入限制）
//
//  Created by 杨建祥 on 15/1/9.
//  Copyright (c) 2015年 杨建祥. All rights reserved.
//

#import "JXInputLimit.h"
#import "JXApple.h"
#import <objc/runtime.h>

#define kLimitKey        @"kJXInputLimitKey"

static NSMutableDictionary *limitDict;

@implementation UITextField (JXInputLimitCategory)
- (id)valueForUndefinedKey:(NSString *)key {
    if ([key isEqualToString:kLimitKey]) {
        if (!JXiOSVersionGreaterThanOrEqual(7.0)) {
            return [limitDict objectForKey:[NSString stringWithFormat:@"%p", self]];
        }else {
            return objc_getAssociatedObject(self, key.UTF8String);
        }
    }
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:kLimitKey]) {
        if (!JXiOSVersionGreaterThanOrEqual(7.0)) {
            [limitDict setObject:value forKey:[NSString stringWithFormat:@"%p", self]];
        }else {
            objc_setAssociatedObject(self, key.UTF8String, value, OBJC_ASSOCIATION_RETAIN);
        }
    }
}

- (void)exSetupLimit:(NSUInteger)limit {
    [self setValue:[NSNumber numberWithUnsignedInteger:limit] forKey:kLimitKey];
}

//- (void)clearLimit {
//    [limitDict removeObjectForKey:[NSString stringWithFormat:@"%p", self]];
//}
@end


@implementation UITextView (JXInputLimitCategory)
- (id)valueForUndefinedKey:(NSString *)key {
    if ([key isEqualToString:kLimitKey]) {
        if (!JXiOSVersionGreaterThanOrEqual(7.0)) {
            return [limitDict objectForKey:[NSString stringWithFormat:@"%p", self]];
        }else {
            return objc_getAssociatedObject(self, key.UTF8String);
        }
    }
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:kLimitKey]) {
        if (!JXiOSVersionGreaterThanOrEqual(7.0)) {
            [limitDict setObject:value forKey:[NSString stringWithFormat:@"%p", self]];
        }else {
            objc_setAssociatedObject(self, key.UTF8String, value, OBJC_ASSOCIATION_RETAIN);
        }
    }
}

- (void)exSetupLimit:(NSUInteger)limit {
    [self setValue:[NSNumber numberWithUnsignedInteger:limit] forKey:kLimitKey];
}

//- (void)clearLimit {
//    [limitDict removeObjectForKey:[NSString stringWithFormat:@"%p", self]];
//}
@end


@interface JXInputLimit ()
@property (nonatomic, copy) void(^exceedBlock)(UIView *inputView, NSUInteger exceed);
@property (nonatomic, copy) void(^countBlock)(UIView *inputView, NSUInteger count);
@end

@implementation JXInputLimit
+ (void)load {
    [super load];
    if (!JXiOSVersionGreaterThanOrEqual(7.0)) {
        limitDict = [NSMutableDictionary dictionary];
    }
    [JXInputLimit sharedInstance];
}

+ (JXInputLimit *)sharedInstance {
    static JXInputLimit *sInputLimit;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInputLimit = [[JXInputLimit alloc] init];
    });
    
    return sInputLimit;
}

- (id)init {
    if (self = [super init]) {
        self.enable = YES;
    }
    return self;
}

- (void)setEnable:(BOOL)enable {
    if (_enable == enable) {
        return;
    }
    
    if (enable) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidChange:) name:UITextFieldTextDidChangeNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange:) name:UITextViewTextDidChangeNotification object: nil];
    }else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    _enable = enable;
}

- (void)setupExceedBlock:(void(^)(UIView *inputView, NSUInteger exceed))exceedBlock
              countBlock:(void(^)(UIView *inputView, NSUInteger count))countBlock {
    if (!JXiOSVersionGreaterThanOrEqual(7.0) && !exceedBlock && !countBlock) {
        [limitDict removeAllObjects];
    }
    
    _exceedBlock = exceedBlock;
    _countBlock = countBlock;
}

- (void)textFieldViewDidChange:(NSNotification*)notification {
    UITextField *textField = (UITextField *)notification.object;
    
    NSNumber *number;
    if (!JXiOSVersionGreaterThanOrEqual(7.0)) {
        number = [limitDict objectForKey:[NSString stringWithFormat:@"%p", textField]];
    }else {
        number = [textField valueForKey:kLimitKey];
    }
    if (!number) {
        return;
    }
    
    UITextRange *textRange = textField.markedTextRange;
    if (textRange) {
        return;
    }
    
    NSUInteger limit = number.unsignedIntegerValue;
    NSUInteger chars;
    if (JXInputLimitTypeDistinguish == _type) {
        chars = [textField.text lengthInByte];
    }else {
        chars = textField.text.length;
    }
    if (chars > limit) {
        NSInteger adjust = limit;
        if (chars == limit + 1) {
            NSString *subString = [textField.text substringWithRange:NSMakeRange(limit - 1, 1)];
            const char *cString = [subString UTF8String];
            if (NULL == cString) {
                adjust -= 1;
            }
        }

        if (JXInputLimitTypeDistinguish == _type) {
            textField.text = [textField.text substringByBytes:adjust];
        }else {
            textField.text = [textField.text substringToIndex:adjust];
        }

        if (_exceedBlock) {
            _exceedBlock(textField, limit);
        }
    }
    
    if (JXInputLimitTypeDistinguish == _type) {
        chars = [textField.text lengthInByte];
    }else {
        chars = textField.text.length;
    }
    
    if (_countBlock) {
        _countBlock(textField,chars);
    }
}

- (void)textViewDidChange:(NSNotification *)notification {
    UITextView *textView = (UITextView *)notification.object;
    
    NSNumber *number;
    if (!JXiOSVersionGreaterThanOrEqual(7.0)) {
        number = [limitDict objectForKey:[NSString stringWithFormat:@"%p", textView]];
    }else {
        number = [textView valueForKey:kLimitKey];
    }
    if (!number) {
        return;
    }
    
    UITextRange *textRange = textView.markedTextRange;
    if (textRange) {
        return;
    }
    
    NSUInteger limit = number.unsignedIntegerValue;
    NSUInteger chars;
    if (JXInputLimitTypeDistinguish == _type) {
        chars = [textView.text lengthInByte];
    }else {
        chars = textView.text.length;
    }
    if (chars > limit) {
        NSInteger adjust = limit;
        if (chars == limit + 1) {
            NSString *subString = [textView.text substringWithRange:NSMakeRange(limit - 1, 1)];
            const char *cString = [subString UTF8String];
            if (NULL == cString) {
                adjust -= 1;
            }
        }

        if (JXInputLimitTypeDistinguish == _type) {
            textView.text = [textView.text substringByBytes:adjust];
        }else {
            textView.text = [textView.text substringToIndex:adjust];
        }

        if (_exceedBlock) {
            _exceedBlock(textView, limit);
        }
    }
    
    if (JXInputLimitTypeDistinguish == _type) {
        chars = [textView.text lengthInByte];
    }else {
        chars = textView.text.length;
    }
    
    if (_countBlock) {
        _countBlock(textView, chars);
    }
}
@end
