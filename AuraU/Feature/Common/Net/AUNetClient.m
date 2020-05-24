//
//  AUNet.m
//  AuraU
//
//  Created by Thundersoft on 15/2/13.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUNetClient.h"
#import "GDataXMLNode.h"
#import "AUNetArgument.h"
#import "AUMetadataItem.h"

@interface AUNetClient ()
@property (nonatomic, assign) BOOL isRegistering;
@property (nonatomic, strong) GCDAsyncSocket *tcpSocket;
@property (nonatomic, strong) NSTimer *readTimer;

@property (nonatomic, copy) void(^successBlock)(GDataXMLDocument *xml, AUNetClientType type);
@property (nonatomic, copy) void(^failureBlock)(NSError *error);
@end

@implementation AUNetClient
- (instancetype)init {
    if (self = [super init]) {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        _tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];

        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyReachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        //        [[Reachability reachabilityForLocalWiFi] startNotifier];
    }
    return self;
}

- (void)dealloc {
    [_readTimer invalidate];
    _readTimer = nil;
}

- (void)setupCompletionBlockWithSuccess:(void (^)(GDataXMLDocument *xml, AUNetClientType type))success failure:(void (^)(NSError *error))failure {
    _successBlock = success;
    _failureBlock = failure;
}

- (void)readTimerSchedule {
    [self heartbeat];
}

- (void)checkRegisterSuccessOrNot {
    if (_isRegistering) {
        NSError *err = [NSError errorWithDomain:kAUDomain code:kErrorForRegisterTimeout userInfo:nil];
        if (_failureBlock) {
            _failureBlock(err);
        }
    }
}

- (void)disconnect {
    [_tcpSocket disconnect];
}

- (void)handleMessage:(GDataXMLDocument *)xml {
    NSArray *arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/Connect" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"register"]) {
            _isRegistered = YES;
            _isRegistering = NO;
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeDeviceRegister);
            }
            return;
        }

        if ([cmdAttr isEqualToString:@"userchange"]) {
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeDeviceUserchange);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/Connect" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"unregister"]) {
            _isRegistered = NO;
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeDeviceUnregister);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/FaceScan" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"recognizeRetry"]) {
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeScanRetry);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/FaceScan" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"recognizeSucceed"]) {
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeScanSucceed);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/FaceScan" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"recognizeFailed"]) {
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeScanFailed);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/MediaLibrary" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"Querymetadata"]) {
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeMediaQuery);
            }
            return;
        }
    }

    // 隐藏主菜单
    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/Setting" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"isvisible"]) {
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeMenuHide);
            }
            return;
        }
    }

    // “摇晃手机分享照片”完成
    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/Shake" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"shakecompleted"]) {
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeShakeCompleted);
            }
            return;
        }
    }

    // BeginReset
    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhoneDetect" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"BeginReset"]) {
            NSArray *arr2 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhoneDetect/DetectionCode" error:nil];
            for (GDataXMLElement *ele2 in arr2) {
                _detectionCode = [ele2 stringValue];
                if (_successBlock) {
                    _successBlock(xml, AUNetClientTypeDetectBeginReset);
                }
                return;
            }
        }
    }

    // PatternPrepared
    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhoneDetect" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"PatternPrepared"]) {
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeDetectPatternPrepared);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhoneDetect" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"DetectionFailed"]) {
            NSArray *arr2 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhoneDetect/DetectionCode" error:nil];
            for (GDataXMLElement *ele2 in arr2) {
                _detectionCode = [ele2 stringValue];
                _isDetecting = NO;
                if (_successBlock) {
                    _successBlock(xml, AUNetClientTypeDetectDetectionFailed);
                }
                return;
            }
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhoneDetect" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"DetectionSuccess"]) {
            _isDetecting = NO;
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeDetectDetectionSuccess);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/FileCopy" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"copy"]) {
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeCopyToPhone);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/FileCopy" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"cancel"]) {
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeCopyCanceled);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhotoMerge" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"MergeProcessing"]) {
            _isDetecting = NO;
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypePhotoMerge);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhotoMerge" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"MergeAccept"]) {
            _isDetecting = NO;
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypePhotoMerge);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhotoMerge" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"MergeAccept"]) {
            _isDetecting = NO;
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypePhotoMerge);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhotoMerge" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"MergeSucceed"]) {
            _isDetecting = NO;
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeMergeSucceed);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhotoMerge" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"MergeProcessQuit"]) {
            _isDetecting = NO;
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeMergeProcessQuit);
            }
            return;
        }
    }

    arr1 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhotoMerge" error:nil];
    for (GDataXMLElement *ele1 in arr1) {
        NSString *cmdAttr = [[ele1 attributeForName:@"Command"] stringValue];
        if ([cmdAttr isEqualToString:@"MergeReject"]) {

            NSArray *arr2 = [xml nodesForXPath:@"//MdmiChannel/Transaction/PhotoMerge/Result" error:nil];
            for (GDataXMLElement *ele2 in arr2) {
                NSString *str = [ele2 stringValue];
                if ([str isEqualToString:@"FullUser"]) {
                    _isDetecting = NO;
                    if (_successBlock) {
                        _successBlock(xml, AUNetClientTypeFullUser);
                    }
                     return;
                }
            }
            _isDetecting = NO;
            if (_successBlock) {
                _successBlock(xml, AUNetClientTypeMergeReject);
            }
            return;
        }
    }

    DDLogInfo(@"%s: 未处理的响应！", __func__);
}

