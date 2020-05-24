//
//  AUSerialization.m
//  AuraU
//
//  Created by Army on 15-3-1.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUSerialization.h"

@implementation AUSerialization

+ (NSString *)getFileDocument
{

    NSString *fileName = kDocumentName;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentLibraryFolderPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:documentLibraryFolderPath]) {
        [fm createDirectoryAtPath:documentLibraryFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return documentLibraryFolderPath;
}

+ (NSString *)getFilePhoto
{
    NSString *fileName = [self getFileDocument];
    fileName = [fileName stringByAppendingPathComponent:file_Images];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:fileName]) {
        [fm createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fileName;
}

+ (NSString *)getFileVideo
{
    NSString *fileName = [self getFileDocument];
    fileName = [fileName stringByAppendingPathComponent:file_Video];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:fileName]) {
        [fm createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fileName;
}

+ (NSString *)getFileMusic
{
    NSString *fileName = [self getFileDocument];
    fileName = [fileName stringByAppendingPathComponent:file_Music];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:fileName]) {
        [fm createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fileName;
}

+ (NSString *)getFileCapture
{
    NSString *fileName = [self getFileDocument];
    fileName = [fileName stringByAppendingPathComponent:file_Capture];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:fileName]) {
        [fm createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fileName;
}

+ (NSString *)getFileNormal
{
    NSString *fileName = [self getFileDocument];
    fileName = [fileName stringByAppendingPathComponent:file_normal];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:fileName]) {
        [fm createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fileName;
}

@end
