//
//  AUType.h
//  AuraU
//
//  Created by Thundersoft on 15/2/8.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#ifndef AuraU_AUType_h
#define AuraU_AUType_h

typedef NS_ENUM(int, k_enum_Choose) {
    enum_notChoose,
    enum_isChoose
};

typedef NS_ENUM(int, k_MediaType) {
    PhotoMerge,
    MediaPhtot,
    MediaVideo,
    MediaMusic
};


typedef NS_ENUM(int, k_MediaActionType) {
    MediaActionInit,
    MediaActionAdd,
    MediaActionRemove,
    MediaActionUpdate
};


#endif
