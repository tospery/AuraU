//
//  AUUtil.h
//  AuraU
//
//  Created by Thundersoft on 15/3/17.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GDataXMLDocument;

@interface AUUtil : NSObject

+ (GDataXMLDocument *)genDownloadRequestBody:(GDataXMLDocument *)xml;

+ (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
                       fileData:(NSData *)fileData
                       fileName:(NSString *)fileName
                customAlbumName:(NSString *)customAlbumName
                      mediaType:(k_MediaType)mediaType
                completionBlock:(void (^)(void))completionBlock
                   failureBlock:(void (^)(NSError *error))failureBlock;

@end
