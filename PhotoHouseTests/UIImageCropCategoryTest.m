//
//  UIImageCropCategoryTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 4/3/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "UIImage+Crop.h"

@interface UIImageCropCategoryTest : XCTestCase

@end

@implementation UIImageCropCategoryTest

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

- (void)testDrawText
{
    UIImage *image = [UIImage imageNamed:@"squareImage"];
    
    UIImage *result = [image drawText:@"Preview"];
    XCTAssertNotNil(result, @"Image nil");
}



- (void) testInsertImageSizeToMainSizeIphone5Portrait
{
    UIImage *image = [UIImage imageNamed:@"albumBack"];
    CGRect insertRect = CGRectMake(0.f, 54.f, 320.f, 464.f);
    CGRect rect = [image insertToCenterRect:insertRect];
    XCTAssertFalse(CGRectEqualToRect(CGRectZero, rect), @"Rect Zero");
    
    //XCTAssertTrue(CGRectGetMinX(rect) > 0, @"X");
    XCTAssertTrue(CGRectGetMinY(rect) > 0, @"Y");
    XCTAssertTrue(CGRectGetWidth(rect) > 0, @"Width");
    XCTAssertTrue(CGRectGetHeight(rect) > 0, @"Height");
}


- (void) testInsertImageSizeToMainSizeIphone5Panorama
{
    UIImage *image = [UIImage imageNamed:@"albumBack"];
    CGRect insertRect = CGRectMake(0.f, 54.f, 568.f, 216.f);
    CGRect rect = [image insertToCenterRect:insertRect];
    XCTAssertFalse(CGRectEqualToRect(CGRectZero, rect), @"Rect Zero");
    
    XCTAssertTrue(CGRectGetMinX(rect) > 0, @"X");
    XCTAssertTrue(CGRectGetMinY(rect) > 0, @"Y");
    XCTAssertTrue(CGRectGetWidth(rect) > 0, @"Width");
    XCTAssertTrue(CGRectGetHeight(rect) > 0, @"Height");
}



- (void) testInsertImageSizeToMainSizeIphone4Portrait
{
    UIImage *image = [UIImage imageNamed:@"albumBack"];
    CGRect insertRect = CGRectMake(0.f, 54.f, 320.f, 376.f);
    CGRect rect = [image insertToCenterRect:insertRect];
    XCTAssertFalse(CGRectEqualToRect(CGRectZero, rect), @"Rect Zero");
    
    //XCTAssertTrue(CGRectGetMinX(rect) > 0, @"X");
    XCTAssertTrue(CGRectGetMinY(rect) > 0, @"Y");
    XCTAssertTrue(CGRectGetWidth(rect) > 0, @"Width");
    XCTAssertTrue(CGRectGetHeight(rect) > 0, @"Height");
}


- (void) testInsertImageSizeToMainSizeIphone4Panorama
{
    UIImage *image = [UIImage imageNamed:@"albumBack"];
    CGRect insertRect = CGRectMake(0.f, 54.f, 480.f, 216.f);
    CGRect rect = [image insertToCenterRect:insertRect];
    XCTAssertFalse(CGRectEqualToRect(CGRectZero, rect), @"Rect Zero");
    
    //XCTAssertTrue(CGRectGetMinX(rect) > 0, @"X");
    XCTAssertTrue(CGRectGetMinY(rect) > 0, @"Y");
    XCTAssertTrue(CGRectGetWidth(rect) > 0, @"Width");
    XCTAssertTrue(CGRectGetHeight(rect) > 0, @"Height");
}

@end
