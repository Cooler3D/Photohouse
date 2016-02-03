//
//  PrintDataTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/20/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ResponseGetItems.h"
#import "ResponseAlbumV2.h"
#import "CoreDataStore.h"

#import "AlbumTemplate.h"
#import "JsonTemplateLayout.h"
#import "LayerPage.h"
#import "PlaceHolder.h"

#import "Template.h"
#import "Layout.h"
#import "Layer.h"
#import "Image.h"
//#import "Position.h"

#import "StoreItem.h"
#import "PropType.h"
#import "PropCover.h"
#import "PropSize.h"
#import "PropUturn.h"
#import "PropColor.h"
#import "PropStyle.h"

#import "PrintData.h"

#import "BundleDefault.h"


@interface CoreDataStoreTest : XCTestCase

@end

@implementation CoreDataStoreTest
{
    ResponseGetItems *response;
    ResponseAlbumV2 *responseAlbumV2;
    CoreDataStore *coreStore;
    PrintData *printData;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    BundleDefault *bundle = [[BundleDefault alloc] init];
    NSData *dataItems = [bundle defaultDataWithBundleName:BundleDefaultTypeAllItems];
    responseAlbumV2 = [[ResponseAlbumV2 alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    response = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbumV2.oldTemplates];
    

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


//- (void) testSaveAllItemsAndTemplates
//{
//    BundleDefault *bundle = [[BundleDefault alloc] init];
//    NSData *dataItems = [bundle defaultDataWithBundleName:BundleDefaultTypeAllItems];
//    ResponseAlbum *responseAlbum = [[ResponseAlbum alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTests]];
//    response = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbum.templates];
//    
//    coreStore = [[CoreDataStore alloc] init];
//    
//}

#pragma mark - Store
- (void) testGetCategoryStorePhoto
{
    StoreType store = StoreTypePhotoPrint;
    NSString *name = [coreStore getCategoryTitleWithCategoryID:store];
    XCTAssertFalse(name.length == 0, @"Empty");
    
    NSArray *array = [coreStore getStoreItemsWithCategoryName:name];
    XCTAssertFalse(array.count == 0, @"Empty");
}



- (void) testGetItemsWithCategory
{
    StoreType store = StoreTypeCoverCase;
    NSString *name = [coreStore getCategoryTitleWithCategoryID:store];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:name];
    XCTAssertFalse(storeItems.count == 0, @"Store is Empty");
}

- (void) testCreatePrintDataWithAlbums {
    
    NSString *const categoryName = @"Альбомы";
    NSArray *storeItems = [coreStore getAlbumStoreItemsWithCategoryName:categoryName andAlbumPurshaseID:PhotoHousePrintAlbum];
    XCTAssertFalse(storeItems.count == 0, @"Store is Empty");
    
    for (StoreItem *store in storeItems) {
        printData = [[PrintData alloc] initWithStoreItem:store andUniqueNum:0];
        XCTAssertTrue(printData.purchaseID > 0, @"PurchaseId == %li",(long)printData.purchaseID);
        XCTAssertFalse(printData.namePurchase.length == 0, @"namePurchase is Empty");
        XCTAssertFalse([printData count] == 0, @"Count == %lu", (unsigned long)printData.count);
        XCTAssertFalse([printData price] == 0, @"Price == %li", (long)printData.price);
        XCTAssertNotNil([printData iconShopCart], @"Icon image nil: ID: %li", (long)printData.purchaseID);
        XCTAssertNil([printData gridImage], @"Grid image nil: ID: %li", (long)printData.purchaseID);
        
        
        
        
        // Props album
        NSArray *keys = [[printData props] allKeys];
        XCTAssertFalse([keys count] == 0, @"Prop Keys == %lu", (unsigned long)printData.count);
        for (NSString *key in keys) {
            XCTAssertFalse(key.length == 0, @"Prop Key is Empty");
            XCTAssertFalse([[[printData props] objectForKey:key] length] == 0, @"Value Key is Empty");
        }
        
        
        for (PropType *type in store.types) {
            XCTAssertFalse(type.sizes.count == 0, @"Sizes is Empty");
            XCTAssertFalse(type.uturns.count == 0, @"Uturn is Empty");
            XCTAssertFalse(type.covers.count == 0, @"Covers is Empty");
            XCTAssertFalse(type.styles.count == 0, @"Styles is Empty");
            
            // Size
            NSArray *sizes = type.sizes;
            for (id object in sizes) {
                XCTAssertTrue([object isKindOfClass:[PropSize class]], @"Do not PropSize Class");
            }
            
            for (PropSize *size in sizes) {
                XCTAssertFalse(size.sizeName.length == 0, @"Size is Empty");
            }
            
            // Uturn
            NSArray *uturns = type.uturns;
            for (id object in uturns) {
                XCTAssertTrue([object isKindOfClass:[PropUturn class]], @"Do not PropUturn Class");
            }
            
            for (PropUturn *uturn in uturns) {
                XCTAssertFalse(uturn.uturn.length == 0, @"Uturn is Empty");
            }
            
            
            
            // Cover
            NSArray *covers = type.covers;
            for (id object in covers) {
                XCTAssertTrue([object isKindOfClass:[PropCover class]], @"Do not PropCover Class");
            }
            
            for (PropCover *cover in covers) {
                XCTAssertFalse(cover.cover.length == 0, @"Cover is Empty");
            }
            
            
            // Style
            NSArray *styles = type.styles;
            for (id propStyle in type.styles) {
                XCTAssertTrue([propStyle isKindOfClass:[PropStyle class]], @"Do not PropStyle Class");
            }
            for (PropStyle *style in styles) {
                XCTAssertFalse(style.styleName.length == 0, @"Style is Empty");
                XCTAssertTrue(style.maxCount > 0, @"Max is Empty");
                XCTAssertTrue(style.minCount > 0, @"Min is Empty");
            }
            
            
            
            // Selected
            XCTAssertTrue([type.selectPropCover isKindOfClass:[PropCover class]], @"Do not PropCover Class");
            XCTAssertTrue([type.selectPropUturn isKindOfClass:[PropUturn class]], @"Do not PropUturn Class");
            XCTAssertTrue([type.selectPropSize isKindOfClass:[PropSize class]], @"Do not PropSize Class");
            XCTAssertTrue([type.selectPropStyle isKindOfClass:[PropStyle class]], @"Do not PropStyle Class");
        }
    }
}


- (void) testCreatePrintDataWithPhotoPrints {
    NSString *const categoryName = @"Фотопечать";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    
    for (StoreItem *store in storeItems) {
        printData = [[PrintData alloc] initWithStoreItem:store andUniqueNum:0];
        XCTAssertTrue(printData.purchaseID > 0, @"PurchaseId == %li",(long)printData.purchaseID);
        XCTAssertFalse([printData count] == 0, @"Count == %lu", (unsigned long)printData.count);
        XCTAssertFalse([printData price] == 0, @"Price == %li", (long)printData.price);
        XCTAssertNotNil([printData iconShopCart], @"Icon image nil: ID: %li", (long)printData.purchaseID);
        XCTAssertNotNil(store.iconStoreImage, @"Icon store nil: ID: %li", (long)printData.purchaseID);
        XCTAssertNotNil([printData gridImage], @"Grid image nil: ID: %li", (long)printData.purchaseID);
        //XCTAssertNotNil([printData showCaseImage], @"ShowCaseImage == nil");
    }
}


- (void) testCreatePrintDataWithSouvenirs {
    NSString *const categoryName = @"Сувениры и подарки";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    
    for (StoreItem *store in storeItems) {
        printData = [[PrintData alloc] initWithStoreItem:store andUniqueNum:0];
        XCTAssertTrue(printData.purchaseID > 0, @"PurchaseId == %li",(long)printData.purchaseID);
        XCTAssertFalse([printData count] == 0, @"Count == %lu", (unsigned long)printData.count);
        XCTAssertFalse([printData price] == 0, @"Price == %li", (long)printData.price);
        XCTAssertNotNil([printData iconShopCart], @"Icon image nil: ID: %li", (long)printData.purchaseID);
        XCTAssertNotNil([printData gridImage], @"Grid image nil: ID: %li", (long)printData.purchaseID);
        XCTAssertNotNil([printData showCaseImage], @"ShowCaseImage == nil");
        
        
        // Props album
        if ([store.purchaseID isEqualToString:@"1"] && [store.propType.name isEqualToString:@"heart"]) {
            
            //
            NSArray *keys = [[printData props] allKeys];
            XCTAssertFalse([keys count] == 0, @"Prop Keys == %lu", (unsigned long)printData.count);
            
            for (NSString *key in keys) {
                XCTAssertFalse(key.length == 0, @"Prop Key is Empty");
                XCTAssertFalse([[[printData props] objectForKey:key] length] == 0, @"Value Key is Empty");
            }
        }
        
        
        
        // Props album
        if ([store.purchaseID isEqualToString:@"2"]) {
            
            //
            NSArray *keys = [[printData props] allKeys];
            XCTAssertFalse([keys count] == 0, @"Prop Keys == %lu", (unsigned long)printData.count);
            
            for (NSString *key in keys) {
                XCTAssertFalse(key.length == 0, @"Prop Key is Empty");
                XCTAssertFalse([[[printData props] objectForKey:key] length] == 0, @"Value Key is Empty");
            }
        }
    }
}


- (void) testCreatePrintDataWithCaseAndMagnits {
    NSString *const categoryName = @"Чехлы и магниты";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    
    for (StoreItem *store in storeItems) {
        printData = [[PrintData alloc] initWithStoreItem:store andUniqueNum:0];
        XCTAssertTrue(printData.purchaseID > 0, @"PurchaseId == %li",(long)printData.purchaseID);
        XCTAssertFalse([printData count] == 0, @"Count == %lu", (unsigned long)printData.count);
        XCTAssertFalse([printData price] == 0, @"Price == %li", (long)printData.price);
        XCTAssertNotNil([printData iconShopCart], @"Icon image nil: ID: %li", (long)printData.purchaseID);
        XCTAssertNotNil([printData gridImage], @"Grid image nil: ID: %li", (long)printData.purchaseID);
        XCTAssertNotNil([printData showCaseImage], @"ShowCaseImage == nil");
        
        // Props album
        if ([store.purchaseID isEqualToString:@"13"]) {
            //
            NSArray *keys = [[printData props] allKeys];
            XCTAssertFalse([keys count] == 0, @"Prop Keys == %lu", (unsigned long)printData.count);
            
            
            for (NSString *key in keys) {
                XCTAssertFalse(key.length == 0, @"Prop Key is Empty");
                XCTAssertFalse([[[printData props] objectForKey:key] length] == 0, @"Value Key is Empty");
            }
            
            
            for (PropType *type in store.types) {
                NSArray *sizes = type.sizes;
                
                for (id object in sizes) {
                    XCTAssertTrue([object isKindOfClass:[PropSize class]], @"Do not PropSize Class");
                }
                
                for (PropSize *size in sizes) {
                    XCTAssertFalse(size.sizeName.length == 0, @"Size is Empty");
                }
                
                XCTAssertTrue([type.selectPropSize isKindOfClass:[PropSize class]], @"Do not PropSize Class");
            }
        }
    }
}


//- (void) testTimeServer
//{
//    NSDate *responseTime = response.dateCmdResponse;
//    NSDate *savedTime = [coreStore time];
//    
//    XCTAssertTrue([responseTime isEqualToDate:savedTime]);
//}


#pragma mark - Templates
- (void) testGetAllTemplatesFromStore
{
    //    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"template.txt"];
    //
    //    NSData *data = [bundle defaultDataWithBundleName:BundleDefaultTypeAlbum];
    //    BOOL fileExists = [data writeToFile:filePath atomically:YES];
    //
    //    NSData *readData = [NSData dataWithContentsOfFile:filePath];
    //    NSDictionary *parse = [NSJSONSerialization JSONObjectWithData:readData options:0 error:nil];
    
    NSArray *templates = [coreStore getAllTemplatesWithPurchaseID:@"13" andPropTypeName:TypeNameConstructor];
    XCTAssertFalse(templates.count == 0, @"Styles Empty");
    for (Template *template in templates) {
        XCTAssertNotNil(template, @"Template == nil");
        XCTAssertFalse(template.name.length == 0, @"Name is Empty: %@", template.name);
        XCTAssertFalse(template.fontName.length == 0, @"Font is Empty: %@", template.fontName);
        XCTAssertFalse(template.id_template.length == 0, @"ID is Empty: %@", template.id_template);
        XCTAssertFalse(template.layouts.count == 0, @"Layouts Empty");
        XCTAssertFalse(template.size.length == 0, @"Size Empty");
        
        for (Layout *layout in template.layouts) {
            XCTAssertFalse(layout.id_layout.length == 0);
            XCTAssertFalse(layout.template_psd.length == 0);
            XCTAssertFalse(layout.layoutType.length == 0);
            XCTAssertTrue(layout.combinedLayer);
            // NoscaleCombined
            XCTAssertTrue(CGRectGetWidth(layout.noscaleCombinedLayer) > 0);
            XCTAssertTrue(CGRectGetHeight(layout.noscaleCombinedLayer) > 0);
            
            // PlaceHolder
            PlaceHolder *pHolder = layout.combinedLayer;
            XCTAssertTrue(pHolder.psdPath.length > 0);
            XCTAssertTrue(pHolder.layerNum.length > 0);
            XCTAssertTrue(pHolder.pngPath.length > 0);
            XCTAssertTrue(CGRectGetWidth(pHolder.rect) > 0);
            XCTAssertTrue(CGRectGetHeight(pHolder.rect) > 0);
            
            // *******
            // Back
            Layer *backLayer = layout.backLayer;
            XCTAssertNotNil(backLayer.image);
            //XCTAssertFalse(backLayer.images.count == 0, @"Images Empty");
            
            Image *backImage = backLayer.image;
            XCTAssertFalse(backImage.pixelsMin.length == 0);
            XCTAssertFalse(backImage.pixelsLimit.length == 0);
            XCTAssertFalse(backImage.z.length == 0);
            XCTAssertFalse(backImage.permanent.length == 0);
            XCTAssertFalse(backImage.url_image.length == 0);
//            XCTAssertNotNil(backImage.image);
            
            
            // Maket
            for (Image *image in backLayer.images) {
                XCTAssertFalse(image.pixelsMin.length == 0);
                XCTAssertFalse(image.pixelsLimit.length == 0);
                XCTAssertFalse(image.z.length == 0);
                XCTAssertFalse(image.permanent.length == 0);
//                XCTAssertFalse(image.url_image.length == 0);
                
                CGRect rect = image.rect;
                XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
                XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
                
                // Crop
//                CGRect crop = image.crop;
//                XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
//                XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
            }
            // *******
            
            
            
            // *******
            // Front
            Layer *frontLayer = layout.frontLayer;
            XCTAssertNotNil(frontLayer.image);
//            XCTAssertFalse(frontLayer.images.count == 0, @"Images Empty");
            
            Image *frontImage = frontLayer.image;
            XCTAssertFalse(frontImage.pixelsMin.length == 0);
            XCTAssertFalse(frontImage.pixelsLimit.length == 0);
            XCTAssertFalse(frontImage.z.length == 0);
            XCTAssertFalse(frontImage.permanent.length == 0);
            XCTAssertFalse(frontImage.url_image.length == 0);
//            XCTAssertNotNil(frontImage.image);
            
            
            // Maket
            for (Image *image in frontLayer.images) {
                XCTAssertFalse(image.pixelsMin.length == 0);
                XCTAssertFalse(image.pixelsLimit.length == 0);
                XCTAssertFalse(image.z.length == 0);
                XCTAssertFalse(image.permanent.length == 0);
//                XCTAssertFalse(image.url_image.length == 0);
                
                // Rect
                CGRect rect = image.rect;
                XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
                XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
                
                // Crop
                CGRect crop = image.rect;
                XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
                XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
            }
            // *******
            
            
            
//            // *******
//            // Clear
//            Layer *clearLayer = layout.clearLayer;
//            XCTAssertNotNil(clearLayer.image);
//            
//            Image *clearImage = clearLayer.image;
//            XCTAssertFalse(clearImage.pixelsMin.length == 0);
//            XCTAssertFalse(clearImage.pixelsLimit.length == 0);
//            XCTAssertFalse(clearImage.z.length == 0);
//            XCTAssertFalse(clearImage.permanent.length == 0);
//            XCTAssertFalse(clearImage.url_image.length == 0);
//            
//            
//            // Maket
//            for (Image *image in clearLayer.images) {
//                XCTAssertFalse(image.pixelsMin.length == 0);
//                XCTAssertFalse(image.pixelsLimit.length == 0);
//                XCTAssertFalse(image.z.length == 0);
//                XCTAssertFalse(image.permanent.length == 0);
//                XCTAssertFalse(image.url_image.length == 0);
//                
//                // Rect
//                CGRect rect = image.rect;
//                XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
//                XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
//                
//                // Crop
//                CGRect crop = image.rect;
//                XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
//                XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
//            }
//            // *******
        }
    }
}


- (void) testGetPropsStyleCWithConstructor
{
//    PropSize *size = [[PropSize alloc] initSize:@"20x20" andPrice:0];
    NSArray *styles = [coreStore getStylesWithPurchaseID:@"13" andTypePropName:TypeNameConstructor];
    XCTAssertFalse(styles.count == 0, @"Styles Empty");
    
    for (id propStyle in styles) {
        XCTAssertTrue([propStyle isKindOfClass:[PropStyle class]], @"Do not PropStyle Class");
    }
    for (PropStyle *style in styles) {
        XCTAssertFalse(style.styleName.length == 0, @"Style is Empty");
        XCTAssertTrue(style.maxCount > 0, @"Max is Empty");
        XCTAssertTrue(style.minCount > 0, @"Min is Empty");
    }
}


- (void) testGetCoverLayoutAlbum
{
//    PropSize *size = [[PropSize alloc] initSize:@"20x20" andPrice:0];
//    PropStyle *style = [[PropStyle alloc] initWithStyleName:@"undefined" andMaxCount:20 andMinCount:30 andImage:nil];
    NSArray *items = [coreStore getStoreItemsWithCategoryName:@"Альбомы"];
    StoreItem *storeItem;
    for (StoreItem *item in items) {
        if ([item.propType.name isEqualToString:TypeNameConstructor]) {
            storeItem = item;
        }
    }
    printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    Layout *coverlayout = printData.storeItem.propType.selectTemplate.layoutCover;
    XCTAssertFalse(coverlayout.id_layout.length == 0);
    XCTAssertFalse(coverlayout.template_psd.length == 0);
    XCTAssertFalse(coverlayout.layoutType.length == 0);
    
    // *******
    // Back
    Layer *backLayer = coverlayout.backLayer;
    XCTAssertNotNil(backLayer.image);
    //XCTAssertFalse(backLayer.images.count == 0, @"Images Empty");
    
    Image *backImage = backLayer.image;
    XCTAssertFalse(backImage.pixelsMin.length == 0);
    XCTAssertFalse(backImage.pixelsLimit.length == 0);
    XCTAssertFalse(backImage.z.length == 0);
    XCTAssertFalse(backImage.permanent.length == 0);
    XCTAssertFalse(backImage.url_image.length == 0);
//            XCTAssertNotNil(backImage.image);
    
    
    // Maket
    for (Image *image in backLayer.images) {
        XCTAssertFalse(image.pixelsMin.length == 0);
        XCTAssertFalse(image.pixelsLimit.length == 0);
        XCTAssertFalse(image.z.length == 0);
        XCTAssertFalse(image.permanent.length == 0);
        XCTAssertFalse(image.url_image.length == 0);
        
        // Rect
        CGRect rect = image.rect;
        XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
        XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
        
        // Crop
        CGRect crop = image.rect;
        XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
        XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
    }
    // *******
    
    
    
    // *******
    // Front
    Layer *frontLayer = coverlayout.frontLayer;
    XCTAssertNotNil(frontLayer.image);
//    XCTAssertFalse(frontLayer.images.count == 0, @"Images Empty");
    
    Image *frontImage = frontLayer.image;
    XCTAssertFalse(frontImage.pixelsMin.length == 0);
    XCTAssertFalse(frontImage.pixelsLimit.length == 0);
    XCTAssertFalse(frontImage.z.length == 0);
    XCTAssertFalse(frontImage.permanent.length == 0);
    XCTAssertFalse(frontImage.url_image.length == 0);
//            XCTAssertNotNil(frontImage.image);
    
    
    // Maket
    for (Image *image in frontLayer.images) {
        XCTAssertFalse(image.pixelsMin.length == 0);
        XCTAssertFalse(image.pixelsLimit.length == 0);
        XCTAssertFalse(image.z.length == 0);
        XCTAssertFalse(image.permanent.length == 0);
        XCTAssertFalse(image.url_image.length == 0);
        
        // Rect
        CGRect rect = image.rect;
        XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
        XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
        
        // Crop
        CGRect crop = image.rect;
        XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
        XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
    }
    // *******
    
    
    
//    // *******
//    // Clear
//    Layer *clearLayer = coverlayout.clearLayer;
//    XCTAssertNotNil(clearLayer.image);
//    
//    Image *clearImage = clearLayer.image;
//    XCTAssertFalse(clearImage.pixelsMin.length == 0);
//    XCTAssertFalse(clearImage.pixelsLimit.length == 0);
//    XCTAssertFalse(clearImage.z.length == 0);
//    XCTAssertFalse(clearImage.permanent.length == 0);
//    XCTAssertFalse(clearImage.url_image.length == 0);
//    
//    
//    // Maket
//    for (Image *image in clearLayer.images) {
//        XCTAssertFalse(image.pixelsMin.length == 0);
//        XCTAssertFalse(image.pixelsLimit.length == 0);
//        XCTAssertFalse(image.z.length == 0);
//        XCTAssertFalse(image.permanent.length == 0);
//        XCTAssertFalse(image.url_image.length == 0);
//        
//        // Rect
//        CGRect rect = image.rect;
//        XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
//        XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
//        
//        // Crop
//        CGRect crop = image.rect;
//        XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
//        XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
//    }
//    // *******
}




- (void) testGetPagesLayoutAlbum
{
//    PropSize *size = [[PropSize alloc] initSize:@"20x20" andPrice:0];
//    PropStyle *style = [[PropStyle alloc] initWithStyleName:@"undefined" andMaxCount:20 andMinCount:30 andImage:nil];
    
    NSArray *items = [coreStore getStoreItemsWithCategoryName:@"Альбомы"];
    StoreItem *storeItem;
    for (StoreItem *item in items) {
        if ([item.propType.name isEqualToString:TypeNameConstructor]) {
            storeItem = item;
        }
    }
    printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    
    
    NSArray *pages = printData.storeItem.propType.selectTemplate.layoutPages;
    XCTAssertFalse(pages.count == 0, @"Pages Empty");
    for (Layout *layout in pages) {
        XCTAssertFalse(layout.id_layout.length == 0);
        XCTAssertFalse(layout.template_psd.length == 0);
        XCTAssertFalse(layout.layoutType.length == 0);
        
        // *******
        // Back
        Layer *backLayer = layout.backLayer;
        XCTAssertNotNil(backLayer.image);
        //XCTAssertFalse(backLayer.images.count == 0, @"Images Empty");
        
        Image *backImage = backLayer.image;
        XCTAssertFalse(backImage.pixelsMin.length == 0);
        XCTAssertFalse(backImage.pixelsLimit.length == 0);
        XCTAssertFalse(backImage.z.length == 0);
        XCTAssertFalse(backImage.permanent.length == 0);
        XCTAssertFalse(backImage.url_image.length == 0);
//            XCTAssertNotNil(backImage.image);
        
        
        // Maket
        for (Image *image in backLayer.images) {
            XCTAssertFalse(image.pixelsMin.length == 0);
            XCTAssertFalse(image.pixelsLimit.length == 0);
            XCTAssertFalse(image.z.length == 0);
            XCTAssertFalse(image.permanent.length == 0);
            XCTAssertFalse(image.url_image.length == 0);
            
            // Rect
            CGRect rect = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
            
            // Crop
            CGRect crop = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
        }
        // *******
        
        
        
        // *******
        // Front
        Layer *frontLayer = layout.frontLayer;
        XCTAssertNotNil(frontLayer.image);
//        XCTAssertFalse(frontLayer.images.count == 0, @"Images Empty");
        
        Image *frontImage = frontLayer.image;
        XCTAssertFalse(frontImage.pixelsMin.length == 0);
        XCTAssertFalse(frontImage.pixelsLimit.length == 0);
        XCTAssertFalse(frontImage.z.length == 0);
        XCTAssertFalse(frontImage.permanent.length == 0);
        XCTAssertFalse(frontImage.url_image.length == 0);
//            XCTAssertNotNil(frontImage.image);
        
        
        // Maket
        for (Image *image in frontLayer.images) {
            XCTAssertFalse(image.pixelsMin.length == 0);
            XCTAssertFalse(image.pixelsLimit.length == 0);
            XCTAssertFalse(image.z.length == 0);
            XCTAssertFalse(image.permanent.length == 0);
            XCTAssertFalse(image.url_image.length == 0);
            
            // Rect
            CGRect rect = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
            
            // Crop
            CGRect crop = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
        }
        // *******
        
        
        
//        // *******
//        // Clear
//        Layer *clearLayer = layout.clearLayer;
//        XCTAssertNotNil(clearLayer.image);
//        
//        Image *clearImage = clearLayer.image;
//        XCTAssertFalse(clearImage.pixelsMin.length == 0);
//        XCTAssertFalse(clearImage.pixelsLimit.length == 0);
//        XCTAssertFalse(clearImage.z.length == 0);
//        XCTAssertFalse(clearImage.permanent.length == 0);
//        XCTAssertFalse(clearImage.url_image.length == 0);
//        
//        
//        // Maket
//        for (Image *image in clearLayer.images) {
//            XCTAssertFalse(image.pixelsMin.length == 0);
//            XCTAssertFalse(image.pixelsLimit.length == 0);
//            XCTAssertFalse(image.z.length == 0);
//            XCTAssertFalse(image.permanent.length == 0);
//            XCTAssertFalse(image.url_image.length == 0);
//            
//            // Rect
//            CGRect rect = image.rect;
//            XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
//            XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
//            
//            // Crop
//            CGRect crop = image.rect;
//            XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
//            XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
//        }
//        // *******
    }
    
}


- (void) testGetOriginalTemplatePropSize20x15AndStyle
{
    NSString *templateSize = @"20x15";
    NSString *templateName = @"pink_checkered";
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];
    XCTAssertNotNil(originalTemplate, @"Template is Nil");
    XCTAssertFalse(originalTemplate.name.length == 0, @"Name is Empty: %@", originalTemplate.name);
    XCTAssertFalse(originalTemplate.fontName.length == 0, @"Font is Empty: %@", originalTemplate.fontName);
    XCTAssertFalse(originalTemplate.id_template.length == 0, @"ID is Empty: %@", originalTemplate.id_template);
    XCTAssertFalse(originalTemplate.layouts.count == 0, @"Layouts Empty");
    XCTAssertFalse(originalTemplate.size.length == 0, @"Size Empty");
    
    for (Layout *layout in originalTemplate.layouts) {
        XCTAssertFalse(layout.id_layout.length == 0);
        XCTAssertFalse(layout.template_psd.length == 0);
        XCTAssertFalse(layout.layoutType.length == 0);
        
        // *******
        // Back
        Layer *backLayer = layout.backLayer;
        XCTAssertNotNil(backLayer.image);
        //XCTAssertFalse(backLayer.images.count == 0, @"Images Empty");
        
        Image *backImage = backLayer.image;
        XCTAssertFalse(backImage.pixelsMin.length == 0);
        XCTAssertFalse(backImage.pixelsLimit.length == 0);
        XCTAssertFalse(backImage.z.length == 0);
        XCTAssertFalse(backImage.permanent.length == 0);
        XCTAssertFalse(backImage.url_image.length == 0);
//        XCTAssertNotNil(backImage.image);
        
        
        // Maket
        for (Image *image in backLayer.images) {
            XCTAssertFalse(image.pixelsMin.length == 0);
            XCTAssertFalse(image.pixelsLimit.length == 0);
            XCTAssertFalse(image.z.length == 0);
            XCTAssertFalse(image.permanent.length == 0);
            XCTAssertFalse(image.url_image.length == 0);
            
            // Rect
            CGRect rect = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
            
            // Crop
            CGRect crop = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
        }
        // *******
        
        
        
        // *******
        // Front
        Layer *frontLayer = layout.frontLayer;
        XCTAssertNotNil(frontLayer.image);
//        XCTAssertFalse(frontLayer.images.count == 0, @"Images Empty");
        
        Image *frontImage = frontLayer.image;
        XCTAssertFalse(frontImage.pixelsMin.length == 0);
        XCTAssertFalse(frontImage.pixelsLimit.length == 0);
        XCTAssertFalse(frontImage.z.length == 0);
        XCTAssertFalse(frontImage.permanent.length == 0);
        XCTAssertFalse(frontImage.url_image.length == 0);
//        XCTAssertNotNil(frontImage.image);
        
        
        // Maket
        for (Image *image in frontLayer.images) {
            XCTAssertFalse(image.pixelsMin.length == 0);
            XCTAssertFalse(image.pixelsLimit.length == 0);
            XCTAssertFalse(image.z.length == 0);
            XCTAssertFalse(image.permanent.length == 0);
            XCTAssertFalse(image.url_image.length == 0);
            
            // Rect
            CGRect rect = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
            
            // Crop
//            CGRect crop = image.rect;
//            XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
//            XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
        }
        // *******
        
        
        
//        // *******
//        // Clear
//        Layer *clearLayer = layout.clearLayer;
//        XCTAssertNotNil(clearLayer.image);
//        
//        Image *clearImage = clearLayer.image;
//        XCTAssertFalse(clearImage.pixelsMin.length == 0);
//        XCTAssertFalse(clearImage.pixelsLimit.length == 0);
//        XCTAssertFalse(clearImage.z.length == 0);
//        XCTAssertFalse(clearImage.permanent.length == 0);
//        XCTAssertFalse(clearImage.url_image.length == 0);
//        
//        
//        // Maket
//        for (Image *image in clearLayer.images) {
//            XCTAssertFalse(image.pixelsMin.length == 0);
//            XCTAssertFalse(image.pixelsLimit.length == 0);
//            XCTAssertFalse(image.z.length == 0);
//            XCTAssertFalse(image.permanent.length == 0);
//            XCTAssertFalse(image.url_image.length == 0);
//            
//            // Rect
//            CGRect rect = image.rect;
//            XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
//            XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
//            
//            // Crop
//            CGRect crop = image.rect;
//            XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
//            XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
//        }
//        // *******
    }
    
}



