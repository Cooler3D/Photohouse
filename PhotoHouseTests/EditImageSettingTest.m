//
//  EditImageSettingTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/4/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "EditImageSetting.h"

#import "PPBaseFilter.h"

@interface EditImageSettingTest : XCTestCase

@end

@implementation EditImageSettingTest
{
    EditImageSetting *editSetting;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    editSetting = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEditSettingDefault
{
    editSetting = [[EditImageSetting alloc] initFilterName:DEFAUL_FILTER andSaturation:DEFAULT_SATURATION andBrightness:DEFAULT_BRIGHTNESS andContrast:DEFAULT_CONSTRAST andCropRect:CGRectZero andRectToVisible:CGRectZero andAutoResizingEnabled:YES andImageOrientation:UIImageOrientationUp andImageDefautlOrientation:UIImageOrientationUp];
    
    XCTAssertFalse(editSetting.isDidEditing, @"Setting edited");
}


- (void) testEditSettingParams {
    editSetting = [[EditImageSetting alloc] initFilterName:@"Filter" andSaturation:DEFAULT_SATURATION andBrightness:DEFAULT_BRIGHTNESS andContrast:DEFAULT_CONSTRAST andCropRect:CGRectZero andRectToVisible:CGRectZero andAutoResizingEnabled:YES andImageOrientation:UIImageOrientationUp andImageDefautlOrientation:UIImageOrientationUp];
    
    XCTAssertTrue(editSetting.isDidEditing, @"Setting edited");
}


- (void) testEditSettingImage {
    editSetting = [[EditImageSetting alloc] initSettingWithImage:[UIImage imageNamed:@"logo"]];
    XCTAssertFalse(editSetting.isDidEditing, @"Setting edited");
}


- (void)testApplyFilter {
    NSString *filter = [[PPBaseFilter allFilters] firstObject];
    UIImageOrientation orientation = UIImageOrientationLeft;
    UIImage *input = [UIImage imageNamed:@"run2"];
    CGSize inputSize = input.size;
    
    editSetting = [[EditImageSetting alloc] initFilterName:filter andSaturation:DEFAULT_SATURATION andBrightness:DEFAULT_BRIGHTNESS andContrast:DEFAULT_CONSTRAST andCropRect:CGRectZero andRectToVisible:CGRectZero andAutoResizingEnabled:YES andImageOrientation:orientation andImageDefautlOrientation:UIImageOrientationUp];
    UIImage *result = [editSetting executeImage:input];
    CGSize resultSize = result.size;
    
    XCTAssertTrue(result);
    XCTAssertTrue(inputSize.width == resultSize.height);
    XCTAssertTrue(inputSize.height == resultSize.width);
}


- (void) testAllFilters {
    XCTAssertTrue([PPBaseFilter allFilters].count > 0);
}

@end