#pragma mark - Net methods
- (void)connect {
    NSError *error = nil;

    if (_isConnecting ||
        [_tcpSocket isConnected]) {
        return;
    }

    if (![_tcpSocket connectToHost:kSocketHost onPort:kSocketPort withTimeout:(kSocketTimeout * 2) error:&error]) {
        _isConnecting = NO;
        if (error.code == 1) {
            return;
        }

        if (_failureBlock) {
            _failureBlock(error);
        }
    }else {
        // _readTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(readTimerSchedule) userInfo:nil repeats:YES];
    }
    _isConnecting = YES;
}

- (void)heartbeat {
    if ([_tcpSocket isDisconnected]) {
        [_readTimer invalidate];
        _readTimer = nil;
        return;
    }

//    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
//    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:@"heartbeat"];
//    [transactionElement addAttribute:typeAttr];
//
//    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
//    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:[AUNetArgument sharedArgument].ip];

//    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"a"];
//    [mdmiChannelElement addChild:sourceElement];
//    [mdmiChannelElement addChild:destinationElement];
//    [mdmiChannelElement addChild:transactionElement];

//    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
//    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:AUNetClientTypeDeviceHeartbeat];

    [_tcpSocket writeData:[@"a" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:kSocketTimeout tag:AUNetClientTypeDeviceHeartbeat];
}

- (void)sendDevice:(AUNetClientType)type {
    if (type < AUNetClientTypeDeviceConnect || type > AUNetClientTypeDeviceHeartbeat) {
        return;
    }

    NSString *typeString;
    switch (type) {
        case AUNetClientTypeDeviceRegister:
            typeString = @"register";
            break;
        case AUNetClientTypeDeviceUnregister:
            typeString = @"unregister";
            break;
        default:
            break;
    }
    
    AUNetArgument *arg = [AUNetArgument sharedArgument];

    GDataXMLElement *macElement = [GDataXMLNode elementWithName:@"MAC" stringValue:arg.mac];
    GDataXMLElement *nameElement = [GDataXMLNode elementWithName:@"Name" stringValue:arg.name];
    GDataXMLElement *ipElement = [GDataXMLNode elementWithName:@"IP" stringValue:arg.ip];
    GDataXMLElement *versionElement = [GDataXMLNode elementWithName:@"Version" stringValue:arg.version];
    GDataXMLElement *typeElement = [GDataXMLNode elementWithName:@"Type" stringValue:/*@"MDMI"*/@"IOS"];
    GDataXMLElement *httpPortElement = [GDataXMLNode elementWithName:@"HttpPort" stringValue:@"8345"];
    GDataXMLElement *downloadURIElement = [GDataXMLNode elementWithName:@"DownloadURI" stringValue:@"file"];
    GDataXMLElement *streamingURIElement = [GDataXMLNode elementWithName:@"StreamingURI" stringValue:@"streaming"];

    GDataXMLElement *connectElement = [GDataXMLNode elementWithName:@"Connect"];
    GDataXMLElement *commandAttribute = [GDataXMLNode attributeWithName:@"Command" stringValue:typeString];
    [connectElement addAttribute:commandAttribute];
    [connectElement addChild:macElement];
    [connectElement addChild:nameElement];
    [connectElement addChild:ipElement];
    [connectElement addChild:versionElement];
    [connectElement addChild:typeElement];
    [connectElement addChild:httpPortElement];
    [connectElement addChild:downloadURIElement];
    [connectElement addChild:streamingURIElement];

    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
    GDataXMLElement *typeAttribute = [GDataXMLNode attributeWithName:@"Type" stringValue:@"connect"];
    [transactionElement addAttribute:typeAttribute];
    [transactionElement addChild:connectElement];

    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:arg.ip];

    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"MdmiChannel"];
    [mdmiChannelElement addChild:sourceElement];
    [mdmiChannelElement addChild:destinationElement];
    [mdmiChannelElement addChild:transactionElement];

    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:type];
}

