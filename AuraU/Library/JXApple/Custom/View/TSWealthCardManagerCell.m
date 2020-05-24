//
//  TSWealthCardManagerCell.m
//  CMBCEcosphere
//
//  Created by Thundersoft on 10/6/14.
//  Copyright (c) 2014 Zhou , Hongjun. All rights reserved.
//

#import "TSWealthCardManagerCell.h"
//#import "TSManager.h"

@implementation TSWealthCardManagerCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setManager:(TSManager *)manager
{
    
}

+ (CGFloat)height
{
    return 100;
}

+ (NSString *)identifier
{
    return @"TSWealthCardManagerCellIdentifier";
}
@end
