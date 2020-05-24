//
//  AUModelObjectBase.m
//  AuraU
//
//  Created by Army on 15-2-12.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUModelObjectBase.h"
#import "AUMetadataItem.h"

@implementation AUPhotoAlbum
+ (AUPhotoAlbum *)sharedPhotoAlbum
{
    static AUPhotoAlbum *photoAlbum = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        photoAlbum = [[AUPhotoAlbum alloc]init];
    });
    return photoAlbum;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.arrayPhotoGruop  = [NSMutableArray array];
    }

    return self;
}


- (void)getAssetsLibraryGroupsObject:(TSAssetsGroupObject *)assetsGroup onBlock:(metadataItemsBlock)block Number50Block:(metadataNumber50Block)metadatablock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.arrayHttpItems = [[NSMutableArray alloc]init];
        static NSInteger startIndex = 100;
        ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result,NSUInteger index, BOOL *stop){
            if (result!=NULL) {
                if ([[result valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypePhoto]) {

                    NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url
                    NSRange range1=[urlstr rangeOfString:@"id="];
                    NSString *resultName=[urlstr substringFromIndex:range1.location+3];
                    resultName=[resultName stringByReplacingOccurrencesOfString:@"&ext=" withString:@"."];//格式demo:123456.png
                    JXDimension *dimension = [JXDimension currentDimension];
                    UIImage *image = nil;
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] < (7.0) && dimension.screenResolution == JXDimensionScreenResolution640x960) {
                        image = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                    } else {
                        image = [UIImage imageWithCGImage:result.defaultRepresentation.fullScreenImage];
                        image = [self transformSize:CGSizeMake(image.size.width / 2, image.size.height / 2) image:image];
                    }

                    NSString *strFilePath = [AUSerialization getFilePhoto];
                    strFilePath = [NSString stringWithFormat:@"%@/%@",strFilePath,assetsGroup.strTitle];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:strFilePath]) {
                        [[NSFileManager defaultManager] createDirectoryAtPath:strFilePath withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    NSString *imagePath = [strFilePath stringByAppendingPathComponent:resultName];

                    NSData *imageData = UIImagePNGRepresentation(image);
                    if(![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
                    {
                        [imageData writeToFile:imagePath atomically:YES];
                    }

                    startIndex ++;
                    if (startIndex == 150 ) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            metadatablock();
                        });
                    }


                }
            } else {
                if (startIndex < 150) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block();
                    });
                }
            }
            
        };
        [assetsGroup.assetsGroup enumerateAssetsUsingBlock:groupEnumerAtion];
    });

}

- (UIImage *)transformSize:(CGSize)size image:(UIImage *)image
{

    CGFloat destW = size.width;
    CGFloat destH = size.height;
    CGFloat sourceW = size.width;
    CGFloat sourceH = size.height;

    CGImageRef imageRef = image.CGImage;
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                destW,
                                                destH,
                                                CGImageGetBitsPerComponent(imageRef),
                                                4*destW,
                                                CGImageGetColorSpace(imageRef),
                                                (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));

    CGContextDrawImage(bitmap, CGRectMake(0, 0, sourceW, sourceH), imageRef);

    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);

    return result;
}

@end

@implementation TSAssetsGroupObject

@synthesize isChoose,strNumber,strTitle,image,assetsGroup,arrayAssect;

@end

@implementation TSMusicObject

@synthesize isChoose,strMusicName,mediaItme,strmusicUrl,albumTitle,artist;

@end


@implementation TSUserObject

@synthesize strUserConnect;

+ (TSUserObject *)sharedUserObject
{
    static TSUserObject *userObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userObject = [[TSUserObject alloc]init];
    });
    return userObject;
}

@end