- (void)metadataCount:(NSInteger)count {
    AUNetArgument *arg = [AUNetArgument sharedArgument];

    GDataXMLElement *metadataListElement = [GDataXMLNode elementWithName:@"MetadataList"];
    GDataXMLElement *countAttr = [GDataXMLNode attributeWithName:@"Count" stringValue:JXIntToString(count)];
    [metadataListElement addAttribute:countAttr];

    GDataXMLElement *mediaLibraryElement = [GDataXMLNode elementWithName:@"MediaLibrary"];
    GDataXMLElement *metadatacountAttr = [GDataXMLNode attributeWithName:@"Command" stringValue:@"metadatacount"];
    [mediaLibraryElement addAttribute:metadatacountAttr];
    [mediaLibraryElement addChild:metadataListElement];

    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:@"medialibrary"];
    [transactionElement addAttribute:typeAttr];
    [transactionElement addChild:mediaLibraryElement];

    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:arg.ip];

    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"MdmiChannel"];
    [mdmiChannelElement addChild:sourceElement];
    [mdmiChannelElement addChild:destinationElement];
    [mdmiChannelElement addChild:transactionElement];

    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:AUNetClientTypeMediaQuery];
}

- (void)metadataList:(NSArray *)list listActionType:(k_MediaActionType)actionType{
    AUNetArgument *arg = [AUNetArgument sharedArgument];
    GDataXMLElement *metadataListElement = [GDataXMLNode elementWithName:@"MetadataList"];
    GDataXMLElement *countAttr = [GDataXMLNode attributeWithName:@"Count" stringValue:JXIntToString([list count])];
    NSString *strAction = @"init";

    if (actionType == MediaActionInit) {
        strAction = @"init";
    } else if (actionType == MediaActionAdd) {
        strAction = @"add";
    } else if (actionType == MediaActionRemove) {
        strAction = @"remove";
    }


    GDataXMLElement *ActionAttr = [GDataXMLNode attributeWithName:@"Action" stringValue:strAction];
    [metadataListElement addAttribute:countAttr];
    [metadataListElement addAttribute:ActionAttr];

    NSString *metadataItemString = @"";
    for (AUMetadataItem *metadataItem in list) {
        NSString *filepath = metadataItem.path;

        if (AUMetadataItemTypeMusic == metadataItem.type ||
            AUMetadataItemTypeVideo == metadataItem.type) {
            filepath = [NSString stringWithFormat:@"Aura/%@", filepath];
        }

        metadataItemString = [NSString stringWithFormat:@"Type<%@>ID<%@>Path<%@>Length<%ld>DateModified<1423532030>DateTaken<1423532030688>Orientation<0>Width<1080>Height<1920>Album<%@>Artist<%@>",
                      [[AUMetadataItem typeRepresents] objectAtIndex:metadataItem.type],
                      metadataItem.identifier,
                      filepath,
                              (long)metadataItem.lengthBytes,
                              metadataItem.albumTitle,
                              metadataItem.artist];
         //NSLog(@"path = %@, type = %ld", metadataItem.path, (long)metadataItem.type);
        GDataXMLNode *cdataNode = [GDataXMLNode createCData:metadataItemString];
        GDataXMLElement *contentElement = [GDataXMLNode elementWithName:@"MetadataItem"];
        [contentElement addChild:cdataNode];
        [metadataListElement addChild:contentElement];
    }

    GDataXMLElement *mediaLibraryElement = [GDataXMLNode elementWithName:@"MediaLibrary"];

     NSString *strCommand = @"metadatalist";
    if (actionType == MediaActionInit) {
        strCommand = @"metadatalist";
    } else {
        strCommand = @"mediaUpdate";
    }
    GDataXMLElement *metadatacountAttr = [GDataXMLNode attributeWithName:@"Command" stringValue:strCommand];
    [mediaLibraryElement addAttribute:metadatacountAttr];
    [mediaLibraryElement addChild:metadataListElement];

    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:@"medialibrary"];
    [transactionElement addAttribute:typeAttr];
    [transactionElement addChild:mediaLibraryElement];

    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:arg.ip];

    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"MdmiChannel"];
    [mdmiChannelElement addChild:sourceElement];
    [mdmiChannelElement addChild:destinationElement];
    [mdmiChannelElement addChild:transactionElement];

    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:AUNetClientTypeMediaQuery];
}

