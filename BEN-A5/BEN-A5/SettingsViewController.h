//
//  SettingsViewController.h
//  BEN-A5
//
//  Created by Nicole Sliwa on 3/25/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@protocol ModalViewControllerDelegate <NSObject>
-(void)didDismissModalView;
@end

@interface SettingsViewController : UIViewController

@property (nonatomic, weak) id<ModalViewControllerDelegate> delegate;
@property (weak, nonatomic) BLE *bleShield;

@end
