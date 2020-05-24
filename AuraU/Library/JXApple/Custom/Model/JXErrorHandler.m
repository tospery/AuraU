//
//  JXErrorHandler.m
//  MySystem02（错误处理）
//
//  Created by 杨建祥 on 15/1/24.
//  Copyright (c) 2015年 杨建祥. All rights reserved.
//

#import "JXErrorHandler.h"
#import "JXApple.h"

static NSMutableArray *sHandlers = nil;

@implementation JXErrorHandler
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        NSInteger recoveryIndex = [[_error localizedRecoveryOptions] indexOfObject:buttonTitle];
        if (NSNotFound != recoveryIndex) {
            if (![[_error recoveryAttempter] attemptRecoveryFromError:_error optionIndex:recoveryIndex]) {
                [JXErrorHandler handleError:_error fatal:_fatal];
            }
        }
    }else {
        if (_fatal) {
            abort();
        }
    }
    
    [sHandlers removeObject:self];
}

#pragma mark - Public methods
- (instancetype)initWithError:(NSError *)error fatal:(BOOL)fatal {
    if (self = [self init]) {
        _fatal = fatal;
        _error = error;
    }
    return self;
}

#pragma mark - Class methods
+ (void)handleError:(NSError *)error fatal:(BOOL)fatal {
    NSString *localizedCancelTitle = kStringDismiss;
    if (fatal) {
        localizedCancelTitle = kStringExit;
    }
    
    JXErrorHandler *handler = [[[self class] alloc] initWithError:error fatal:fatal];
    if (!sHandlers) {
        sHandlers = [[NSMutableArray alloc] init];
    }
    [sHandlers addObject:handler];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:handler
                                              cancelButtonTitle:localizedCancelTitle
                                              otherButtonTitles:nil];
    if ([error recoveryAttempter]) {
        alertView.message = [NSString stringWithFormat:@"%@ %@", alertView.message, error.localizedRecoverySuggestion];
        for (NSString *option in error.localizedRecoveryOptions) {
            [alertView addButtonWithTitle:option];
        }
    }
    [alertView show];
    
    NSLog(@"%@: \n%@, %@", kStringUnhandledError, error, [error userInfo]);
}
@end
