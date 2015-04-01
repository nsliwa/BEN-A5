//
//  ViewController.m
//  BEN-A5
//
//  Created by Nicole Sliwa on 3/25/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "BLE.h"

#define kAPI_KEY @"7808cb7fa5475ae0"
#define kState @"TX"
#define kCity @"University_Park"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *tempImageView;
@property (strong, nonatomic) UIImageView *miserImageView;
@property (strong, nonatomic) UIProgressView *progressBar;

@property (nonatomic) float ambientTemperature;

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation ViewController

-(BLE*)bleShield
{
    if(!_bleShield) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _bleShield = appDelegate.bleShield;
    }
    return _bleShield;
}

-(NSURLSession*) session {
    if(!_session) {
        
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = 5.0;
        sessionConfig.timeoutIntervalForResource = 8.0;
        sessionConfig.HTTPMaximumConnectionsPerHost = 1;
        
        _session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
    }
    return _session;
}

-(float) ambientTemperature {
    if(!_ambientTemperature) {
        _ambientTemperature = 0.0;
    }
    
    return _ambientTemperature;
}

-(UIProgressView*) progressBar {
    if(!_progressBar) {
        _progressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(-8, 202, 330,20)];
        _progressBar.progress = 0.5f;
        _progressBar.progressViewStyle = UIProgressViewStyleBar;
        _progressBar.progressTintColor = [UIColor redColor];
        _progressBar.transform = CGAffineTransformMakeRotation( M_PI * 1.5 );
        [self.tempImageView addSubview:_progressBar];
    }
    return _progressBar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidConnect:) name:@"BLEDidConnect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidDisconnect:) name:@"BLEDidDisconnect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidUpdateRSSI:) name:@"BLEUpdatedRSSI" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidReceiveData:) name:@"BLEReceievedData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidReceiveData_Temp:) name:@"BLEReceievedData_Temp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnBLEDidReceiveData_Button:) name:@"BLEReceievedData_Button" object:nil];
    
    // register NSUserDefaults from plist
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"]]];
    
    // Testing miser animations

    
    NSData* data = [NSData dataWithBytes:@"Bloodborne" length:255];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEReceievedData_Button" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys: data, @"data",nil]] ;


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // additional setup

    // init progress bar
    self.progressBar.progress = [ self temperatureToProgress: self.ambientTemperature ];

}

//setup auto rotation in code
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - RSSI timer
NSTimer *rssiTimer;
-(void) readRSSITimer:(NSTimer *)timer
{
    [self.bleShield readRSSI]; // be sure that the RSSI is up to date
}

#pragma mark - BLEdelegate protocol methods
-(void) OnBLEDidUpdateRSSI:(NSNotification *)notification
{
    NSNumber* d = [[notification userInfo] objectForKey:@"RSSI"];
    
    NSLog(@"RSSI: %@", d.stringValue);
}

// NEW FUNCTION EXAMPLE: parse the received data from NSNotification
-(void) OnBLEDidReceiveData:(NSNotification *)notification
{
    NSData* d = [[notification userInfo] objectForKey:@"data"];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    
    NSLog(@"data received: %@", s);
}

-(void) OnBLEDidReceiveData_Temp:(NSNotification *)notification
{
    NSData* d = [[notification userInfo] objectForKey:@"data"];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    float temp = [s floatValue];
    NSLog(@"Ambient temp: %f", temp);
//    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ambientTemperature = [self temperatureToProgress:temp];
        self.progressBar.progress = self.ambientTemperature;
        
        NSLog(@"Ambient temp: %f", self.ambientTemperature);
    });
}

