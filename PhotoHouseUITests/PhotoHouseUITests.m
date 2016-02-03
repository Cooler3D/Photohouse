//
//  PhotoHouseUITests.m
//  PhotoHouseUITests
//
//  Created by Мартынов Дмитрий on 11/10/15.
//  Copyright © 2015 ___FULLUSERNAME___. All rights reserved.
//

#import <XCTest/XCTest.h>

//#import "CoreDataShopCart.h"

@interface PhotoHouseUITests : XCTestCase

@end

@implementation PhotoHouseUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = YES;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddTShitToCart{
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    [app.tables.cells.staticTexts[@"SOUVENIRS AND GIFTS"] tap];
//    
//    XCUIElementQuery *collectionViewsQuery = app.collectionViews;
//    [collectionViewsQuery.staticTexts[@"T-Shirt"] tap];
//    [app.buttons[@"Choose Photo"] tap];
//#warning Todo: If photolibrary auth
////    [app.alerts[@"\U201cPhotoHouse\U201d Would Like to Access Your Photos"].collectionViews.buttons[@"OK"] tap];
//    collectionViewsQuery = app.collectionViews;
//    [[collectionViewsQuery.cells elementBoundByIndex:0] tap];
//    [app.navigationBars[@"Choose Photo"].buttons[@"OK"] tap];
//    [app.navigationBars[@"T-Shirt"].buttons[@"to Cart"] tap];
}


- (void) testAddDesignAlbumToCart {
    
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    XCUIElement *cell = [app.tables.cells elementBoundByIndex:0];
//    
//    XCUIElementQuery *cellView = [cell childrenMatchingType:XCUIElementTypeScrollView];
//    XCUIElementQuery *scroll = [cell childrenMatchingType:XCUIElementTypeScrollView];
//    XCUIElementQuery *tool = [scroll childrenMatchingType:XCUIElementTypeOther];
//    NSString *text = scroll.debugDescription;
//    [scroll.element coordinateWithNormalizedOffset:CGVectorMake(60, 60)];
//    [tool.element tap];
//    NSLog(@"%@; %@", text, tool.description);
//    [scroll tap];
//    [elem tap];
}

@end
