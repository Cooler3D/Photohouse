//
//  TimeTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/5/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSDate+ServerTime.h"

@interface ServerTimeTest : XCTestCase

@end

@implementation ServerTimeTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConvertServerTimeToDate
{
    NSString *serverTime = @"1436127948";//@"1436128225.9525";
    NSDate *dateServ = [NSDate convertToDateWithServerTimer:serverTime];
    XCTAssertTrue([dateServ earlierDate:[NSDate date]]);
    
    NSString *getItems = @"1436137948";
    NSDate *dateItems = [NSDate convertToDateWithServerTimer:getItems];
    NSLog(@"%@", dateItems);
    XCTAssertTrue([dateServ compare:dateItems] == NSOrderedAscending);
}

@end
