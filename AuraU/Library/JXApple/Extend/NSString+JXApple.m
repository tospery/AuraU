//
//  NSString+JXApple.m
//  MyiOS
//
//  Created by Thundersoft on 10/20/14.
//  Copyright (c) 2014 Thundersoft. All rights reserved.
//

#import "NSString+JXApple.h"
#import <CoreLocation/CoreLocation.h>

@implementation NSString (JXApple)
// TODO 重新实现该方法
+ (NSString *)getDistanceWithLatitude:(double)latitude longitude:(double)longitude
{
    CLLocationCoordinate2D lo =CLLocationCoordinate2DMake(latitude,longitude);
    CLLocation *loLocation = [[CLLocation alloc] initWithLatitude:lo.latitude longitude:lo.longitude];
    CLLocation *toLocation = [[CLLocation alloc] initWithLatitude:/*g_coordinate.latitude*/latitude longitude:/*g_coordinate.longitude*/longitude];
    CLLocationDistance dis = [loLocation distanceFromLocation:toLocation];

    if (dis >= 1000)
        return [NSString stringWithFormat:@"%0.0fkm",dis/1000];
    else
        return [NSString stringWithFormat:@"%0.0fm",dis];
}

- (NSNumber *)lengthAsNumber {
    NSUInteger length = self.length;
    return ([NSNumber numberWithUnsignedInteger:length]);
}

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

- (CGSize)exSizeWithFont:(UIFont *)font width:(CGFloat)width {
    CGSize result = CGSizeZero;
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *textParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        textParagraphStyle.alignment = NSTextAlignmentLeft;
        textParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        result = [self boundingRectWithSize:CGSizeMake(width, UINT16_MAX)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSFontAttributeName: font,
                                              NSParagraphStyleAttributeName: textParagraphStyle}
                                    context:nil].size;
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font
                  constrainedToSize:CGSizeMake(width, UINT16_MAX)
                      lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    }
    return result;
}

- (NSString *)deleteSpecialCharacterInFix:(NSString *)specialCharacter {
    NSMutableString *temp = [NSMutableString stringWithString:self];
    while (YES) {
        if ([temp hasPrefix:specialCharacter]) {
            [temp deleteCharactersInRange:NSMakeRange(0, 1)];
        }else {
            break;
        }
    }
    while (YES) {
        if ([temp hasSuffix:specialCharacter]) {
            [temp deleteCharactersInRange:NSMakeRange(temp.length - 1, 1)];
        }else {
            break;
        }
    }

    return temp;
}

- (NSString *)replaceUnicodeValue {
    NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

- (NSString *)substringToIndexSafely:(NSUInteger)to {
    if (self.length < to) {
        return self;
    }
    return [self substringToIndex:to];
}

- (NSUInteger)lengthInByte {
    NSUInteger bytes = 0;
    NSUInteger unicodes = self.length;

    NSRange range;
    NSString *uString;
    const char *cString;
    for (NSUInteger i = 0; i < unicodes; ++i) {
        range = NSMakeRange(i, 1);
        uString = [self substringWithRange:range];
        cString = [uString UTF8String];
        if (cString == NULL || strlen(cString) == 1 ) {
            ++bytes;
        }else {
            bytes += 2;
        }
    }
    return bytes;
}

- (NSString *)substringByBytes:(NSUInteger)count {
    NSUInteger bytes = [self lengthInByte];
    if (count >= bytes) {
        return self;
    }

    NSUInteger i = 0;
    NSUInteger unicodes = self.length;
    NSUInteger remaining = count;

    NSRange range;
    NSString *uString;
    const char *cString;
    for (; i < unicodes && remaining > 0; ++i) {
        range = NSMakeRange(i, 1);
        uString = [self substringWithRange:range];
        cString = [uString UTF8String];
        if (cString == NULL || strlen(cString) == 1) {
            --remaining;
        }else {
            if (1 == remaining) {
                break;
            }
            remaining -= 2;
        }
    }

    return [self substringToIndex:i];
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)exHexToDec {
    return JXIntToString(strtoul([self UTF8String], 0, 16));
}

- (void)exDrawInRect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment {
    if ([self respondsToSelector:@selector(drawWithRect:options:attributes:context:)]) {
        NSMutableParagraphStyle *textParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        textParagraphStyle.alignment = alignment;
        textParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;

        [self drawWithRect:rect
                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                attributes:@{NSFontAttributeName: font,
                             NSParagraphStyleAttributeName: textParagraphStyle,
                             NSForegroundColorAttributeName: color}
                   context:nil];
    }else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self drawInRect:rect
                 withFont:font
            lineBreakMode:NSLineBreakByWordWrapping
                alignment:alignment];
#pragma clang diagnostic pop
    }
}

+ (NSString *)stringWithFilename:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    return [documents stringByAppendingPathComponent:filename];
}
@end

















