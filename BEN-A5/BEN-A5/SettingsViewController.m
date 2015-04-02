//
//  SettingsViewController.m
//  BEN-A5
//
//  Created by Nicole Sliwa on 3/25/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "BLE.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchVisualTemp;
@property (weak, nonatomic) IBOutlet UISwitch *switchManualColor;
@property (weak, nonatomic) IBOutlet UIImageView *imageColorWheel;

@end

@implementation SettingsViewController

-(BLE*)bleShield
{
    if(!_bleShield) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _bleShield = appDelegate.bleShield;
    }
    return _bleShield;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidDisconnect:) name:@"BLEDidDisconnect" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* enableMotor = [defaults objectForKey:@"enableMotor"];
    self.switchVisualTemp.on = [enableMotor boolValue];
    
    NSLog(@"get motor: %d", [enableMotor boolValue]);
    
    NSNumber* manualColor = [defaults objectForKey:@"manualColor"];
    self.switchManualColor.on = [manualColor boolValue];
    
    NSLog(@"get color: %d", [manualColor boolValue]);
    
    if(self.switchManualColor.on) {
        self.imageColorWheel.userInteractionEnabled = true;
        self.imageColorWheel.hidden = false;
    } else {
        self.imageColorWheel.userInteractionEnabled = false;
        self.imageColorWheel.hidden = true;
    }
        
}
- (IBAction)onToggleVisualTemp:(UISwitch*)sender {
    
    
    //TODO:
    // send message to arduino to toggle motor on/off
    
    if([self.bleShield isConnected]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[ NSNumber numberWithBool:sender.on ]  forKey:@"enableMotor"];
        
        [defaults synchronize];
        
        NSNumber* enableMotor = [defaults objectForKey:@"enableMotor"];
        
        NSLog(@"get motor: %d", [enableMotor boolValue]);
        
        [self BLEShieldSend:@"M" data:sender.on];
        NSLog(@"Message sent");
    }
    else {
        NSLog(@"No device connected");
        self.switchVisualTemp.on = !sender.on;
    }
    
    
}
- (IBAction)onToggleManualColor:(UISwitch*)sender {
    
    if([self.bleShield isConnected]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[ NSNumber numberWithBool:sender.on ]  forKey:@"manualColor"];
        
        [defaults synchronize];
        
        NSNumber* manualColor = [defaults objectForKey:@"manualColor"];
        
        NSLog(@"get color: %d", [manualColor boolValue]);
        
        if(sender.on) {
            self.imageColorWheel.userInteractionEnabled = true;
            self.imageColorWheel.hidden = false;
        } else {
            self.imageColorWheel.userInteractionEnabled = false;
            self.imageColorWheel.hidden = true;
            
        }
        
        [ self BLEShieldSend:@"C" data:0 ];
        NSLog(@"Message sent");
    }
    else {
        NSLog(@"No device connected");
        
        self.switchManualColor.on = !sender.on;
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier  isEqual: @"updateSettings"]) {
        // need do stuff?
    }
}

- (IBAction)didCancelView:(id)sender {
    NSLog(@"did dismiss modal view");
    [self.delegate didDismissModalView];
}

-(void)didDismissModalView:(id)sender{
    [self.delegate didDismissModalView];
}


- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // TODO:
        // map tappedcolor to buckets 0-12
        // send message to arduino to do something with tappedColor color
        
        NSLog(@"tap");
        
        if([self.bleShield isConnected]) {
            NSArray *colorBuckets = @[
                                      [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:255/255.0f], // white - 255,255,255
                                      [UIColor colorWithRed:255/255.0f green:0/255.0f blue:0/255.0f alpha:255/255.0f], // red - 255,0,0
                                      [UIColor colorWithRed:255/255.0f green:102/255.0f blue:0/255.0f alpha:255/255.0f], // red-orange - 255,102,0
                                      [UIColor colorWithRed:255/255.0f green:148/255.0f blue:0/255.0f alpha:255/255.0f], // orange -  255,148,0
                                      [UIColor colorWithRed:254/255.0f green:197/255.0f blue:0/255.0f alpha:255/255.0f], // orange-yellow - 254,197,0
                                      [UIColor colorWithRed:255/255.0f green:255/255.0f blue:0/255.0f alpha:255/255.0f], // yellow - 255,255,0
                                      [UIColor colorWithRed:140/255.0f green:199/255.0f blue:0/255.0f alpha:255/255.0f], // yellow-green - 140,199,0
                                      [UIColor colorWithRed:15/255.0f green:173/255.0f blue:0/255.0f alpha:255/255.0f], // green - 15,173,0
                                      [UIColor colorWithRed:0/255.0f green:163/255.0f blue:199/255.0f alpha:255/255.0f], // green-blue - 0,163,199
                                      [UIColor colorWithRed:0/255.0f green:100/255.0f blue:181/255.0f alpha:255/255.0f], // blue - 0,100,101
                                      [UIColor colorWithRed:0/255.0f green:16/255.0f blue:165/255.0f alpha:255/255.0f], // blue-purple - 0,16,165
                                      [UIColor colorWithRed:99/255.0f green:0/255.0f blue:165/255.0f alpha:255/255.0f], // purple - 99,0,165
                                      [UIColor colorWithRed:197/255.0f green:0/255.0f blue:124/255.0f alpha:255/255.0f], // purple-red - 197,0,124
                                      ];
            
            CGPoint point = [sender locationInView:self.imageColorWheel];
            NSLog(@"X location: %f", point.x);
            NSLog(@"Y Location: %f",point.y);
            
            UIColor* tappedColor = [self getPixelColorAtPoint:self.imageColorWheel.image x:point.x y:point.y];
            
            int colorBucket = (int)[colorBuckets indexOfObject:tappedColor];
            if( colorBucket == -1 ) {
                colorBucket = 0;
            }
            
            [ self BLEShieldSend:@"C" data:colorBucket ];
            NSLog(@"Message sent");
            
            NSLog(@"bucket: %d", colorBucket);
        }
        else {
            NSLog(@"No device connected");
        }
    }
    
}

