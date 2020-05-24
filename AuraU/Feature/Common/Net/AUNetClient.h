//
//  AUNet.h
//  AuraU
//
//  Created by Thundersoft on 15/2/13.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDataXMLDocument;

typedef NS_ENUM(NSInteger, AUNetClientType){
    AUNetClientTypeNone,
    AUNetClientTypeDeviceConnect,
    AUNetClientTypeDeviceRegister,
    AUNetClientTypeDeviceUserchange,
    AUNetClientTypeDeviceUnregister,
    AUNetClientTypeDeviceHeartbeat,
    AUNetClientTypeMediaQuery,
    AUNetClientTypeShakeStart,
    AUNetClientTypeShakeDelta,
    AUNetClientTypeShakeStop,
    AUNetClientTypeShakeCompleted,
    AUNetClientTypeShakeReset,
    AUNetClientTypeMenuShow,
    AUNetClientTypeMenuHide,
    AUNetClientTypeScanStart,
    AUNetClientTypeScanRetry,
    AUNetClientTypeScanSucceed,
    AUNetClientTypeScanFailed,
    AUNetClientTypeScanStop,
    AUNetClientTypeDetectInit,
    AUNetClientTypeDetectBeginReset,
    AUNetClientTypeDetectEndReset,
    AUNetClientTypeDetectPatternPrepared,
    AUNetClientTypeDetectTakeReady,
    AUNetClientTypeDetectDetectionSuccess,
    AUNetClientTypeDetectDetectionFailed,
    AUNetClientTypeDetectCancelDetection,
    AUNetClientTypeCopyToPhone,
    AUNetClientTypeCopyProcessing,
    AUNetClientTypeCopyCanceled,
    AUNetClientTypeCopyCompleted,
    AUNetClientTypePhotoMerge,
    AUNetClientTypeMergeSucceed,
    AUNetClientTypeAll,
    AUNetClientTypeMergeProcessQuit,
    AUNetClientTypeMergeReject,
    AUNetClientTypeFullUser


};

typedef NS_ENUM(NSInteger, AUNetClientError){
    AUNetClientErrorNone,
    AUNetClientErrorWifiDisconnect = 10000,
    AUNetClientErrorAll
};

@interface AUNetClient : NSObject <GCDAsyncSocketDelegate>
@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, assign) BOOL isDetecting;
@property (nonatomic, assign) BOOL isRegistered;
@property (nonatomic, strong) NSString *detectionCode;
@property (nonatomic, strong) NSString *sourceURL;
@property (nonatomic, strong) NSString *sourcePath;


+ (instancetype)sharedClient;
- (BOOL)isConnected;
- (void)disconnect;

- (void)connect;
- (void)sendDevice:(AUNetClientType)type;
- (void)heartbeat;
- (void)metadataCount:(NSInteger)count;
- (void)metadataList:(NSArray *)list listActionType:(k_MediaActionType)actionType;
- (void)shake:(AUNetClientType)type;
- (void)showMenu:(BOOL)show;
- (void)scan:(AUNetClientType)type taskID:(NSString *)taskID filePath:(NSString *)filePath length:(float)length;
- (void)detect:(AUNetClientType)type code:(NSString *)code;
- (void)copyProcessing:(AUNetClientType)type
                taskID:(NSString *)taskID
              sourceIP:(NSString *)sourceIP
              progress:(NSString *)progress
                 delta:(NSString *)delta
                 cdata:(NSString *)cdata;
- (void)sendCopyCompletedMessageWithTaskid:(NSString *)taskid sourceIP:(NSString *)sourceIP fileitemCData:(NSString *)fileitemCData;

- (void)sendCopyerrorMessageWithTaskid:(NSString *)taskid fileitemCData:(NSString *)fileitemCData;

- (void)photoMergeTaskID:(NSString *)taskID filePath:(NSString *)filePath length:(float)length;

- (void)mergeQuitTaskID:(NSString *)taskID;

- (void)setupCompletionBlockWithSuccess:(void (^)(GDataXMLDocument *xml, AUNetClientType type))success failure:(void (^)(NSError *error))failure;
@end
