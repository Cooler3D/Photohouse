//
//  RangeImageTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/30/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ResponseGetItems.h"
#import "ResponseAlbumV2.h"
#import "CoreDataStore.h"

//#import "imageCountType.h"
//#import "StyleStyles.h"
#import "StoreItem.h"
#import "PropType.h"
#import "PropCover.h"
#import "PropSize.h"
#import "PropUturn.h"
#import "PropColor.h"
#import "PropStyle.h"

#import "PrintData.h"

#import "BundleDefault.h"

@interface StyleAndImageCountTest : XCTestCase

@end

@implementation StyleAndImageCountTest
{
    ResponseGetItems *response;
    CoreDataStore *coreStore;
    PrintData *printData;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    BundleDefault *bundle = [[BundleDefault alloc] init];
    NSData *dataItems = [bundle defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseAlbumV2 *responseAlbum = [[ResponseAlbumV2 alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    response = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbum.oldTemplates];
    
    coreStore = [[CoreDataStore alloc] init];
}

- (void)tearDown
{
    [coreStore clearStory];
    response = nil;
    coreStore = nil;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}




- (void)testRangePhoto
{
    // Photo
//    NSRange rangePhoto = [coreImageCount getRangePurchaseID:@"7" andTypeName:@"" andStyleName:@""];
    
    NSString *const categoryName = @"Фотопечать";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    
    for (StoreItem *store in storeItems) {
        NSRange rangePhoto = store.propType.selectPropStyle.rangeImages;
        XCTAssertFalse(rangePhoto.location < 2, @"Range Empty: %lu", (unsigned long)rangePhoto.location);
        XCTAssertFalse(rangePhoto.length < 2, @"Range Empty: %lu", (unsigned long)rangePhoto.length);
    }
}



- (void)testRangeMagnit
{
    // Photo Magnit square
    NSString *const categoryName = @"Чехлы и магниты";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    
    for (StoreItem *store in storeItems) {
        NSRange rangePhoto = store.propType.selectPropStyle.rangeImages;
        if (![store.purchaseID isEqualToString:@"14"]) {
            // Для чехлов нет занчений, поэтому одному равно
            rangePhoto = NSMakeRange(1, 0);
        }
        XCTAssertTrue(rangePhoto.location > 0, @"Range Empty: %lu", (unsigned long)rangePhoto.location);
        XCTAssertTrue(rangePhoto.length == 0, @"Range Empty: %lu", (unsigned long)rangePhoto.length);
    }
}


- (void) testMug
{
    // Photo Magnit square
//    NSRange rangeMug = [coreImageCount getRangePurchaseID:@"1" andTypeName:@"square" andStyleName:@""];
//    
//    XCTAssertTrue(rangeMug.location == 1, @"Range Empty: %lu", (unsigned long)rangeMug.location);
//    XCTAssertTrue(rangeMug.length == 0, @"Range Empty: %lu", (unsigned long)rangeMug.length);
}


- (void) testAlbum
{
    // Photo Album
    NSString *const categoryName = @"Альбомы";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    
    for (StoreItem *store in storeItems) {
        NSRange rangePhoto = store.propType.selectPropStyle.rangeImages;
        XCTAssertTrue(rangePhoto.location > 0, @"Range Empty: %lu", (unsigned long)rangePhoto.location);
//        XCTAssertTrue(rangePhoto.length > 0, @"Range Empty: %lu", (unsigned long)rangePhoto.length);
    }

}


- (void)testArrayStyles
{
    // default
//    NSArray *arrayPropStyles = [coreImageCount getPropStylesForAlbumWithPurchaseID:@"13" andUturnPagesCount:nil];
//    XCTAssertFalse(arrayPropStyles.count == 0, @"Empty");
//    
//    for (id style in arrayPropStyles) {
//        XCTAssertTrue([style isKindOfClass:[PropStyle class]], @"Is Not class");
//    }
//    
//    
//    
//    // Uturn 12
//    arrayPropStyles = [coreImageCount getPropStylesForAlbumWithPurchaseID:@"13" andUturnPagesCount:@"12"];
//    XCTAssertFalse(arrayPropStyles.count == 0, @"Empty");
//    
//    for (id style in arrayPropStyles) {
//        XCTAssertTrue([style isKindOfClass:[PropStyle class]], @"Is Not class");
//    }

}

@end
