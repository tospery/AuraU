//
//  UIScrollView+JXApple.m
//  MyiOS
//
//  Created by Thundersoft on 10/18/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import "UIScrollView+JXApple.h"

@implementation UIScrollView (JXApple)
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nextResponder touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nextResponder touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nextResponder touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}
@end