- (void)shake:(AUNetClientType)type {
    if (type < AUNetClientTypeShakeStart || type > AUNetClientTypeShakeReset) {
        return;
    }

    NSString *typeString;
    switch (type) {
        case AUNetClientTypeShakeStart:
            typeString = @"shakestart";
            break;
        case AUNetClientTypeShakeDelta:
            typeString = @"shakedelta";
            break;
        case AUNetClientTypeShakeStop:
            typeString = @"shakestop";
            break;
        case AUNetClientTypeShakeCompleted:
            typeString = @"shakecompleted";
            break;
        case AUNetClientTypeShakeReset:
            typeString = @"shakereset";
            break;
        default:
            break;
    }

    AUNetArgument *arg = [AUNetArgument sharedArgument];

    GDataXMLElement *valueElement = [GDataXMLNode elementWithName:@"Value" stringValue:@"0"];

    GDataXMLElement *shakeElement = [GDataXMLNode elementWithName:@"Shake"];
    GDataXMLElement *commandAttr = [GDataXMLNode attributeWithName:@"Command" stringValue:typeString];
    [shakeElement addAttribute:commandAttr];
    [shakeElement addChild:valueElement];

    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:@"shake"];
    [transactionElement addAttribute:typeAttr];
    [transactionElement addChild:shakeElement];

    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:arg.ip];

    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"MdmiChannel"];
    [mdmiChannelElement addChild:sourceElement];
    [mdmiChannelElement addChild:destinationElement];
    [mdmiChannelElement addChild:transactionElement];

    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:type];
}

