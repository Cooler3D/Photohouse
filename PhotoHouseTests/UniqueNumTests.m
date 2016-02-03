//
//  PhotoHouseTests.m
//  PhotoHouseTests
//
//  Created by Дмитрий Мартынов on 8/5/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "UniqueNum.h"

@interface UniqueNumTests : XCTestCase
@end


@implementation UniqueNumTests

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

- (void)testCreateUnique
{
    NSMutableArray *indexs = [NSMutableArray array];
    
    for (int i=0; i<10000; i++) {
        NSUInteger index = [UniqueNum getUniqueID];
        [indexs addObject:[NSNumber numberWithInteger:index]];
    }
    
    
    // Check
    for (NSNumber *number in indexs) {
        NSUInteger curIndex = [number integerValue];
        BOOL isOne = NO;
        for (NSNumber *number in indexs) {
            NSUInteger index = [number integerValue];
            if (index == curIndex) {
                isOne = YES;
            } else if (index == curIndex && isOne) {
                XCTFail(@"Index: %li == Index: %li", (long)curIndex, (long)index);
            }
        }
    }
}

@end
