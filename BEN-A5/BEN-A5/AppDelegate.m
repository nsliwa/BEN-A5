//
//  AppDelegate.m
//  BEN-A5
//
//  Created by Nicole Sliwa on 3/25/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - BLE Delegate
-(void) bleDidConnect
{
    NSLog(@"BLE Connected");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEDidConnect" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.bleShield.activePeripheral.name,@"deviceName", nil]];
}
-(void) bleDidDisconnect
{
    NSLog(@"BLE Disconnected");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEDidDisconnect" object:self] ;
}
-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    // note that this does not run consistently in the app delegate
    NSLog(@"BLE Updated RSSI");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEUpdatedRSSI" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:rssi,@"RSSI", nil]];
}
-(void) bleDidReceiveData:(unsigned char *) data length:(int) length
{
    NSArray *protocolIDs = @[@"T", @"B", @"M", @"E", @"C"];
    
    NSLog(@"BLE ReceivedData");
    
    NSData* myData = [NSData dataWithBytes:data length:length];
    
    
    // get protocol id
    NSData *msgProtocol = [myData subdataWithRange:NSMakeRange(0, 1)]; // make sure if data has n bytes
    NSString *protocol = [[NSString alloc] initWithData:msgProtocol encoding:NSUTF8StringEncoding];
    
    // get data bytes
    NSData *msgData = [myData subdataWithRange:NSMakeRange(1, length-1)]; // make sure if data has n bytes
    
    int protocolID = [protocolIDs indexOfObject:protocol];
    
    switch (protocolID) {
        case 0:
            NSLog(@"temp");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEReceievedData_Temp" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys: msgData, @"data",nil]] ;
            break;
        case 1:
            NSLog(@"button");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEReceievedData_Button" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys: msgData, @"data",nil]] ;
            break;
        case 2:
            NSLog(@"motor - shouldn't get from A");
            break;
        case 3:
            NSLog(@"effect - shouldn't get from A");
            break;
        case 4:
            NSLog(@"color - shouldn't get from A");
            break;
        default:
            NSLog(@"default - missing protocol");
            break;
    }
    
    // available notifications
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEReceievedData_Temp" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys: msgData, @"data",nil]] ;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEReceievedData_Color" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys: msgData, @"data",nil]] ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEReceievedData" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys: msgData, @"data",nil]] ;
    
}
#pragma mark - Application Deletate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.bleShield = [[BLE alloc] init];
    [self.bleShield controlSetup];
    self.bleShield.delegate = self;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
