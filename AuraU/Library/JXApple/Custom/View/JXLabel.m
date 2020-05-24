//
//  JXLabel.m
//  MyiOS
//
//  Created by Thundersoft on 10/20/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import "JXLabel.h"

static CGFloat const lineWidth = 2.0f;
static CGFloat const spaceWithText = 5.0f;

@interface JXLabel ()
@property (strong, nonatomic) UIColor *originalTextColor;
@end

@implementation JXLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.lineType = JXLabelLineTypeNone;
        self.lineColor = [UIColor redColor];
        self.originalTextColor = self.textColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName: self.font}];
    if (JXLabelLineTypeAround == self.lineType) {
        if (NSTextAlignmentCenter == self.textAlignment) {
            [self drawLineAroundTheCenterText:rect textSize:textSize];
        }
    }else if (JXLabelLineTypeDown == self.lineType) {
        [self drawLineDownTheText:rect textSize:textSize];
    }
}

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:rect];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.textColor = [UIColor redColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.textColor = self.originalTextColor;
    if ([self.delegate respondsToSelector:@selector(label:didSelected:)]) {
        [self.delegate label:self didSelected:YES];
    }
}

#pragma mark Private methods
- (void)drawLineAroundTheCenterText:(CGRect)labelRect textSize:(CGSize)textSize
{
    // TODO 当label的边框不足时，自动增长边框大小
    //    CGRect newRect;
    //    CGFloat requiredWidth = textSize.width + 2.0 * spaceWithText + 2.0 * spaceWithText;
    //    if (labelRect.size.width < requiredWidth) {
    //    }

    // 计算区域
    CGFloat x = (labelRect.size.width - textSize.width) / 2.0 - spaceWithText;
    CGFloat y = (labelRect.size.height - textSize.height) / 2.0 - spaceWithText;
    CGFloat width = textSize.width + spaceWithText * 2.0;
    CGFloat heigth = textSize.height + spaceWithText * 2.0;
    CGRect rect = CGRectMake(x, y, width, heigth);
    CGFloat radius = 10.0;
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);

    // 绘制图形
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawLineDownTheText:(CGRect)labelRect textSize:(CGSize)textSize
{
    CGFloat x, y;
    if (NSTextAlignmentLeft == self.textAlignment) {
        x = 0.0f;
    }else if (NSTextAlignmentCenter == self.textAlignment) {
        x = (labelRect.size.width - textSize.width) / 2.0;
    }else{
        x = labelRect.size.width - textSize.width;
    }

    y = (labelRect.size.height - textSize.height) / 2 + textSize.height;
    CGRect lineRect = CGRectMake(x , y, textSize.width, lineWidth);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
    CGContextFillRect(context, lineRect);
}
@end
