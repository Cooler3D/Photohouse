//
//  DeviceManagerTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/4/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "DeviceManager.h"

@interface DeviceManagerTest : XCTestCase

@end

@implementation DeviceManagerTest
{
    DeviceManager *deviceManager;
}
- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    deviceManager = [[DeviceManager alloc] init];
}

- (void)tearDown
{
    deviceManager = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDeviceName
{
    NSString *device = [deviceManager getDeviceName];
    NSInteger loc = [device rangeOfString:@"ip"].location;
    XCTAssertTrue(loc == 0);
}


- (void) testDeviceModelName
{
    NSString *device = [deviceManager getDeviceModelName];
    XCTAssertTrue(device.length == 1);
    
    NSInteger model = [device integerValue];
    XCTAssertTrue(model >= 4 && model <7);
}
@end