- (void)showMenu:(BOOL)show {
    NSString *settingValue = @"false";
    if (show) {
        settingValue = @"true";
    }

    GDataXMLElement *settingElement = [GDataXMLNode elementWithName:@"Setting"];
    GDataXMLElement *commandAttr = [GDataXMLNode attributeWithName:@"Command" stringValue:@"isvisible"];
    GDataXMLElement *valueAttr = [GDataXMLNode attributeWithName:@"Value" stringValue:settingValue];
    [settingElement addAttribute:commandAttr];
    [settingElement addAttribute:valueAttr];

    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:@"setting"];
    [transactionElement addAttribute:typeAttr];
    [transactionElement addChild:settingElement];

    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:[AUNetArgument sharedArgument].ip];

    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"MdmiChannel"];
    [mdmiChannelElement addChild:sourceElement];
    [mdmiChannelElement addChild:destinationElement];
    [mdmiChannelElement addChild:transactionElement];

    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:AUNetClientTypeMenuShow];
}

- (void)scan:(AUNetClientType)type taskID:(NSString *)taskID filePath:(NSString *)filePath length:(float)length{
    if (type < AUNetClientTypeScanStart || type > AUNetClientTypeScanStop) {
        return;
    }

    NSString *commandValue;
    switch (type) {
        case AUNetClientTypeScanStart:
            commandValue = @"ScanStart";
            break;
        case AUNetClientTypeScanStop:
            commandValue = @"ScanStop";
            break;
        default:
            break;
    }

    NSString *cdataString = [NSString stringWithFormat:@"ID<-1>Path<%@>Length<%.0f>", filePath,length];
    GDataXMLNode *cdataNode = [GDataXMLNode createCData:cdataString];

    GDataXMLElement *fileItemElement = [GDataXMLNode elementWithName:@"FileItem"];
    [fileItemElement addChild:cdataNode];

    GDataXMLElement *faceScanElement = [GDataXMLNode elementWithName:@"FaceScan"];
    GDataXMLElement *commandAttr = [GDataXMLNode attributeWithName:@"Command" stringValue:commandValue];
    GDataXMLElement *taskIDAttr = [GDataXMLNode attributeWithName:@"TaskID" stringValue:taskID];
    [faceScanElement addAttribute:commandAttr];
    [faceScanElement addAttribute:taskIDAttr];
    [faceScanElement addChild:fileItemElement];

    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:@"FaceScan"];
    [transactionElement addAttribute:typeAttr];
    [transactionElement addChild:faceScanElement];

    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:[AUNetArgument sharedArgument].ip];

    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"MdmiChannel"];
    [mdmiChannelElement addChild:sourceElement];
    [mdmiChannelElement addChild:destinationElement];
    [mdmiChannelElement addChild:transactionElement];

    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:type];
}

- (void)detect:(AUNetClientType)type code:(NSString *)code {
    NSString *commandValue;
    switch (type) {
        case AUNetClientTypeDetectInit:
            _isDetecting = YES;
            commandValue = @"init";
            break;
        case AUNetClientTypeDetectEndReset:
            commandValue = @"endreset";
            break;
        case AUNetClientTypeDetectTakeReady:
            commandValue = @"takeready";
            break;
        case AUNetClientTypeDetectCancelDetection:
            _isDetecting = NO;
            commandValue = @"canceldetection";
            break;
        default:
            break;
    }

    GDataXMLElement *detectionCodeElement = [GDataXMLNode elementWithName:@"DetectionCode" stringValue:code];

    GDataXMLElement *phoneDetectElement = [GDataXMLNode elementWithName:@"PhoneDetect"];
    GDataXMLElement *commandAttr = [GDataXMLNode attributeWithName:@"Command" stringValue:commandValue];
    [phoneDetectElement addAttribute:commandAttr];
    [phoneDetectElement addChild:detectionCodeElement];

    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:@"phonedetect"];
    [transactionElement addAttribute:typeAttr];
    [transactionElement addChild:phoneDetectElement];

    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:[AUNetArgument sharedArgument].ip];

    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"MdmiChannel"];
    [mdmiChannelElement addChild:sourceElement];
    [mdmiChannelElement addChild:destinationElement];
    [mdmiChannelElement addChild:transactionElement];

    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:type];
}

