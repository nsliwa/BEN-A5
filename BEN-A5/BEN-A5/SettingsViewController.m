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

//TODO:
// get shared instance of bleShield to send messages

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
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool enableMotor = [defaults objectForKey:@"enableMotor"];
    self.switchVisualTemp.on = enableMotor;
    
    bool manualColor = [defaults objectForKey:@"manualColor"];
    self.switchManualColor.on = manualColor;
    
    if(self.switchManualColor.on) {
        self.imageColorWheel.userInteractionEnabled = true;
        self.imageColorWheel.hidden = false;
    } else {
        self.imageColorWheel.userInteractionEnabled = false;
        self.imageColorWheel.hidden = true;
    }
    
}
- (IBAction)onToggleVisualTemp:(UISwitch*)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[ NSNumber numberWithBool:sender.on ]  forKey:@"enableMotor"];
    
    [defaults synchronize];
    
    //TODO:
    // send message to arduino to toggle motor on/off
}
- (IBAction)onToggleManualColor:(UISwitch*)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[ NSNumber numberWithBool:sender.on ]  forKey:@"manualColor"];
    
    [defaults synchronize];
    
    if(sender.on) {
        self.imageColorWheel.userInteractionEnabled = true;
        self.imageColorWheel.hidden = false;
    } else {
        self.imageColorWheel.userInteractionEnabled = false;
        self.imageColorWheel.hidden = true;
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier  isEqual: @"UpdateSettings"]) {
        // need do stuff?
    }
}


- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // TODO:
        // map tappedcolor to buckets 0-12
        // send message to arduino to do something with tappedColor color
        
        NSLog(@"tap");

        CGPoint point = [sender locationInView:self.imageColorWheel];
        NSLog(@"X location: %f", point.x);
        NSLog(@"Y Location: %f",point.y);
        
        UIColor* tappedColor = [self getPixelColorAtPoint:self.imageColorWheel.image x:point.x y:point.y];
        
    }
    
}


- (IBAction)onSwipeRightGesture:(UISwipeGestureRecognizer *)sender {
    //TODO:
    // send message to arduino to go cw around color wheel
    
    NSLog(@"swipe right");
}

- (IBAction)onSwipeLeftGesture:(UISwipeGestureRecognizer *)sender {
    
    //TODO:
    // send message to arduino to go ccw around color wheel
    
    NSLog(@"swipe left");
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
- (void)BLEShieldSend:(NSString*) protocolID data:(NSNumber*)data
{
    /*
    NSData* protocolByte = [protocolID dataUsingEncoding:NSUTF8StringEncoding];
    NSData* payloadBytes = [NSKeyedArchiver archivedDataWithRootObject:data];
    
    NSMutableData *packet = [NSMutableData protocolByte];
    [packet appendData:payloadBytes];
    
    if (self.textField.text.length > 16)
        s = [self.textField.text substringToIndex:16];
    else
        s = self.textField.text;
    
    s = [NSString stringWithFormat:@"%@\r\n", s];
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.bleShield write:d];
     */
}
@end
