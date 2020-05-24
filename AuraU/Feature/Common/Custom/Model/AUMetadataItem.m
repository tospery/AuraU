//
//  AUMetadataItem.m
//  AuraU
//
//  Created by Thundersoft on 15/3/6.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import "AUMetadataItem.h"


//<MetadataItem>
//    <![CDATA[Type<photo>ID<2106>Path</storage/emulated/0/Pictures/Screenshots/Screenshot_2015-02-10-09-33-50.png>Length<199372>DateModified<1423532030>DateTaken<1423532030688>Orientation<0>Width<1080>Height<1920>]]>
//</MetadataItem>

@implementation AUMetadataItem
//- (void)encodeWithCoder:(NSCoder *)coder
//{
//    [coder encodeObject:[NSNumber numberWithInteger:_userid] forKey:@"userid"];
//    [coder encodeObject:[NSNumber numberWithInteger:_dreamprogress] forKey:@"dreamprogress"];
//    [coder encodeObject:[NSNumber numberWithInteger:_ordercount] forKey:@"ordercount"];
//    [coder encodeObject:[NSNumber numberWithInteger:_goldcoin] forKey:@"goldcoin"];
//    [coder encodeObject:[NSNumber numberWithInteger:_postcount] forKey:@"postcount"];
//    [coder encodeObject:[NSNumber numberWithInteger:_couponcount] forKey:@"couponcount"];
//    [coder encodeObject:[NSNumber numberWithInteger:_elecCouponCount] forKey:@"elecCouponCount"];
//    [coder encodeObject:[NSNumber numberWithInteger:_lotteryCount] forKey:@"lotteryCount"];
//    [coder encodeObject:[NSNumber numberWithBool:_logging] forKey:@"logging"];
//    [coder encodeObject:_nickname forKey:@"nickname"];
//    [coder encodeObject:_avatar forKey:@"avatar"];
//    [coder encodeObject:_mobile forKey:@"mobile"];
//    [coder encodeObject:_email forKey:@"email"];
//    [coder encodeObject:_lastCheckin forKey:@"lastCheckin"];
//    [coder encodeObject:_membershipcards forKey:@"membershipcards"];
//    [coder encodeObject:_address forKey:@"address"];
//    [coder encodeObject:_allCheckinCount forKey:@"allCheckinCount"];
//    [coder encodeObject:_checkin forKey:@"checkin"];
//    [coder encodeObject:_shareUrl forKey:@"shareUrl"];
//    [coder encodeObject:_given forKey:@"given"];
//}
//
//- (id)initWithCoder:(NSCoder *)coder {
//    if (self = [super init]) {
//        _userid = [(NSNumber *)[coder decodeObjectForKey:@"userid"] integerValue];
//        _dreamprogress = [(NSNumber *)[coder decodeObjectForKey:@"dreamprogress"] integerValue];
//        _ordercount = [(NSNumber *)[coder decodeObjectForKey:@"ordercount"] integerValue];
//        _goldcoin = [(NSNumber *)[coder decodeObjectForKey:@"goldcoin"] integerValue];
//        _postcount = [(NSNumber *)[coder decodeObjectForKey:@"postcount"] integerValue];
//        _couponcount = [(NSNumber *)[coder decodeObjectForKey:@"couponcount"] integerValue];
//        _elecCouponCount = [(NSNumber *)[coder decodeObjectForKey:@"elecCouponCount"] integerValue];
//        _lotteryCount = [(NSNumber *)[coder decodeObjectForKey:@"lotteryCount"] integerValue];
//        _logging = [(NSNumber *)[coder decodeObjectForKey:@"logging"] boolValue];
//        _nickname = [coder decodeObjectForKey:@"nickname"];
//        _avatar = [coder decodeObjectForKey:@"avatar"];
//        _mobile = [coder decodeObjectForKey:@"mobile"];
//        _email = [coder decodeObjectForKey:@"email"];
//        _lastCheckin = [coder decodeObjectForKey:@"lastCheckin"];
//        _membershipcards = [coder decodeObjectForKey:@"membershipcards"];
//        _address = [coder decodeObjectForKey:@"address"];
//        _allCheckinCount =   [coder decodeObjectForKey:@"allCheckinCount"];
//        _checkin =   [coder decodeObjectForKey:@"checkin"];
//        _shareUrl =   [coder decodeObjectForKey:@"shareUrl"];
//        _given =   [coder decodeObjectForKey:@"given"];
//    }
//    return self;
//}
//
#pragma mark - NSCoping methods
- (id)copyWithZone:(NSZone *)zone {
    AUMetadataItem *copy = [[[self class] allocWithZone:zone] init];
    copy.identifier = _identifier;
    copy.type = _type;
    copy.path = _path;
    copy.albumTitle = _albumTitle;
    copy.artist = _artist;
    copy.lengthBytes = _lengthBytes;
    return copy;
}

+ (NSArray *)typeRepresents {
    static NSArray *represents;
    if (!represents) {
        represents = @[@"photo", @"music", @"video",@"photoMerge",@"faceScan"];
    }
    return represents;
}
@end