- (void)copyProcessing:(AUNetClientType)type
                taskID:(NSString *)taskID
              sourceIP:(NSString *)sourceIP
              progress:(NSString *)progress
                 delta:(NSString *)delta
                 cdata:(NSString *)cdata {
    GDataXMLNode *cdataNode = [GDataXMLNode createCData:cdata];

    GDataXMLElement *fileItemElement = [GDataXMLNode elementWithName:@"FileItem"];
    GDataXMLElement *sourceIPAttr = [GDataXMLNode attributeWithName:@"SourceIP" stringValue:sourceIP];
    GDataXMLElement *progressAttr = [GDataXMLNode attributeWithName:@"Progress" stringValue:progress];
    GDataXMLElement *deltaAttr = [GDataXMLNode attributeWithName:@"Delta" stringValue:delta];
    [fileItemElement addAttribute:sourceIPAttr];
    [fileItemElement addAttribute:progressAttr];
    [fileItemElement addAttribute:deltaAttr];
    [fileItemElement addChild:cdataNode];

    GDataXMLElement *fileCopyElement = [GDataXMLNode elementWithName:@"FileCopy"];
    GDataXMLElement *commandAttr = [GDataXMLNode attributeWithName:@"Command" stringValue:@"copyprogress"];
    GDataXMLElement *taskIDAttr = [GDataXMLNode attributeWithName:@"TaskID" stringValue:taskID];
    [fileCopyElement addAttribute:commandAttr];
    [fileCopyElement addAttribute:taskIDAttr];
    [fileCopyElement addChild:fileItemElement];

    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:@"filecopy"];
    [transactionElement addAttribute:typeAttr];
    [transactionElement addChild:fileCopyElement];

    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:[AUNetArgument sharedArgument].ip];

    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"MdmiChannel"];
    [mdmiChannelElement addChild:sourceElement];
    [mdmiChannelElement addChild:destinationElement];
    [mdmiChannelElement addChild:transactionElement];

    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:type];
}

- (void)sendCopyCompletedMessageWithTaskid:(NSString *)taskid sourceIP:(NSString *)sourceIP fileitemCData:(NSString *)fileitemCData {
    GDataXMLNode *fileitemCDataNode = [GDataXMLNode createCData:fileitemCData];

    GDataXMLElement *fileItemElement = [GDataXMLNode elementWithName:@"FileItem"];
    GDataXMLElement *sourceIPAttr = [GDataXMLNode attributeWithName:@"SourceIP" stringValue:/*[AUNetArgument sharedArgument].ipForDestination*/sourceIP];
    [fileItemElement addAttribute:sourceIPAttr];
    [fileItemElement addChild:fileitemCDataNode];

    GDataXMLElement *fileCopyElement = [GDataXMLNode elementWithName:@"FileCopy"];
    GDataXMLElement *commandAttr = [GDataXMLNode attributeWithName:@"Command" stringValue:@"completed"];
    GDataXMLElement *taskIDAttr = [GDataXMLNode attributeWithName:@"TaskID" stringValue:taskid];
    [fileCopyElement addAttribute:commandAttr];
    [fileCopyElement addAttribute:taskIDAttr];
    [fileCopyElement addChild:fileItemElement];


    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:@"filecopy"];
    [transactionElement addAttribute:typeAttr];
    [transactionElement addChild:fileCopyElement];

    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:[AUNetArgument sharedArgument].ip];

    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"MdmiChannel"];
    [mdmiChannelElement addChild:sourceElement];
    [mdmiChannelElement addChild:destinationElement];
    [mdmiChannelElement addChild:transactionElement];

    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:AUNetClientTypeCopyCompleted];
}

