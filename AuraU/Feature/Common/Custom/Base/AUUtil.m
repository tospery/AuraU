//
//  AUUtil.m
//  AuraU
//
//  Created by Thundersoft on 15/3/17.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUUtil.h"
#import "GDataXMLNode.h"


@implementation AUUtil
+ (GDataXMLDocument *)genDownloadRequestBody:(GDataXMLDocument *)xml {
    NSString *identifier;
    NSString *sourceURL;
    NSString *type;
    NSString *path;

    NSArray *arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/FileCopy/FileList/FileItem" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        sourceURL = [[ele1 attributeForName:@"SourceURL"] stringValue];
        NSString *cdata  = [ele1 stringValue];
        NSRange range1 = [cdata rangeOfString:@">Path<"];
        NSRange range2 = [cdata rangeOfString:@">Length<"];
        path = [cdata substringWithRange:NSMakeRange(range1.location + range1.length,
                                                     range2.location - range1.location - range1.length)];

        range1 = [cdata rangeOfString:@"Type<"];
        range2 = [cdata rangeOfString:@">ID<"];
        type = [cdata substringWithRange:NSMakeRange(range1.location + range1.length,
                                                     range2.location - range1.location - range1.length)];

        range1 = [cdata rangeOfString:@">ID<"];
        range2 = [cdata rangeOfString:@">Path<"];
        identifier = [cdata substringWithRange:NSMakeRange(range1.location + range1.length,
                                                           range2.location - range1.location - range1.length)];
        break;
    }

    GDataXMLNode *downloadCData = [GDataXMLNode createCData:path];

    GDataXMLElement *downloadElement = [GDataXMLNode elementWithName:@"Download"];
    GDataXMLElement *idAttr = [GDataXMLNode attributeWithName:@"ID" stringValue:identifier];
    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:type];
    GDataXMLElement *isThumbnailAttr = [GDataXMLNode attributeWithName:@"IsThumbnail" stringValue:@"False"];
    [downloadElement addAttribute:idAttr];
    [downloadElement addAttribute:typeAttr];
    [downloadElement addAttribute:isThumbnailAttr];
    [downloadElement addChild:downloadCData];


    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:downloadElement];

    // YJX_TODO
    NSString *downloadString = [[NSString alloc] initWithData:[xmlDoc XMLData] encoding:NSUTF8StringEncoding];
    NSLog(@"downloadString = %@", downloadString);

    return xmlDoc;
}


+ (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
                       fileData:(NSData *)fileData
                       fileName:(NSString *)fileName
                customAlbumName:(NSString *)customAlbumName
                      mediaType:(k_MediaType)mediaType
                completionBlock:(void (^)(void))completionBlock
                   failureBlock:(void (^)(NSError *error))failureBlock
{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        __block ALAssetsLibrary *blockSelf = assetsLibrary;
        void (^AddAsset)(ALAssetsLibrary *, NSURL *) = ^(ALAssetsLibrary *assetsLibrary, NSURL *assetURL) {
            [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                [assetsLibrary enumerateGroupsWithTypes:(ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos) usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:customAlbumName]) {
                        [group addAsset:asset];
                        if (completionBlock) {
                            completionBlock();
                        }
                    }
                } failureBlock:^(NSError *error) {
                    if (failureBlock) {
                        failureBlock(error);
                    }
                }];
            } failureBlock:^(NSError *error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        };
        if (mediaType == MediaPhtot || mediaType == PhotoMerge) {
            [assetsLibrary writeImageDataToSavedPhotosAlbum:fileData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
                if (customAlbumName) {
                    [assetsLibrary addAssetsGroupAlbumWithName:customAlbumName resultBlock:^(ALAssetsGroup *group) {
                        if (group) {
                            [blockSelf assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                                [group addAsset:asset];
                                if (completionBlock) {
                                    completionBlock();
                                }
                            } failureBlock:^(NSError *error) {
                                if (failureBlock) {
                                    failureBlock(error);
                                }
                            }];
                        } else {
                            AddAsset(blockSelf, assetURL);
                        }
                    } failureBlock:^(NSError *error) {
                        AddAsset(blockSelf, assetURL);
                    }];
                } else {
                    if (completionBlock) {
                        completionBlock();
                    }
                }
            }];
        } else {

            NSString *strFilePath = [NSString stringWithFormat:@"%@/%@",[AUSerialization getFileVideo],[[fileName componentsSeparatedByString:@"/"] lastObject]];
            if(![[NSFileManager defaultManager] fileExistsAtPath:strFilePath])
            {
                [fileData writeToFile:strFilePath atomically:YES];
            }
            [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:strFilePath]
                                              completionBlock:^(NSURL *assetURL, NSError *error) {

                                                  if (error) {
                                                      NSLog(@"Save video fail:%@",error);
                                                      if (failureBlock) {
                                                          failureBlock(error);
                                                      }
                                                  } else {
                                                      NSLog(@"Save video succeed.");
                                                      if([[NSFileManager defaultManager] fileExistsAtPath:strFilePath])
                                                      {
                                                          NSError *err;
                                                          [[NSFileManager defaultManager] removeItemAtPath:strFilePath error:&err];
                                                      }

                                                      if (completionBlock) {
                                                          completionBlock();
                                                      }
                                                  }
                                              }];

        }
    });


}

@end
