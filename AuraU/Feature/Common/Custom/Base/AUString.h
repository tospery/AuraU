//
//  AUString.h
//  AuraU
//
//  Created by Thundersoft on 15/2/8.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#ifndef AuraU_AUString_h
#define AuraU_AUString_h

#pragma mark - 1个汉字


#pragma mark - 2个汉字
#define kStringForgotPhoto                                       \
JXT(NSLocalizedString(@"ForgotPhoto", @"照片"), @"照片")
#define kStringForgotVideo                                       \
JXT(NSLocalizedString(@"ForgotVideo ", @"视频"), @"视频")
#define kStringForgotMusic                                      \
JXT(NSLocalizedString(@"ForgotMusic", @"音乐"), @"音乐")
#define kStringGestureAction                                      \
JXT(NSLocalizedString(@"GestureAction", @"手势操作"), @"手势操作")

#pragma mark - 3个汉字
#define kStringRecognizingWithEllipsis                          \
JXT(NSLocalizedString(@"RecognizingWithEllipsis", @"识别中..."), @"识别中...")


#pragma mark - 4个汉字
#define kStringForgotPassword                                       \
JXT(NSLocalizedString(@"ForgotPassword", @"忘记密码"), @"忘记密码")
#define kStringReshareOnBegin                                       \
JXT(NSLocalizedString(@"ReshareOnBegin", @"从头分享"), @"从头分享")
#define kStringScanFace                                             \
JXT(NSLocalizedString(@"ScanFace", @"扫描人脸"), @"扫描人脸")
#define kStringTakePhotoWithPeoples                                 \
JXT(NSLocalizedString(@"TakePhotoWithPeoples", @"多人合照"), @"多人合照")
#define kStringCopyPassword                                         \
JXT(NSLocalizedString(@"CopyPassword", @"拷贝密码"), @"拷贝密码")
#define kStringConnecting                                         \
JXT(NSLocalizedString(@"Connecting", @"正在连接"), @"正在连接")
#define kStringPreparing                                         \
JXT(NSLocalizedString(@"Preparing", @"正在准备"), @"正在准备")
#define kStringTimeIsUp                                        \
JXT(NSLocalizedString(@"TimeIsUp", @"时间到了"), @"时间到了")
#define kStringReconnecting                                        \
JXT(NSLocalizedString(@"Reconnecting", @"正在重连"), @"正在重连")
#define kStringAccessError                                        \
JXT(NSLocalizedString(@"AccessError", @"访问错误"), @"访问错误")
#define kStringRetake                                       \
JXT(NSLocalizedString(@"Retake", @"重新拍摄"), @"重新拍摄")
#define kStringGetStarred                                       \
JXT(NSLocalizedString(@"GetStarred", @"开始体验"), @"开始体验")
#define kStringReconnect                                       \
JXT(NSLocalizedString(@"Reconnect", @"重新连接"), @"重新连接")
#define kStringPhotoReadingPleaseWait                                       \
JXT(NSLocalizedString(@"PhotoReadingPleaseWait", @"照片准备中，请稍后..."), @"照片准备中，请稍后...")


#pragma mark - 5个汉字
#define kStringShowMainMenu                                         \
JXT(NSLocalizedString(@"ShowMainMenu", @"显示主菜单"), @"显示主菜单")


#pragma mark - 更多汉字
#define kStringShakePhoneToSharePhotosToAura                        \
JXT(NSLocalizedString(@"ShakePhoneToSharePhotosToAura", @"晃动手机分享照片至Aura桌面"), @"晃动手机分享照片至Aura桌面")
#define kStringFlatPhoneOnAuraToShowMainMenu                        \
JXT(NSLocalizedString(@"FlatPhoneOnAuraToShowMainMenu", @"放平手机到Aura桌面上，显示手机主菜单"), @"放平手机到Aura桌面上，显示手机主菜单")
#define kStringSetSharedDirectory                                   \
JXT(NSLocalizedString(@"kStringSetSharedDirectory", @"设置可公开目录"), @"设置可公开目录")
#define kStringSupportFlatGesture                                   \
JXT(NSLocalizedString(@"SupportFlatGesture", @"支持放平手势"), @"支持放平手势")
#define kStringUnrecognizeFlatGestureAfterClosed                    \
JXT(NSLocalizedString(@"kStringUnrecognizeFlatGestureAfterClosed", @"关闭后无法识别放平手势"), @"关闭后无法识别放平手势")
#define kStringWifiNotConnectPCHotspot                              \
JXT(NSLocalizedString(@"WifiNotConnectPCHotspot", @"WIFI未连接PC热点"), @"WIFI未连接PC热点")
#define kStringSearchingDevice                                      \
JXT(NSLocalizedString(@"SearchingDevice", @"正在搜索设备..."), @"正在搜索设备...")
#define kStringAllPhotosHaveBeenSharedToAura                                      \
JXT(NSLocalizedString(@"AllPhotosHaveBeenSharedToAura", @"照片已全部分享到Aura桌面"), @"照片已全部分享到Aura桌面")

