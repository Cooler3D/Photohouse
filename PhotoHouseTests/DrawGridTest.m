//
//  DrawGridTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/20/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>


#import "DrawGridView.h"

@interface DrawGridTest : XCTestCase

@end

@implementation DrawGridTest

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

- (void) testDrawGrid
{
    DrawGridView *view = [[DrawGridView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    NSLog(@"View: %@", view);
    XCTAssertNotNil(view, @"View is Nil");
}

@end
