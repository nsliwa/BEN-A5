//
//  MasterViewController.m
//  BEN-A5
//
//  Created by Nicole Sliwa on 3/25/15.
//  Copyright (c) 2015 Team B.E.N. All rights reserved.
//

#import "MasterViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "BLE.h"

@interface MasterViewController ()

@property (strong, nonatomic) BLE* bleShield;

@end

@implementation MasterViewController

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
    
    UIRefreshControl * refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(scanForDevices) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self scanForDevices];
    
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
}

// Scan for devices for 3 seconds, then populate table with UUID and peripheral name
// To connect, click on device name
-(void)scanForDevices
{
    
    NSLog(@"Scan for peripherals");
    // disconnect from any peripherals
    if (self.bleShield.activePeripheral)
        if(self.bleShield.activePeripheral.isConnected)
        {
            [[self.bleShield CM] cancelPeripheralConnection:[self.bleShield activePeripheral]];
            return;
        }
    
    // set peripheral to nil
    if (self.bleShield.peripherals)
        self.bleShield.peripherals = nil;
    
    //start search for peripherals with a timeout of 3 seconds
    // this is an asunchronous call and will return before search is complete
    [self.bleShield findBLEPeripherals:3];
    
    // after three seconds, try to connect to first peripheral
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0
                                     target:self
                                   selector:@selector(didFinishScanning:)
                                   userInfo:nil
                                    repeats:NO];
}

-(void) didFinishScanning:(NSTimer*) timer{
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section==0){
        return [self.bleShield.peripherals count];
    }
    else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BLECell" forIndexPath:indexPath];
    
    if(indexPath.section==0){
        CBPeripheral* aPeripheral = [self.bleShield.peripherals objectAtIndex:indexPath.row];
        
        // Configure the cell...
        cell.textLabel.text = aPeripheral.name;
        cell.detailTextLabel.text = aPeripheral.identifier.UUIDString;
        
    }
    else {
        
        cell.textLabel.text = @"Cancel";
        cell.detailTextLabel.text = @"";
        
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0) {
    
        NSLog(@"Attemp to connect to peripherals %ld", (long)indexPath.row);
        CBPeripheral *aPeripheral = [self.bleShield.peripherals objectAtIndex:indexPath.row];
        
        if (self.bleShield.activePeripheral && self.bleShield.activePeripheral.isConnected) {
            [[self.bleShield CM] cancelPeripheralConnection:[self.bleShield activePeripheral]];
        }
        
        //CHANGE 6: add code her to connect to the selected peripheral (aPeripheral)
        [self.bleShield connectPeripheral: aPeripheral];
    
    }
        
    [self.delegate didDismissModalView];
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier  isEqual: @"updateBLE"]) {
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

@end
