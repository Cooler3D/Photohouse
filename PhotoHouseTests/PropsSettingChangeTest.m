//
//  AlbumSettingTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/3/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CoreDataStore.h"
//#import "CoreDataImageCount.h"

#import "ResponseGetItems.h"
//#import "ResponseGetImagesCount.h"

#import "StoreItem.h"
#import "PropType.h"
#import "PropCover.h"
#import "PropSize.h"
#import "PropUturn.h"
#import "PropColor.h"
#import "PropStyle.h"

#import "PrintData.h"

#import "BundleDefault.h"


@interface PropsSettingChangeTest : XCTestCase

@end


@implementation PropsSettingChangeTest
{
    CoreDataStore *coreStore;
    //CoreDataImageCount *coreImage;
    
    ResponseGetItems *response;
    //ResponseGetImagesCount *responseImageRenge;
}


- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    BundleDefault *bundle = [[BundleDefault alloc] init];
    response = [[ResponseGetItems alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAllItems]];
    //responseImageRenge = [[ResponseGetImagesCount alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeRangeImages]];

    
    coreStore = [[CoreDataStore alloc] init];
    //coreImage = [[CoreDataImageCount alloc] init];
}


- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



#pragma mark - Album
- (void)testPropsSettingAlbum
{
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:@"Альбомы"];
    
    for (StoreItem *storeItem in storeItems) {
        PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
        
        PropType *propSetting = [printData.storeItem propType];
        XCTAssertTrue([propSetting isKindOfClass:[PropType class]], @"Do not Setting Class");
        
        PropCover *defaultCover = [propSetting selectPropCover];
        PropStyle *defaultStyle = [propSetting selectPropStyle];
        
        XCTAssertFalse(defaultCover.cover.length == 0, @"Cover is Empty");
        XCTAssertTrue([defaultCover isKindOfClass:[PropCover class]], @"Do not PropCover Class");
        
        XCTAssertFalse(defaultStyle.styleName.length == 0, @"Style is Empty");
        XCTAssertTrue([defaultStyle isKindOfClass:[PropStyle class]], @"Do not PropStyle Class");
        
        
        XCTAssertTrue([propSetting.selectPropSize isKindOfClass:[PropSize class]], @"Do not PropSize Class");
        XCTAssertTrue([propSetting.selectPropUturn isKindOfClass:[PropUturn class]], @"Do not PropUturn Class");
        
        
        // Size
        NSArray *sizes = propSetting.sizes;
        XCTAssertFalse(sizes.count == 0, @"Sizes is Empty");
        
        // Size
        for (PropSize *size in sizes) {
            XCTAssertFalse(size.sizeName.length == 0, @"Size is Empty");
        }
        
        for (id object in sizes) {
            XCTAssertTrue([object isKindOfClass:[PropSize class]], @"Do not PropSize Class");
        }
        
        
        // Uturn
        NSArray *uturns = propSetting.uturns;
        XCTAssertFalse(uturns.count == 0, @"Utuns is Empty");
        
        // Size
        for (PropUturn *uturn in uturns) {
            XCTAssertFalse(uturn.uturn.length == 0, @"Uturn is Empty");
        }
        
        for (id object in uturns) {
            XCTAssertTrue([object isKindOfClass:[PropUturn class]], @"Do not PropUturn Class");
        }


        // Covers
        NSArray *covers = propSetting.covers;
        XCTAssertFalse(covers.count == 0, @"Utuns is Empty");
        
        // Cover
        for (PropCover *cover in covers) {
            XCTAssertFalse(cover.cover.length == 0, @"Cover is Empty");
        }
        
        for (id object in covers) {
            XCTAssertTrue([object isKindOfClass:[PropCover class]], @"Do not PropCover Class");
        }
    }
}



- (void)testPropsSettingChangePropsAlbum
{
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:@"Альбомы"];
    
    for (StoreItem *storeItem in storeItems) {
        PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
        
        PropType *propSetting = [printData.storeItem propType];
        PropCover *defaultCover = [propSetting selectPropCover];
        PropStyle *defaultStyle = [propSetting selectPropStyle];
        
        PropStyle *changePropStyle;
        for (PropStyle *propStyle in propSetting.styles) {
            if (![propStyle.styleName isEqualToString:defaultStyle.styleName]) {
                changePropStyle = propStyle;
            }
        }
        
        PropCover *changePropCover;
        for (PropCover *propCover in propSetting.covers) {
            if (![propCover.cover isEqualToString:defaultCover.cover]) {
                changePropCover = propCover;
            }
        }
        
        
        [printData changeProp:changePropCover];
        [printData changeProp:changePropStyle];
        
        
        //defaultCover = [propSetting selectPropCover];
        //defaultStyle = [propSetting selectPropStyle];
        
        
        XCTAssertNotEqual(defaultCover, changePropCover, @"Not Changed");
        XCTAssertNotEqual(defaultStyle, changePropStyle, @"Not Changed");
    }
}


#pragma mark - Mug
- (void)testPropsSettingMug
{
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:@"Сувениры и подарки"];
    
    for (StoreItem *storeItem in storeItems) {
        if ([storeItem.propType.name isEqualToString:@"heart"]) {
            PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
            
            PropType *propSetting = [printData.storeItem propType];
            PropColor *defaultColor = [propSetting selectPropColor];
            
            for (PropColor *propColor in propSetting.colors) {
                if (![propColor.color isEqualToString:defaultColor.color]) {
                    [printData changeProp:propColor];
                }
            }
            
            XCTAssertNotEqual(defaultColor, printData.storeItem.propType.selectPropColor, @"Not Changed");
        }
    }
}



- (void)testPropsSettingTShirt
{
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:@"Сувениры и подарки"];
    
    for (StoreItem *storeItem in storeItems) {
        if ([storeItem.purchaseID isEqualToString:@"2"]) {
            PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
            
            PropType *propSetting = [printData.storeItem propType];
            PropSize *defaultSize = [propSetting selectPropSize];
            
            PropSize *changePropSize;
            for (PropSize *propSize in propSetting.sizes) {
                if (![propSize.sizeName isEqualToString:defaultSize.sizeName]) {
                    changePropSize = propSize;
                }
            }
            
            
            [printData changeProp:changePropSize];
            
            
            //defaultSize = [propSetting selectPropSize];
            
            
            XCTAssertNotEqual(defaultSize, changePropSize, @"Not Changed");
        }
    }
}



- (void)testPropsSettingMagnit
{
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:@"Чехлы и магниты"];
    
    for (StoreItem *storeItem in storeItems) {
        if ([storeItem.purchaseID isEqualToString:@"14"]) {
            PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
            
            PropType *propSetting = [printData.storeItem propType];
            PropSize *defaultSize = [propSetting selectPropSize];
            
            PropSize *changePropSize;
            for (PropSize *propSize in propSetting.sizes) {
                if (![propSize.sizeName isEqualToString:defaultSize.sizeName]) {
                    changePropSize = propSize;
                }
            }
            
            if (!changePropSize) {
                changePropSize = [propSetting.sizes firstObject];
            }
            
            
            [printData changeProp:changePropSize];
            
            
            defaultSize = [propSetting selectPropSize];
            
            
            XCTAssertEqual(defaultSize, changePropSize, @"Not Changed");
        }
    }
}

@end
