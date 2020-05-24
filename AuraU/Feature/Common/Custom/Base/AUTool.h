//
//  AUTool.h
//  AuraU
//
//  Created by Thundersoft on 15/2/8.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#ifndef AuraU_AUTool_h
#define AuraU_AUTool_h

//#define AUShowCustomAlertSuccess(msg)      \
//[[TWMessageBarManager sharedInstance] hideAll]; [[TWMessageBarManager sharedInstance] showMessageWithTitle:kStringSuccess description:(msg) type:TWMessageBarMessageTypeSuccess duration:1.5];
//#define AUShowCustomAlertFailure(msg)      \
//[[TWMessageBarManager sharedInstance] hideAll]; [[TWMessageBarManager sharedInstance] showMessageWithTitle:kStringFailure description:(msg) type:TWMessageBarMessageTypeError duration:1.5];
//#define AUShowCustomAlertHint(msg)      \
//[[TWMessageBarManager sharedInstance] hideAll]; [[TWMessageBarManager sharedInstance] showMessageWithTitle:kStringHint description:(msg) type:TWMessageBarMessageTypeInfo duration:1.5];

#define AUAlertHUDTips(msg)                     \
[MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES hideAnimated:YES hideDelay:2.5 mode:MBProgressHUDModeText type:0 customView:nil labelText:nil detailsLabelText:(msg) square:NO dimBackground:NO color:nil removeFromSuperViewOnHide:NO labelFont:18.0f detailsLabelFont:16.0f];

#define AUAlertCaptureHUDTips(msg)                     \
[MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].delegate window] animated:YES hideAnimated:YES hideDelay:2.5 mode:MBProgressHUDModeText type:0 customView:nil labelText:nil detailsLabelText:(msg) square:NO dimBackground:NO color:nil removeFromSuperViewOnHide:NO labelFont:18.0f detailsLabelFont:16.0f];

#define AUAlertHUDProcessing(msg)   JXAlertHUDProcessing(msg)
#define AUAlertHUDHide()            JXAlertHUDHide()

#endif
