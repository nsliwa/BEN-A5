//
//  AppDelegate.h
//  BEN-A5
//
//  Created by Nicole Sliwa on 3/25/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,BLEDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BLE* bleShield;


@end