- (IBAction)onDownSwipeGesture:(UISwipeGestureRecognizer *)sender {
    
    //TODO:
    // send message to arduino to do no color effects
    
    if([self.bleShield isConnected]) {
        [self BLEShieldSend:@"E" data:0];
        NSLog(@"Message sent");
    }
    else {
        NSLog(@"No device connected");
    }
    
    NSLog(@"swipe down");
}

- (IBAction)onSwipeRightGesture:(UISwipeGestureRecognizer *)sender {
    //TODO:
    // send message to arduino to go cw around color wheel
    
    if([self.bleShield isConnected]) {
        [self BLEShieldSend:@"E" data:2];
        NSLog(@"Message sent");
    }
    else {
        NSLog(@"No device connected");
    }
    
    NSLog(@"swipe right");
}

- (IBAction)onSwipeLeftGesture:(UISwipeGestureRecognizer *)sender {
    
    //TODO:
    // send message to arduino to go ccw around color wheel
    
    if([self.bleShield isConnected]) {
        [self BLEShieldSend:@"E" data:1];
        NSLog(@"Message sent");
    }
    else {
        NSLog(@"No device connected");
    }
    
    NSLog(@"swipe left");
}

//http://stackoverflow.com/a/18740588
-(void) OnBLEDidDisconnect:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth Disconnected"
                                                    message:@"Bluetooth Not Available"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
    
    NSLog(@"Disconnected");
}


// oringinal function found here:
// http://stackoverflow.com/questions/3284185/get-pixel-color-of-uiimage
- (UIColor*)getPixelColorAtPoint:(UIImage *)img x:(int)x y:(int)y {
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(img.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    int pixelInfo = ((img.size.width  * y) + x ) * 4; // The image is png
    
    UInt8 red = data[pixelInfo];         // If you need this info, enable it
    UInt8 green = data[(pixelInfo + 1)]; // If you need this info, enable it
    UInt8 blue = data[pixelInfo + 2];    // If you need this info, enable it
    UInt8 alpha = data[pixelInfo + 3];     // I need only this info for my maze game
    
    CFRelease(pixelData);
    
    UIColor* color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f]; // The pixel color info
    
    NSLog(@"width: %f | lenght: %f", img.size.width, img.size.height);
    NSLog(@"colors: RGB A %i %i %i  %i", red,green,blue,alpha);
    
    return color;
    
}


// TODO:
// split into 3 functions and move to SettingsVC
// -> 1) to toggle motor on/off on switch toggle [build msgStr: 'M' byte + 0/1 byte for off/on]
// -> 2) to send color on imgView tap [build msgStr: 'C' byte + 0-12 byte for color bucket]
// -> 3) to send effect on imgView swipe [build msgStr: 'E' byte + 0-2 for none/left/right light effect]
- (void)BLEShieldSend:(NSString*) protocolID data:(int)data
{
    NSString *payload;
    if(data < 10) {
        payload = [NSString stringWithFormat:@"0%d", data];
    }
    else {
        payload = [NSString stringWithFormat:@"%d", data];
    }
    
    NSString *msg = [NSString stringWithFormat:@"%@%@", protocolID, payload];
    const char *bytes = [msg UTF8String];
    //NSData* packet = [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSData* packet = [NSData dataWithBytes:bytes length:3];
    
    /*NSUInteger len = [packet length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [packet bytes], len);*/
    
//    NSUInteger msgSize = 3;
//    unsigned char *msgBuffer = (unsigned char *)calloc(msgSize, sizeof(unsigned char));
//    msgBuffer[0] = protocolID;
//    msgBuffer[1] = (char) data;
//    msgBuffer[2] = '\n';
//    
//    NSData* packet = [NSData dataWithBytes:(const void *)msgBuffer length:sizeof(unsigned char)*msgSize];
//    
//    NSLog(@"data: %d, %c | buffer: %s", data, (char)data, msgBuffer);
//    
//    free(msgBuffer);
    
    
//    NSData* protocolByte = [protocolID dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *payloadBytes = [NSData dataWithBytes:&data length:sizeof(data)];
////    /*NSData* payloadBytes = [NSKeyedArchiver archivedDataWithRootObject:data];*/
//    
//    NSMutableData *packet = [NSMutableData data];
//    [packet appendData:protocolByte];
//    [packet appendData:payloadBytes];
    
    
    NSString* myString;
    myString = [[NSString alloc] initWithData:packet encoding:NSASCIIStringEncoding];
    NSLog(@"message to send: %@", myString);
    
    
    if([self.bleShield isConnected]) {
        [self.bleShield write:packet];
        NSLog(@"Message sent");
    }
    else {
        NSLog(@"No device connected");
    }
    
    //free(bytes);
    
}
@end
