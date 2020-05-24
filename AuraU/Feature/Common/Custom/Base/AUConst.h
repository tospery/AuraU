//
//  AUConst.h
//  AuraU
//
//  Created by Thundersoft on 15/2/8.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#ifndef AuraU_AUConst_h
#define AuraU_AUConst_h

// Animation
#define kAnimationForEntryMain              (@"kAnimationForEntryMain")

#define kIntForStringFormat(object) [NSString stringWithFormat:@"%d",object]

// Socket
#define kSocketHost                         (@"192.168.173.1")
#define kSocketPort                         (8343)
#define kSocketTimeout                      (5.0)

// HTTPServerPort
#define kHTTPServerPort         8345

// Document
#define kDocumentName                       (@"AuraU")

// Wifi
#define kWifiNamePrefix                     (@"MDMI_")

// XML
#define kXMLDeclaration                     (@"<?xml version=\"1.0\" encoding=\"utf-8\"?>")

#define kCustomDomain                       (@"com.thundersoft.aurau")


// NotificationCenter
#define kPhotoChangeNotification            (@"PhotoChangeNotification")
#define kVideoChangeNotification            (@"VideoChangeNotification")
#define kMusicChangeNotification            (@"MusicChangeNotification")
#define kMediaFilePath                      (@"MediaFilePath")
#define kBecomeActiveNotification           (@"BecomeActiveNotification")


// Capture NotificationCenter

#define kCaptureRetryNotification           (@"CaptureRetryNotification")
#define kCaptureSucceedNotification         (@"CaptureSucceedNotification")
#define kCaptureFailedNotification          (@"CaptureFailedNotification")
#define kResultsNotification                (@"ResultsNotification")

#define kMetaItmesSuccessNotification        (@"MetaItmesSuccessNotification")
#define kMetaItmesAddNotification           (@"MetaItmesAddNotification")
#define kMetaItmesRemoveNotification        (@"MetaItmesRemoveNotification")

#define kNotifyResetGuideViewForiOS6        (@"kNotifyResetGuideViewForiOS6")

#define kSlzFlatEnable                      (@"kSlzFlatEnable")
#define kAppVersion                         (@"kAppVersion")
#define kSettingLoding                      (@"kSettingLoding")

#define kHUDHideDelayTime                      (3)


#define file_Images @"file/image/"

#define file_Video @"streaming/video/"
#define file_Music @"streaming/music/"

#define file_normal @"file/normal/"
#define file_Capture @"file/capture/"
#define file_CapName @"capture"
#define file_PhotoImageName @"photoImage"

#define kAUDomain                           (@"com.lenovo.aurau")
#define kErrorForRegisterTimeout            (-1001)

#define kSizeForOneMb                       (1024*1024)

#define kIndex                              (100000)

#endif