- (void)sendCopyerrorMessageWithTaskid:(NSString *)taskid fileitemCData:(NSString *)fileitemCData {
    GDataXMLNode *fileitemCDataNode = [GDataXMLNode createCData:fileitemCData];

    GDataXMLElement *fileItemElement = [GDataXMLNode elementWithName:@"FileItem"];
    GDataXMLElement *sourceIPAttr = [GDataXMLNode attributeWithName:@"SourceIP" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    [fileItemElement addAttribute:sourceIPAttr];
    [fileItemElement addChild:fileitemCDataNode];

    GDataXMLElement *fileCopyElement = [GDataXMLNode elementWithName:@"FileCopy"];
    GDataXMLElement *commandAttr = [GDataXMLNode attributeWithName:@"Command" stringValue:@"copyerror"];
    GDataXMLElement *taskIDAttr = [GDataXMLNode attributeWithName:@"TaskID" stringValue:taskid];
    [fileCopyElement addAttribute:commandAttr];
    [fileCopyElement addAttribute:taskIDAttr];
    [fileCopyElement addChild:fileItemElement];


    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:@"filecopy"];
    [transactionElement addAttribute:typeAttr];
    [transactionElement addChild:fileCopyElement];

    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:[AUNetArgument sharedArgument].ip];

    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"MdmiChannel"];
    [mdmiChannelElement addChild:sourceElement];
    [mdmiChannelElement addChild:destinationElement];
    [mdmiChannelElement addChild:transactionElement];

    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:AUNetClientTypeCopyCompleted];
}


- (void)photoMergeTaskID:(NSString *)taskID filePath:(NSString *)filePath length:(float)length {

    GDataXMLElement *fileItemElement = nil;
    NSString *commandValue = @"MergeRequest";

    if (filePath) {
        NSString *cdataString = [NSString stringWithFormat:@"ID<-1>Path<%@>Length<%.0f>", filePath,length];
        GDataXMLNode *cdataNode = [GDataXMLNode createCData:cdataString];

        fileItemElement = [GDataXMLNode elementWithName:@"FileItem"];
        [fileItemElement addChild:cdataNode];
        commandValue =  @"Available";

    }
    GDataXMLElement *phoneDetectElement = [GDataXMLNode elementWithName:@"PhotoMerge"];
    GDataXMLElement *commandAttr = [GDataXMLNode attributeWithName:@"Command" stringValue:commandValue];
    GDataXMLElement *taskIDAttr = [GDataXMLNode attributeWithName:@"TaskID" stringValue:taskID];
    [phoneDetectElement addAttribute:commandAttr];
    [phoneDetectElement addAttribute:taskIDAttr];
    if (filePath) {
         [phoneDetectElement addChild:fileItemElement];
    }
    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:@"PhotoMerge"];
    [transactionElement addAttribute:typeAttr];
    [transactionElement addChild:phoneDetectElement];

    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:[AUNetArgument sharedArgument].ip];

    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"MdmiChannel"];
    [mdmiChannelElement addChild:sourceElement];
    [mdmiChannelElement addChild:destinationElement];
    [mdmiChannelElement addChild:transactionElement];

    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:AUNetClientTypePhotoMerge];
}

- (void)mergeQuitTaskID:(NSString *)taskID {

    GDataXMLElement *phoneDetectElement = [GDataXMLNode elementWithName:@"PhotoMerge"];
    GDataXMLElement *commandAttr = [GDataXMLNode attributeWithName:@"Command" stringValue:@"MergeQuit"];
    GDataXMLElement *taskIDAttr = [GDataXMLNode attributeWithName:@"TaskID" stringValue:taskID];

    [phoneDetectElement addAttribute:commandAttr];
    [phoneDetectElement addAttribute:taskIDAttr];

    GDataXMLElement *transactionElement = [GDataXMLNode elementWithName:@"Transaction"];
    GDataXMLElement *typeAttr = [GDataXMLNode attributeWithName:@"Type" stringValue:@"PhotoMerge"];
    [transactionElement addAttribute:typeAttr];
    [transactionElement addChild:phoneDetectElement];

    GDataXMLElement *destinationElement = [GDataXMLNode elementWithName:@"Destination" stringValue:[AUNetArgument sharedArgument].ipForDestination];
    GDataXMLElement *sourceElement = [GDataXMLNode elementWithName:@"Source" stringValue:[AUNetArgument sharedArgument].ip];

    GDataXMLElement *mdmiChannelElement = [GDataXMLNode elementWithName:@"MdmiChannel"];
    [mdmiChannelElement addChild:sourceElement];
    [mdmiChannelElement addChild:destinationElement];
    [mdmiChannelElement addChild:transactionElement];

    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:mdmiChannelElement];
    [_tcpSocket writeData:[xmlDoc XMLData] withTimeout:kSocketTimeout tag:AUNetClientTypePhotoMerge];
}

