//
//  MasterViewController.h
//  BEN-A5
//
//  Created by Nicole Sliwa on 3/25/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BLEModalViewControllerDelegate <NSObject>
-(void)didDismissModalView;
@end

@interface MasterViewController : UITableViewController

@property (nonatomic, weak) id<BLEModalViewControllerDelegate> delegate;

@end
