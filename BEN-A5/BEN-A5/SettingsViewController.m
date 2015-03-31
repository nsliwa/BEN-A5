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
@property (weak, nonatomic) IBOutlet ColorPickerImageView *imageColorWheel;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageColorWheel.pickedColorDelegate = self;
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
        // do stuff?
    }
}


- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // handling code
        // TODO:
        // get pixel color of tapped image position
        
        NSLog(@"tap");

        CGPoint point = [sender locationInView:self.imageColorWheel];
        NSLog(@"X location: %f", point.x);
        NSLog(@"Y Location: %f",point.y);
        
        [self getPixelColorAtLocation:point];
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

- (void) pickedColor:(UIColor*)color {
    NSLog(@"color updated");
}


- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
    UIColor* color = nil;
    CGImageRef inImage = self.imageColorWheel.image.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return nil; /* error */ }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    // When finished, release the context
    CGContextRelease(cgctx); 
    // Free image data memory for the context
    if (data) { free(data); }
    
    return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (int)(pixelsWide * 4);
    bitmapByteCount     = (int)(bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

@end
