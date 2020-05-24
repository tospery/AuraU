//
//  UIImage+JXApple.m
//  MyiOS
//
//  Created by Thundersoft on 10/20/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import "UIImage+JXApple.h"
#import "JXApple.h"

@implementation UIImage (JXApple)
+ (UIImage *)genWithColor:(UIColor *)color {
    CGSize imageSize = CGSizeMake(1, 1);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)drawText:(NSString *)text font:(UIFont *)font color:(UIColor *)color size:(CGSize)size {
    CGRect textRect;
    CGSize standardSize = [kStringNone exSizeWithFont:font width:size.width];
    CGSize textSize = [text exSizeWithFont:font width:size.width];
    if (textSize.height > standardSize.height) {
        textRect.origin.x = 0;
        textRect.origin.y = (size.height - textSize.height) / 2.0;
        textRect.size.width = size.width;
        textRect.size.height = textSize.height;
    }else {
        textRect.origin.x = (size.width - textSize.width) / 2.0;
        textRect.origin.y = size.height / 2.0 - textSize.height;
        textRect.size.width = textSize.width;
        textRect.size.height = textSize.height;
    }


    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [color set];
    [text exDrawInRect:textRect
                  font:font
                 color:color
             alignment:NSTextAlignmentLeft];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (UIImage *)scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)exStretchCenter {
    return [self stretchableImageWithLeftCapWidth:self.size.width * 0.5
                                     topCapHeight:self.size.height * 0.5];
}
@end
