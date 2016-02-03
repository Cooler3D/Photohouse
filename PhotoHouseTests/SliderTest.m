//
//  SliderTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/7/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface SliderTest : XCTestCase

@end

@implementation SliderTest

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

- (void)testSlider
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectZero];
    [slider setMinimumValue:-1.f];
    [slider setMaximumValue:1.f];
    [slider setValue:0.f];
    
    [self testSlider:slider];
}



- (void) testSlider:(UISlider *)sender
{
    //
    NSInteger defaultMax = 100;
    NSInteger defaultMin = -100;
    NSInteger defaultLenght = defaultMax - defaultMin;
    
    //
    NSInteger maxSlider = sender.maximumValue * 100;
    NSInteger minSlider = sender.minimumValue * 100;
    NSInteger curretSlider = sender.value * 100;
    NSInteger intLenght = maxSlider - minSlider;
    
    //
    if (intLenght < defaultLenght) {
        NSInteger aspect_ratio = defaultLenght / intLenght;
        maxSlider *= aspect_ratio;
        minSlider *= aspect_ratio;
        curretSlider *= aspect_ratio;
    } else if (intLenght > defaultLenght) {
        NSInteger aspect_ratio = intLenght / defaultLenght;
        maxSlider /= aspect_ratio;
        minSlider /= aspect_ratio;
        curretSlider /= aspect_ratio;
    }
    
    NSInteger delta = maxSlider - defaultMax;
    curretSlider -= delta;
    
    XCTAssertFalse(curretSlider < defaultMin, @"Current MIN Slider: %li", (long)curretSlider);
    XCTAssertFalse(curretSlider > defaultMax, @"Current MAX Slider: %li", (long)curretSlider);
    
}

@end
