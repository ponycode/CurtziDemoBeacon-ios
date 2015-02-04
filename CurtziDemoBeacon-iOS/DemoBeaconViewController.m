//
//  DemoBeaconViewController.m
//  CurtziDemoBeacon-iOS
//
//  Created by Scott Eklund on 2/3/15.
//  Copyright (c) 2015 Curtzi. All rights reserved.
//

#import "DemoBeaconViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

#define CurtziBeaconUUIDString									@"E7746064-682A-471B-A637-7722DD8F043E"
#define CurtziDemoBeaconMajor									2			// 2:2 is the Curtzi Demo Tag, in Sunnyvale,CA
#define CurtziDemoBeaconMinor									2
#define CurtziDemoBeaconValidationString						@"DEMO"
#define CurtziBeaconRegionIdentifier							@"com.curtzi"

@interface DemoBeaconViewController ()<CBPeripheralManagerDelegate>
@property (nonatomic,strong) CBPeripheralManager *manager;
@property (weak, nonatomic) IBOutlet UISwitch *beaconPowerSwitch;
@property (weak, nonatomic) IBOutlet UILabel *beaconStatusLabel;

@end

@implementation DemoBeaconViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.beaconPowerSwitch.on = FALSE;
	self.beaconStatusLabel.text = @"Initializing";
	
	self.manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
	self.manager.delegate = self;
}

- (IBAction)beaconPowerSwitchDidChange:(UISwitch *)sender {
	if ( sender.on ) {
		[self startAdvertising];
	} else {
		NSLog( @"Stopping Advertising");
		[self stopAdvertising];
	}
}

-(void) startAdvertising;
{
	if( ![self.manager isAdvertising] ){
		self.beaconStatusLabel.text = @"Starting";
		[self.manager startAdvertising:[self advertisingData]];
	} else {
		self.beaconStatusLabel.text = @"Broadcasting";
	}
}

-(void) stopAdvertising;
{
	self.beaconStatusLabel.text = @"Not Broadcasting";
	[self.manager stopAdvertising];
}

-(NSMutableDictionary*) advertisingData;
{
	NSMutableDictionary *advertisementDict = [NSMutableDictionary dictionary];
	
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:CurtziBeaconUUIDString];
	CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
																		   major:CurtziDemoBeaconMajor
																		   minor:CurtziDemoBeaconMinor
																	  identifier:CurtziBeaconRegionIdentifier];
	
	[advertisementDict addEntriesFromDictionary:[beaconRegion peripheralDataWithMeasuredPower:nil]];
		
	NSString *advertismentLocalName = [NSString stringWithFormat:@"Curtzi        %@", CurtziDemoBeaconValidationString];

	[advertisementDict setObject:advertismentLocalName forKey:CBAdvertisementDataLocalNameKey];
	
	return advertisementDict;
}


#pragma mark - Peripheral Delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)manager;
{
	if( manager.state == CBPeripheralManagerStatePoweredOn ){
		if( self.beaconPowerSwitch.on ){
			[self startAdvertising];
		} else {
			self.beaconStatusLabel.text = @"Ready";
			self.beaconPowerSwitch.on = NO;
			self.beaconPowerSwitch.enabled = YES;
		}
	} else if ( manager.state == CBPeripheralManagerStatePoweredOff ){
		self.beaconPowerSwitch.on = NO;
		self.beaconPowerSwitch.enabled = NO;
		self.beaconStatusLabel.text = @"Please turn Bluetooth On";
	} else {
		self.beaconPowerSwitch.on = NO;
		self.beaconPowerSwitch.enabled = NO;
		self.beaconStatusLabel.text = @"Bluetooth isn't Available";
	}
	
	NSLog( @"Peripheral Mananger Did Update State: %d", (int)manager.state );
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error;
{
	if( error ){
		self.beaconStatusLabel.text = @"Failed to start broadcasting";
		NSLog( @"Failed to start advertising: %@", error );
	} else {
		self.beaconStatusLabel.text = @"Broadcasting";
		NSLog( @"Did Start Advertising" );
	}
}

@end
