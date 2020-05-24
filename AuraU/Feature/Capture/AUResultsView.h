//
//  AUResultsView.h
//  AuraU
//
//  Created by Army on 15-3-17.
//  Copyright (c) 2015年 Thundersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCancelButtonClicked        (@"CancelButtonClicked")
#define kOkButtonClicked            (@"OkButtonClicked")

@class AUResultsView;
@protocol AUResultsViewelegate<NSObject>

- (void)AUResultsViewIsCancelButtonClicked:(AUResultsView *)resultsView;
- (void)AUResultsViewIsOkButtonClicked:(AUResultsView *)resultsView;
@end

@interface AUResultsView : UIViewController
@property (weak, nonatomic) id <AUResultsViewelegate>delegate;

@property (nonatomic,strong)IBOutlet UIImageView *imageView;
@end
