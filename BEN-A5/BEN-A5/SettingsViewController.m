//
//  SettingsViewController.m
//  BEN-A5
//
//  Created by Nicole Sliwa on 3/25/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchVisualTemp;
@property (weak, nonatomic) IBOutlet UISwitch *switchManualColor;
@property (weak, nonatomic) IBOutlet UIImageView *imageColorWheel;

//TODO:
// get shared instance of bleShield to send messages

@end

@implementation SettingsViewController

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
@end