- (void) testGetOriginalTemplatePropSize20x20AndStyleTurquoiseTravel
{
    NSString *templateSize = @"20x20";
    NSString *templateName = @"turquoise_travel";
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];
    XCTAssertNotNil(originalTemplate, @"Template is Nil");
    XCTAssertFalse(originalTemplate.name.length == 0, @"Name is Empty: %@", originalTemplate.name);
    XCTAssertFalse(originalTemplate.fontName.length == 0, @"Font is Empty: %@", originalTemplate.fontName);
    XCTAssertFalse(originalTemplate.id_template.length == 0, @"ID is Empty: %@", originalTemplate.id_template);
    XCTAssertFalse(originalTemplate.layouts.count == 0, @"Layouts Empty");
    XCTAssertFalse(originalTemplate.size.length == 0, @"Size Empty");
    
    for (Layout *layout in originalTemplate.layouts) {
        XCTAssertFalse(layout.id_layout.length == 0);
        XCTAssertFalse(layout.template_psd.length == 0);
        XCTAssertFalse(layout.layoutType.length == 0);
        
        // *******
        // Back
        Layer *backLayer = layout.backLayer;
        XCTAssertNotNil(backLayer.image);
        //XCTAssertFalse(backLayer.images.count == 0, @"Images Empty");
        
        Image *backImage = backLayer.image;
        XCTAssertFalse(backImage.pixelsMin.length == 0);
        XCTAssertFalse(backImage.pixelsLimit.length == 0);
        XCTAssertFalse(backImage.z.length == 0);
        XCTAssertFalse(backImage.permanent.length == 0);
        XCTAssertFalse(backImage.url_image.length == 0);
//        XCTAssertNotNil(backImage.image);
        
        NSInteger loc = [backImage.url_image rangeOfString:templateSize].location;
        XCTAssertTrue(loc > 1, @"layour: %@;", layout.id_layout);
        
        // Maket
        for (Image *image in backLayer.images) {
            XCTAssertFalse(image.pixelsMin.length == 0);
            XCTAssertFalse(image.pixelsLimit.length == 0);
            XCTAssertFalse(image.z.length == 0);
            XCTAssertFalse(image.permanent.length == 0);
            XCTAssertFalse(image.url_image.length == 0);
            
            // Rect
            CGRect rect = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
            
            if ([layout.layoutType isEqualToString:LayoutPage]) {
                XCTAssertTrue(CGRectGetWidth(layout.combinedLayer.rect)+1 > CGRectGetMinX(rect), @"X:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                XCTAssertTrue(CGRectGetWidth(layout.combinedLayer.rect)+1 > CGRectGetWidth(rect), @"W:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                XCTAssertTrue(CGRectGetHeight(layout.combinedLayer.rect)+1 > CGRectGetMinY(rect), @"Y:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                XCTAssertTrue(CGRectGetHeight(layout.combinedLayer.rect)+1 > CGRectGetHeight(rect), @"H:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                
            }
            
            // Crop
//            CGRect crop = image.rect;
//            XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
//            XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
        }
        // *******
        
        
        
        // *******
        // Front
        Layer *frontLayer = layout.frontLayer;
        XCTAssertNotNil(frontLayer.image);
//        XCTAssertFalse(frontLayer.images.count == 0, @"Images Empty");
        
        Image *frontImage = frontLayer.image;
        XCTAssertFalse(frontImage.pixelsMin.length == 0);
        XCTAssertFalse(frontImage.pixelsLimit.length == 0);
        XCTAssertFalse(frontImage.z.length == 0);
        XCTAssertFalse(frontImage.permanent.length == 0);
        XCTAssertFalse(frontImage.url_image.length == 0);
//        XCTAssertNotNil(frontImage.image);
        
        loc = [frontImage.url_image rangeOfString:templateSize].location;
        XCTAssertTrue(loc > 1, @"layour: %@;", layout.id_layout);
        
        // Maket
        for (Image *image in frontLayer.images) {
            XCTAssertFalse(image.pixelsMin.length == 0);
            XCTAssertFalse(image.pixelsLimit.length == 0);
            XCTAssertFalse(image.z.length == 0);
            XCTAssertFalse(image.permanent.length == 0);
            XCTAssertFalse(image.url_image.length == 0);
            
            // Rect
            CGRect rect = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
            
            if ([layout.layoutType isEqualToString:LayoutPage]) {
                XCTAssertTrue(CGRectGetWidth(layout.combinedLayer.rect)+1 > CGRectGetMinX(rect), @"X:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                XCTAssertTrue(CGRectGetWidth(layout.combinedLayer.rect)+1 > CGRectGetWidth(rect), @"W:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                XCTAssertTrue(CGRectGetHeight(layout.combinedLayer.rect)+1 > CGRectGetMinY(rect), @"Y:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                XCTAssertTrue(CGRectGetHeight(layout.combinedLayer.rect)+1 > CGRectGetHeight(rect), @"H:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                
            }
            
            // Crop
            CGRect crop = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
        }
        // *******
    }
    
}


- (void) testGetOriginalTemplatePropSize20x20AndStyleTurquoiseLined
{
    NSString *templateSize = @"20x20";
    NSString *templateName = @"turquoise_lined";
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];
    XCTAssertNotNil(originalTemplate, @"Template is Nil");
    XCTAssertFalse(originalTemplate.name.length == 0, @"Name is Empty: %@", originalTemplate.name);
    XCTAssertFalse(originalTemplate.fontName.length == 0, @"Font is Empty: %@", originalTemplate.fontName);
    XCTAssertFalse(originalTemplate.id_template.length == 0, @"ID is Empty: %@", originalTemplate.id_template);
    XCTAssertFalse(originalTemplate.layouts.count == 0, @"Layouts Empty");
    XCTAssertFalse(originalTemplate.size.length == 0, @"Size Empty");
    
    for (Layout *layout in originalTemplate.layouts) {
        XCTAssertFalse(layout.id_layout.length == 0);
        XCTAssertFalse(layout.template_psd.length == 0);
        XCTAssertFalse(layout.layoutType.length == 0);
        
        // *******
        // Back
        Layer *backLayer = layout.backLayer;
        XCTAssertNotNil(backLayer.image);
        //XCTAssertFalse(backLayer.images.count == 0, @"Images Empty");
        
        Image *backImage = backLayer.image;
        XCTAssertFalse(backImage.pixelsMin.length == 0);
        XCTAssertFalse(backImage.pixelsLimit.length == 0);
        XCTAssertFalse(backImage.z.length == 0);
        XCTAssertFalse(backImage.permanent.length == 0);
        XCTAssertFalse(backImage.url_image.length == 0);
        //        XCTAssertNotNil(backImage.image);
        
        
        // Maket
        for (Image *image in backLayer.images) {
            XCTAssertFalse(image.pixelsMin.length == 0);
            XCTAssertFalse(image.pixelsLimit.length == 0);
            XCTAssertFalse(image.z.length == 0);
            XCTAssertFalse(image.permanent.length == 0);
            XCTAssertFalse(image.url_image.length == 0);
            
            // Rect
            CGRect rect = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
            
            if ([layout.layoutType isEqualToString:LayoutPage]) {
                XCTAssertTrue(CGRectGetWidth(layout.combinedLayer.rect)+1 > CGRectGetMinX(rect), @"X:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                XCTAssertTrue(CGRectGetWidth(layout.combinedLayer.rect)+1 > CGRectGetWidth(rect), @"W:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                XCTAssertTrue(CGRectGetHeight(layout.combinedLayer.rect)+1 > CGRectGetMinY(rect), @"Y:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                XCTAssertTrue(CGRectGetHeight(layout.combinedLayer.rect)+1 > CGRectGetHeight(rect), @"H:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
            }
            
            // Crop
            //            CGRect crop = image.rect;
            //            XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
            //            XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
        }
        // *******
        
        
        
        // *******
        // Front
        Layer *frontLayer = layout.frontLayer;
        XCTAssertNotNil(frontLayer.image);
        //        XCTAssertFalse(frontLayer.images.count == 0, @"Images Empty");
        
        Image *frontImage = frontLayer.image;
        XCTAssertFalse(frontImage.pixelsMin.length == 0);
        XCTAssertFalse(frontImage.pixelsLimit.length == 0);
        XCTAssertFalse(frontImage.z.length == 0);
        XCTAssertFalse(frontImage.permanent.length == 0);
        XCTAssertFalse(frontImage.url_image.length == 0);
        //        XCTAssertNotNil(frontImage.image);
        
        
        // Maket
        for (Image *image in frontLayer.images) {
            XCTAssertFalse(image.pixelsMin.length == 0);
            XCTAssertFalse(image.pixelsLimit.length == 0);
            XCTAssertFalse(image.z.length == 0);
            XCTAssertFalse(image.permanent.length == 0);
            XCTAssertFalse(image.url_image.length == 0);
            
            // Rect
            CGRect rect = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
            
            // Crop
            CGRect crop = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
        }
        // *******
    }
    
}


- (void) testGetOriginalTemplatePropSize20x20AndStylePinkCheckered
{
    NSString *templateSize = @"20x20";
    NSString *templateName = @"pink_checkered";
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];
    XCTAssertNotNil(originalTemplate, @"Template is Nil");
    XCTAssertFalse(originalTemplate.name.length == 0, @"Name is Empty: %@", originalTemplate.name);
    XCTAssertFalse(originalTemplate.fontName.length == 0, @"Font is Empty: %@", originalTemplate.fontName);
    XCTAssertFalse(originalTemplate.id_template.length == 0, @"ID is Empty: %@", originalTemplate.id_template);
    XCTAssertFalse(originalTemplate.layouts.count == 0, @"Layouts Empty");
    XCTAssertFalse(originalTemplate.size.length == 0, @"Size Empty");
    
    for (Layout *layout in originalTemplate.layouts) {
        XCTAssertFalse(layout.id_layout.length == 0);
        XCTAssertFalse(layout.template_psd.length == 0);
        XCTAssertFalse(layout.layoutType.length == 0);
        
        // *******
        // Back
        Layer *backLayer = layout.backLayer;
        XCTAssertNotNil(backLayer.image);
        //XCTAssertFalse(backLayer.images.count == 0, @"Images Empty");
        
        Image *backImage = backLayer.image;
        XCTAssertFalse(backImage.pixelsMin.length == 0);
        XCTAssertFalse(backImage.pixelsLimit.length == 0);
        XCTAssertFalse(backImage.z.length == 0);
        XCTAssertFalse(backImage.permanent.length == 0);
        XCTAssertFalse(backImage.url_image.length == 0);
        //        XCTAssertNotNil(backImage.image);
        
        
        // Maket
        for (Image *image in backLayer.images) {
            XCTAssertFalse(image.pixelsMin.length == 0);
            XCTAssertFalse(image.pixelsLimit.length == 0);
            XCTAssertFalse(image.z.length == 0);
            XCTAssertFalse(image.permanent.length == 0);
            XCTAssertFalse(image.url_image.length == 0);
            
            // Rect
            CGRect rect = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
            
            if ([layout.layoutType isEqualToString:LayoutPage]) {
                XCTAssertTrue(CGRectGetWidth(layout.combinedLayer.rect)+1 > CGRectGetMinX(rect), @"X:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                XCTAssertTrue(CGRectGetWidth(layout.combinedLayer.rect)+1 > CGRectGetWidth(rect), @"W:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                XCTAssertTrue(CGRectGetHeight(layout.combinedLayer.rect)+1 > CGRectGetMinY(rect), @"Y:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
                XCTAssertTrue(CGRectGetHeight(layout.combinedLayer.rect)+1 > CGRectGetHeight(rect), @"H:layour: %@; Rect: %@", layout.id_layout, NSStringFromCGRect(rect));
            }
            
            // Crop
            //            CGRect crop = image.rect;
            //            XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
            //            XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
        }
        // *******
        
        
        
        // *******
        // Front
        Layer *frontLayer = layout.frontLayer;
        XCTAssertNotNil(frontLayer.image);
        //        XCTAssertFalse(frontLayer.images.count == 0, @"Images Empty");
        
        Image *frontImage = frontLayer.image;
        XCTAssertFalse(frontImage.pixelsMin.length == 0);
        XCTAssertFalse(frontImage.pixelsLimit.length == 0);
        XCTAssertFalse(frontImage.z.length == 0);
        XCTAssertFalse(frontImage.permanent.length == 0);
        XCTAssertFalse(frontImage.url_image.length == 0);
        //        XCTAssertNotNil(frontImage.image);
        
        
        // Maket
        for (Image *image in frontLayer.images) {
            XCTAssertFalse(image.pixelsMin.length == 0);
            XCTAssertFalse(image.pixelsLimit.length == 0);
            XCTAssertFalse(image.z.length == 0);
            XCTAssertFalse(image.permanent.length == 0);
            XCTAssertFalse(image.url_image.length == 0);
            
            // Rect
            CGRect rect = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
            
            // Crop
            CGRect crop = image.rect;
            XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
            XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
        }
        // *******
    }
    
}




- (void) testSychronizeImagesAfterDownloading
{
    NSString *templateSize = @"20x20";
    NSString *templateName = @"undefined";
    NSString *purchaseID = [NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum];
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:purchaseID
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];
    XCTAssertNil(originalTemplate.layoutCover.backLayer.image.image);
    XCTAssertNil(originalTemplate.layoutCover.frontLayer.image.image);
    XCTAssertNil(originalTemplate.layoutCover.clearLayer.image.image);
    
    // Set images
    NSInteger numLayout = 1;
    for (Layout *layout in originalTemplate.layouts) {
        [layout.backLayer.image updateImage:[UIImage imageNamed:[NSString stringWithFormat:@"0%li_back", (long)numLayout]]];
        [layout.frontLayer.image updateImage:[UIImage imageNamed:[NSString stringWithFormat:@"0%li_front", (long)numLayout]]];
        [layout.clearLayer.image updateImage:[UIImage imageNamed:[NSString stringWithFormat:@"0%li_clear", (long)numLayout]]];
    }
    
    // Write
    [coreStore synchorizeTemplateAfterDowloadImages:originalTemplate
                                      andPurchaseID:purchaseID
                                    andPropTypeName:TypeNameConstructor
                                       TemplateSize:templateSize
                                    andTemplateName:templateName];
    
    
    // Read
    Template *template = [coreStore getTemplateWithPurchaseID:purchaseID
                                              andPropTypeName:TypeNameConstructor
                                                 TemplateSize:templateSize
                                              andTemplateName:templateName];
    
    //
    for (Layout *layout in template.layouts) {
        XCTAssertNotNil(layout.backLayer.image.image);
        XCTAssertNotNil(layout.frontLayer.image.image);
        XCTAssertNotNil(layout.clearLayer.image.image);
    }
}




- (void) testClearAll
{
    NSArray *stories = [coreStore getStoreCategoryes];
    XCTAssertFalse(stories.count == 0, @"Empty");
    
    // clear
    [coreStore clearStory];
    
    stories = [coreStore getStoreCategoryes];
    XCTAssertTrue(stories.count == 0, @"Empty");
}
@end