-(void) OnBLEDidReceiveData_Button:(NSNotification *)notification
{
    
    NSLog(@"miser animation");
    // programattically create UIImageView
    [self queryCurrentWeather:^(float temp) {
        if ( self.ambientTemperature > temp ) {
            self.miserImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heat_miser"]];
        }
        else {
            self.miserImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snow_miser"]];
        }
        
        self.miserImageView.frame = CGRectMake( self.view.frame.size.width/2.0 - 330 /2.0 , self.view.frame.size.height/2.0 - 350/2.0, 330,350);
        [self.view addSubview:self.miserImageView];
        
        //TODO:
        // animate UIImageView
        // delete UIImageView
        
        CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI);
        CGAffineTransform scale = CGAffineTransformMakeScale(0.01, 0.01);
        
        [UIView animateWithDuration:3.0f delay:0.5f options:0
                         animations:^{self.miserImageView.transform = CGAffineTransformConcat(rotate, scale);}
                         completion:^(BOOL finished){[self.miserImageView removeFromSuperview];}];
        
    }];
}

/*
//TODO:
// change from notification to function that gets called on OnBLEDidReceiveData_Temp
// calculate case '0' based on temp
-(void) OnBLEDidReceiveData_Color:(NSNotification *)notification
{
    int color = (int)[[[notification userInfo] objectForKey:@"data"] integerValue];
//    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    UIColor* tint = [UIColor redColor];
    
    if(color == 1) {
        tint = [UIColor yellowColor];
    } else if(color == 2) { // yellow-orange: 255-215-0
        tint = [UIColor colorWithRed:1.000 green:0.843 blue:0.000 alpha:1.000];
    } else if(color == 3) {
        tint = [UIColor orangeColor];
    } else if(color == 4) { // orange-red: 255-127-80
        tint = [UIColor colorWithRed:1.000 green:0.498 blue:0.314 alpha:1.000];
    } else if(color == 5) {
        tint = [UIColor redColor];
    } else if(color == 6) { // red-purple: 176-48-96
        tint = [UIColor colorWithRed:0.690 green:0.188 blue:0.376 alpha:1.000];
    } else if(color == 7) {
        tint = [UIColor purpleColor];
    } else if(color == 8) { // purple-blue: 0-0-205
        tint = [UIColor colorWithRed:0.000 green:0.000 blue:0.804 alpha:1.000];
    } else if(color == 9) {
        tint = [UIColor blueColor];
    } else if(color == 10) { // blue-green: 65-105-225
        tint = [UIColor colorWithRed:0.255 green:0.412 blue:0.882 alpha:1.000];
    } else if(color == 11) {
        tint = [UIColor greenColor];
    } else if(color == 12) { // green-yellow: 173-255-47
        tint = [UIColor colorWithRed:0.678 green:1.000 blue:0.184 alpha:1.000];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressBar.progressTintColor = tint;
    });
}
*/


//NEW did disconnect function
-(void) OnBLEDidDisconnect:(NSNotification *)notification
{
    [rssiTimer invalidate];
    NSLog(@"Disconnected");
}

//NEW did connect function
-(void) OnBLEDidConnect:(NSNotification *)notification
{
    //CHANGE 5.a: Remove all usage of the connect button and remove from storyboard
//    [self.spinner stopAnimating];
    
    NSString *deviceName =[notification.userInfo objectForKey:@"deviceName"];
    
    NSLog(@"Device name: %@", deviceName);
    
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
}


-(IBAction)updateSettings:(UIStoryboardSegue*)unwindeSegue {
    
}

-(float)temperatureToProgress:(float)temperature
{
    float temp_f = (temperature * (9.0/5.0)) + 32.0;
    return (temp_f + 42) / 145;
}


-(void)queryCurrentWeather:(void (^)(float temperature))completionHandler
{
    NSString *urlAsString = [NSString stringWithFormat:@"http://api.wunderground.com/api/%@/conditions/q/%@/%@.json", kAPI_KEY, kState, kCity];
    
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // do stuff to handle data
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        NSDictionary *results = [json valueForKey:@"current_observation"];
        float temperature = [[results valueForKey:@"temp_c"] floatValue];
        
        NSLog(@"Temperature %f", temperature);
        
        if (completionHandler) {
            completionHandler(temperature);
        }
        
    }];
    
    [dataTask resume];
    
    
}

@end