#define kStringAllPhotosSettingoAura                                      \
JXT(NSLocalizedString(@"AllPhotosSettingoAura", @"无可分享照片，请去隐私设置中设置可公开目录"), @"无可分享照片，请去隐私设置中设置可公开目录")

#define kStringAgainShakeWillBeginFromFirstPhoto                                      \
JXT(NSLocalizedString(@"AgainShakeWillBeginFromFirstPhoto", @"再次晃动时将会从第一张照片开始"), @"再次晃动时将会从第一张照片开始")
#define kStringCannotBeDetectedPleaseFlatPhoneOnAura                                      \
JXT(NSLocalizedString(@"CannotBeDetectedPleaseFlatPhoneOnAura", @"无法被识别，请将手机放置在Aura上。"), @"无法被识别，请将手机放置在Aura上。")
#define kStringPhoneCannotBeRecognizedTemporarily                                      \
JXT(NSLocalizedString(@"kStringPhoneCannotBeRecognizedTemporarily", @"您的手机暂时无法被识别"), @"您的手机暂时无法被识别")
#define kStringPleaseReplacePhoneSuchAsFailureRepeatPleaseCloseIt                                      \
JXT(NSLocalizedString(@"kStringPleaseReplacePhoneSuchAsFailureRepeatPleaseCloseIt", @"请重新放置手机，如多次失败，请关闭手势。"), @"请重新放置手机，如多次失败，请关闭手势。")

#define kStringCaptureFaile                                      \
JXT(NSLocalizedString(@"CaptureFaile", @"Aura中没有你的头像"), @"Aura中没有你的头像")
#define kStringRecognizingGestureWCommaPleaseDonotMovePhoneWPeriod                                     \
JXT(NSLocalizedString(@"RecognizingGestureWithCommaPleaseDonotMovePhoneWithPeriod", @"正在识别手势，请勿移动手机。"), @"正在识别手势，请勿移动手机。")
#define kStringGroupPhotoInvitePeople                                     \
JXT(NSLocalizedString(@"kStringGroupPhotoInvitePeople", @"有人邀请您进入多人合照。"), @"有人邀请您进入多人合照。")

#define kStringFunctionShouldBeManyPeopleConnectTheAura                                    \
JXT(NSLocalizedString(@"kStringFunctionShouldBeManyPeopleConnectTheAura", @"此功能需多人连接Aura。"), @"此功能需多人连接Aura。")

#define kStringScanSuccess                                  \
JXT(NSLocalizedString(@"kStringScanSuccess", @"扫描成功，请在Aura上面查看。"), @"扫描成功，请在Aura上面查看。")
#define kStringConnectedSuccessfully                                  \
JXT(NSLocalizedString(@"ConnectedSuccessfully", @"已成功连接至"), @"已成功连接至")
#define kStringPeopleNeedToBeDoneInTheAuraDesktopPhoto                                  \
JXT(NSLocalizedString(@"PeopleNeedToBeDoneInTheAuraDesktopPhoto", @"多人合照需要在Aura桌面上进行"), @"多人合照需要在Aura桌面上进行")
#define kStringPreparingAndWaiting                                         \
JXT(NSLocalizedString(@"PreparingAndWaiting", @"准备中，请稍后..."), @"准备中，请稍后...")
#define kStringYourDeviceNotSupportThisFunction                                         \
JXT(NSLocalizedString(@"YourDeviceNotSupportThisFunction", @"您的设备不支持该功能！"), @"您的设备不支持该功能！")
#define kStringAppCannotUseYourPictureOrVideo                                         \
JXT(NSLocalizedString(@"AppCannotUseYourPictureOrVideo", @"无法获取您的照片或视频"), @"无法获取您的照片或视频")
#define kStringYouCanEnableItAtPrivicySetting                                         \
JXT(NSLocalizedString(@"YouCanEnableItAtPrivicySetting", @"你可以在「隐私设置」中启用存取"), @"你可以在「隐私设置」中启用存取")
#define kStringCaptureSuccessWaitingOtherThenCanSeeOnAura                                         \
JXT(NSLocalizedString(@"CaptureSuccessWaitingOtherThenCanSeeOnAura", @"拍摄成功 \n等待其他用户完成拍摄，\n你可以在Aura上看到合照的结果。"), @"拍摄成功 \n等待其他用户完成拍摄，\n你可以在Aura上看到合照的结果。")
#define kStringNoPicture                                         \
JXT(NSLocalizedString(@"NoPicture", @"没有照片"), @"没有照片")
#define kStringNoVideo                                        \
JXT(NSLocalizedString(@"NoVideo", @"没有视频"), @"没有视频")
#define kStringNoMusic                                         \
JXT(NSLocalizedString(@"NoMusic", @"没有音乐"), @"没有音乐")
#define kStringYouCanUseiTunesToSycPictureToiPhone                                        \
JXT(NSLocalizedString(@"YouCanUseiTunesToSycPictureToiPhone", @"您可以使用 iTunes 将照片\n同步到 iPhone。"), @"您可以使用 iTunes 将照片\n同步到 iPhone。")
#define kStringYouCanUseiTunesToSycVideoToiPhone                                        \
JXT(NSLocalizedString(@"YouCanUseiTunesToSycVideoToiPhon", @"您可以使用 iTunes 将视频\n同步到 iPhone。"), @"您可以使用 iTunes 将视频\n同步到 iPhone。")
#define kStringYouCanUseiTunesToSycMusicToiPhone                                        \
JXT(NSLocalizedString(@"YouCanUseiTunesToSycMusicToiPhone", @"您可以使用 iTunes 将音乐\n同步到 iPhone。"), @"您可以使用 iTunes 将音乐\n同步到 iPhone。")