- (BOOL)isConnected {
    return [_tcpSocket isConnected];
}

#pragma mark - GCDAsyncSocketDelegate methods
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    _isConnecting = NO;

    [_tcpSocket performBlock:^{
        [_tcpSocket enableBackgroundingOnSocket];
    }];

    if (_successBlock) {
        _successBlock(nil, AUNetClientTypeDeviceConnect);
    }
    if (_readTimer) {
        [_readTimer invalidate];
        _readTimer = nil;
    }
    _readTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(readTimerSchedule) userInfo:nil repeats:YES];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (AUNetClientTypeDeviceRegister == tag) {
        _isRegistering = YES;
        [self performSelector:@selector(checkRegisterSuccessOrNot) withObject:nil afterDelay:5.0];
    }

    if (AUNetClientTypeDeviceRegister == tag) {
        [_tcpSocket readDataWithTimeout:-1 tag:tag];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (!data) {
        return;
    }

    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DDLogInfo(@"PC -> Phone: %@", message);

    NSArray *xmlAll = [message componentsSeparatedByString:kXMLDeclaration];
    for (NSString *xml in xmlAll) {
        if ([xml trim].length != 0) {
            GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
            if (doc) {
                [self handleMessage:doc];
            }
        }
    }

    [_tcpSocket readDataWithTimeout:-1 tag:tag];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    _isConnecting = NO;
    _isRegistered = NO;
//    [self connect];
//    return;
    if (_failureBlock) {
        _failureBlock(err);
    }

    [_readTimer invalidate];
    _readTimer = nil;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    NSLog(@"%s: elapsed = %.2f", __func__, elapsed);
    NSError *err = [NSError errorWithDomain:kAUDomain code:kErrorForRegisterTimeout userInfo:nil];
    if (_failureBlock) {
        _failureBlock(err);
    }

    return 0;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    NSLog(@"%s: elapsed = %.2f", __func__, elapsed);
    NSError *err = [NSError errorWithDomain:kAUDomain code:kErrorForRegisterTimeout userInfo:nil];
    if (_failureBlock) {
        _failureBlock(err);
    }

    return 0;
}

#pragma mark - Notification methods
- (void)notifyReachabilityChanged:(NSNotification *)notification {
    //    Reachability* curReach = [note object];
    //    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    //    [self updateInterfaceWithReachability:curReach];

    Reachability* currentReachability = [notification object];
    NetworkStatus networkStatus = currentReachability.currentReachabilityStatus;
    switch (networkStatus) {
        case NotReachable: {
            NSError *err = [NSError errorWithDomain:kCustomDomain code:AUNetClientErrorWifiDisconnect userInfo:nil];
            if (_failureBlock) {
                _failureBlock(err);
            }
            //            statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
            //            imageView.image = [UIImage imageNamed:@"stop-32.png"] ;
            //            /*
            //             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
            //             */
            //            connectionRequired = NO;
            break;
        }

        case ReachableViaWWAN: {
            //            statusString = NSLocalizedString(@"Reachable WWAN", @"");
            //            imageView.image = [UIImage imageNamed:@"WWAN5.png"];
            break;
        }
        case ReachableViaWiFi: {
            //            statusString= NSLocalizedString(@"Reachable WiFi", @"");
            //            imageView.image = [UIImage imageNamed:@"Airport.png"];
            break;
        }
    }
}

#pragma mark - Class methods
+ (instancetype)sharedClient {
    static AUNetClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AUNetClient alloc] init];
    });
    
    return _sharedClient;
}

@end
