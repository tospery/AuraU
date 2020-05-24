//
//  AUNetHTTPConnection.m
//  AuraU
//
//  Created by Thundersoft on 15/3/5.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUNetHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPResponse.h"
#import "GDataXMLNode.h"
#import "HTTPFileResponse.h"
#import "HTTPDataResponse.h"
#import "AUMetadataItem.h"
#import "AUNetHTTPFileResponse.h"

//static NSMutableDictionary *fileDict;
static AUMetadataItemType filetype;
static NSString *filename;
static NSString *isThumbnail;

@interface AUNetHTTPConnection ()
@end

@implementation AUNetHTTPConnection
- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path   {
    // Add support for POST
    if ([method isEqualToString:@"POST"]) {
        return YES;
    }
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
    if ([method isEqualToString:@"POST"]) {
        return YES;
    }
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
//    if (!fileDict) {
//        fileDict = [NSMutableDictionary dictionary];
//    }

    //DDLogInfo(@"method = %@, path = %@, %@, filename = %@", method, path, [NSDate date], filename);
    if ([method isEqualToString:@"POST"] && [path hasPrefix:@"/file"]) {
        NSString *subDir;
        NSString *fn = filename;
        if ([isThumbnail compare:@"False" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            if (AUMetadataItemTypePhoto == filetype) {
                __block NSString *strPath;
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [gAU setWriteImage:fn successCallBackCompletion:^(NSString *path) {
                        strPath = path;
                        dispatch_semaphore_signal(sema);
                    }];
                });
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

                if (strPath) {
                    DDLogInfo(@"使用原图");
                    return [[HTTPFileResponse alloc] initWithFilePath:strPath forConnection:self];
                }else {
                    DDLogInfo(@"使用缩略图");
                    subDir = file_Images;
                }
            }else if (AUMetadataItemTypeMusic == filetype) {
                subDir = file_Music;
                fn = [[filename componentsSeparatedByString:@"/"] lastObject];
            }else if (AUMetadataItemTypeVideo == filetype) {
                subDir = file_Video;
                fn = [[filename componentsSeparatedByString:@"/"] lastObject];
            } else if (AUMetadataItemTypeMerge == filetype || AUMetadataItemTypeFaceScan == filetype) {
                subDir = file_Capture;
            }
        }else {
            if (filetype == AUMetadataItemTypeMusic ||
                filetype == AUMetadataItemTypeVideo) {
                subDir = file_normal;
                fn = [[filename componentsSeparatedByString:@"/"] lastObject];
                if (![fn isEqualToString:file_CapName]) {
                    fn = [NSString stringWithFormat:@"%@.jpg", fn];
                }
            }else {
                subDir = (filetype == AUMetadataItemTypePhoto ? file_Images : file_normal);
                if ((filetype != AUMetadataItemTypePhoto) &&
                    (![filename isEqualToString:file_CapName])) {
                    fn = [NSString stringWithFormat:@"%@.jpg", filename];
                }
            }
        }


        // NSString *subDir = (filetype == AUMetadataItemTypePhoto ? file_Images : file_Capture);
        NSString *filepath = [[NSString alloc] initWithFormat:@"%@/%@%@", [config documentRoot], subDir, fn];
        NSLog(@"%s【POST】: filepath = %@", __func__, filepath);

        return [[HTTPFileResponse alloc] initWithFilePath:filepath forConnection:self];
    }

    if ([method isEqualToString:@"GET"] && [path hasPrefix:@"/streaming"]) {
        NSString *filepath = [[NSString alloc] initWithFormat:@"%@%@", [config documentRoot], [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSArray *array = [filepath componentsSeparatedByString:@"/"];
        NSString *idandaura = [array objectAtIndex:(array.count - 2)];
        idandaura = [NSString stringWithFormat:@"%@/", idandaura];
        filepath = [filepath stringByReplacingOccurrencesOfString:idandaura withString:@""];
        DDLogInfo(@"%s【GET】: filepath = %@", __func__, filepath);

        AUNetHTTPFileResponse *response = [[AUNetHTTPFileResponse alloc] initWithFilePath:filepath forConnection:self];
        if (!response) {
            NSLog(@"Error!");
            return [super httpResponseForMethod:method URI:path];
        }
        return response;
    }

    return [super httpResponseForMethod:method URI:path];
}

- (NSData *)preprocessResponse:(HTTPMessage *)response {
    return [super preprocessResponse:response];
}

- (NSData *)preprocessErrorResponse:(HTTPMessage *)response {
    return [super preprocessErrorResponse:response];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength {
}

- (void)processBodyData:(NSData *)postDataChunk {
    NSString *xml = [[NSString alloc] initWithData:postDataChunk encoding:NSUTF8StringEncoding];
    //NSLog(@"%s: HTTP Request = %@, allHeaderFields = %@", __func__, xml, [request allHeaderFields]);
    DDLogInfo(@"%s: HTTP Request = %@", __func__, xml);

    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
    if (!doc) {
        return;
    }

    NSArray *arr1 = [doc nodesForXPath:@"//Download" error:nil];
    NSString *type;
    for (GDataXMLElement *ele1 in arr1) {
        filename = [ele1 stringValue];
        type = [ele1 attributeForName:@"Type"].stringValue;

        isThumbnail = [ele1 attributeForName:@"IsThumbnail"].stringValue;
        if (filename) {
            break;
        }
    }
    filetype = [[AUMetadataItem typeRepresents] indexOfObject:type];
}
@end