#define kStringPhoneWLANIsOff                                        \
JXT(NSLocalizedString(@"PhoneWLANIsOff", @"手机WLAN未开启"), @"手机WLAN未开启")
#define kStringToSettingOpenWLANThenConnectAura                                       \
JXT(NSLocalizedString(@"ToSettingOpenWLANThenConnectAura", @"请在设置中开启WLAN并连接以下Aura热点"), @"请在设置中开启WLAN并连接以下Aura热点")
#define kStringHotspotsIsMDMI                                       \
JXT(NSLocalizedString(@"HotspotsIsMDMI", @"热点：MDMI_******_******"), @"热点：MDMI_******_******")
#define kStringPasswordIs12345678                                       \
JXT(NSLocalizedString(@"PasswordIs12345678", @"密码：12345678"), @"密码：12345678")
#define kStringTipToReturnAPP                                       \
JXT(NSLocalizedString(@"TipToReturnAPP", @"提示：设置WLAN成功后，请手动切回到Aura APP"), @"提示：设置WLAN成功后，请手动切回到Aura APP")
#define kStringUnconnectedAuraHotspots                                        \
JXT(NSLocalizedString(@"UnconnectedAuraHotspots", @"未连接到Aura热点"), @"未连接到Aura热点")
#define kStringConnectAuraFailed                                        \
JXT(NSLocalizedString(@"ConnectAuraFailed", @"连接Aura失败"), @"连接Aura失败")
#define kStringAuraWifiHasSomeProblem                                        \
JXT(NSLocalizedString(@"AuraWifiHasSomeProblem", @"*如您的Aura网络图标有遮蔽，则你的手机可能正与Aura处于不同频段，无法连接"), @"*如您的Aura网络图标有遮蔽，则你的手机可能正与Aura处于不同频段，无法连接")
#define kStringPleaseToRebootAura                                        \
JXT(NSLocalizedString(@"PleaseToRebootAura", @"*请尝试重新启动Aura"), @"*请尝试重新启动Aura")
#define kStringPleaseToReopenWLAN                                        \
JXT(NSLocalizedString(@"PleaseToReopenWLAN", @"*请尝试重新打开手机WLAN连接"), @"*请尝试重新打开手机WLAN连接")
#define kStringPleaseScanYourFace                                      \
JXT(NSLocalizedString(@"PleaseScanYourFace", @"请扫描您的正脸"), @"请扫描您的正脸")
#define kStringScanYourFaceThenYourPhotoWillShowInAura                                      \
JXT(NSLocalizedString(@"ScanYourFaceThenYourPhotoWillShowInAura", @"扫描您的正脸，您的照片将会在Aura中展现"), @"扫描您的正脸，您的照片将会在Aura中展现")

#define kStringFunctionCanOnlyBeFourPeopleAtTheSameTimeUse                                     \
JXT(NSLocalizedString(@"FunctionCanOnlyBeFourPeopleAtTheSameTimeUse", @"该功能只能4人同时使用"), @"该功能只能4人同时使用")


#define kStringPleaseOpenTheCameraInTheSetPermissions                                      \
JXT(NSLocalizedString(@"PleaseOpenTheCameraInTheSetPermissions", @"请在设置中打开的相机权限"), @"请在设置中打开的相机权限")
#define kStringMediaArraging                                      \
JXT(NSLocalizedString(@"MediaArraging", @"资源整理中..."), @"资源整理中...")


#endif

















