//
//  ViewController.h
//  BEN-A5
//
//  Created by Nicole Sliwa on 3/25/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import "SettingsViewController.h"
#import "MasterViewController.h"

@interface ViewController : UIViewController <NSURLSessionDelegate, ModalViewControllerDelegate, BLEModalViewControllerDelegate, UIAlertViewDelegate>


//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
//@property (weak, nonatomic) IBOutlet UITextField *textField;
//@property (weak, nonatomic) IBOutlet UILabel *label;
//@property (weak, nonatomic) IBOutlet UILabel *labelRSSI;
@property (weak, nonatomic) BLE *bleShield;
//@property (weak, nonatomic) IBOutlet UILabel *labelPeripheral;

@end

