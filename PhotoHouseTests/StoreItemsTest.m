//
//  StoreItemsTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/27/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ResponseGetItems.h"
#import "CoreDataStore.h"

#import "StoreItem.h"
#import "PropType.h"
#import "PropCover.h"
#import "PropSize.h"
#import "PropUturn.h"
#import "PropColor.h"

#import "PropStyle.h"

#import "PrintData.h"

#import "BundleDefault.h"


@interface StoreItemsTest : XCTestCase

@end

@implementation StoreItemsTest
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
    response = [[ResponseGetItems alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAllItems]];
    coreStore = [[CoreDataStore alloc] init];
}

- (void)tearDown
{
    response = nil;
    coreStore = nil;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testResponseItems
{
    
    XCTAssertFalse(response.stories.count == 0, @"Stories is Empty");
    
    //
    for (StoreItem *store in response.stories) {
        XCTAssertFalse(store.categoryID == 0, @"CategoryID is Empty");
        XCTAssertFalse(store.categoryName.length == 0, @"categoryName is Empty");
        XCTAssertFalse(store.namePurchase.length == 0, @"namePurchase is Empty");
        XCTAssertFalse(store.purchaseID.length == 0, @"purchaseID is Empty");
        
        if (![store.purchaseID isEqualToString:@"20"]) {
            XCTAssertFalse(store.types.count == 0, @"Types is Empty");
        }
        
        
        // Types
        for (PropType *propType in store.types) {
            XCTAssertFalse(propType.name.length == 0, @"PropType.name is Empty");
            XCTAssertFalse(propType.price == 0, @"PropType.price == 0");
            
            // Альбомы
            if ([store.purchaseID isEqualToString:@"13"]) {
                XCTAssertFalse(propType.sizes.count == 0, @"Sizes is Empty");
                XCTAssertFalse(propType.uturns.count == 0, @"Uturn is Empty");
                XCTAssertFalse(propType.covers.count == 0, @"Covers is Empty");
                XCTAssertFalse(propType.styles.count == 0, @"Styles is Empty");
                
                // All Sizes, Uturns, Covers, Styles
                for (id propCover in propType.covers) {
                    XCTAssertTrue([propCover isKindOfClass:[PropCover class]], @"Do not PropCover Class");
                }
                
                for (id propUturn in propType.uturns) {
                    XCTAssertTrue([propUturn isKindOfClass:[PropUturn class]], @"Do not PropUturn Class");
                }
                
                for (id propSize in propType.sizes) {
                    XCTAssertTrue([propSize isKindOfClass:[PropSize class]], @"Do not PropSize Class");
                }
                
                for (id object in propType.styles) {
                    XCTAssertTrue([object isKindOfClass:[PropStyle class]], @"Do not PropStyle Class");
                }
            }
            
            // Магниты
            if ([store.purchaseID isEqualToString:@"14"]) {
                XCTAssertFalse(propType.sizes.count == 0, @"Sizes is Empty");
                
                for (id propSize in propType.sizes) {
                    XCTAssertTrue([propSize isKindOfClass:[PropSize class]], @"Do not PropSize Class");
                }
            }

            // Кружки
            if ([store.purchaseID isEqualToString:@"1"]) {
                //XCTAssertFalse(propType.sizes.count == 0, @"Sizes is Empty");
                
                
                for (id propColor in propType.colors) {
                    XCTAssertTrue([propColor isKindOfClass:[PropColor class]], @"Do not PropCover Class");
                }
            }
            
            
            // Футболки
            if ([store.purchaseID isEqualToString:@"2"]) {
                XCTAssertFalse(propType.sizes.count == 0, @"Sizes is Empty");
                
                for (id propSize in propType.sizes) {
                    XCTAssertTrue([propSize isKindOfClass:[PropSize class]], @"Do not PropSize Class");
                }
            }
            
            
            // Кружки
            if ([store.purchaseID isEqualToString:@"1"]) {
                // Только у одного есть цвет
                if ([propType.name isEqualToString:@"heart"]) {
                    XCTAssertFalse(propType.colors.count == 0, @"Colors is Empty");
                    
                    for (id propColor in propType.colors) {
                        XCTAssertTrue([propColor isKindOfClass:[PropColor class]], @"Do not PropSize Class");
                    }
                }
            }
        }
    }
}


/*- (void) testCoreDataItems {
    // перебираем все объекты магазина
    // From 1 to 4
    for (int i=1; i<4; i++) {
        NSArray *types = [coreStore getTypesWithPurchaseID:[NSString stringWithFormat:@"%i", i]];
        XCTAssertFalse(types.count == 0, @"Types empty. PurchaseID: %i", i);
        
        for (id object in types) {
            XCTAssertTrue([object isKindOfClass:[PropType class]], @"Do not PropSize Class");
        }
        
        for (PropType *type in types) {
            XCTAssertFalse(type.name.length == 0, @"PropType.Name is Empty");
            XCTAssertTrue(type.price > 0, @"Price == %li", (unsigned long)type.price);
        
            // Кружка
            if (i == 1 && [type.name isEqualToString:@"heart"]) {
                NSArray *colors = type.colors;
                
                for (id object in colors) {
                    XCTAssertTrue([object isKindOfClass:[PropColor class]], @"Do not PropColor Class");
                }
                
                for (PropColor *color in colors) {
                    XCTAssertFalse(color.color.length == 0, @"Color is Empty");
                }
                
                XCTAssertTrue([type.selectPropColor isKindOfClass:[PropColor class]], @"Do not PropColor Class");
            }
            
            
            
            // Футболка
            if (i == 2) {
                NSArray *sizes = type.sizes;
                
                for (id object in sizes) {
                    XCTAssertTrue([object isKindOfClass:[PropSize class]], @"Do not PropSize Class");
                }
                
                for (PropSize *size in sizes) {
                    XCTAssertFalse(size.size.length == 0, @"Size is Empty");
                }
                
                XCTAssertTrue([type.selectPropSize isKindOfClass:[PropSize class]], @"Do not PropSize Class");
            }
        }

    }
    
    
    // From 6 to 8
    for (int i=6; i<8; i++) {
        NSArray *types = [coreStore getTypesWithPurchaseID:[NSString stringWithFormat:@"%i", i]];
        XCTAssertFalse(types.count == 0, @"Types empty. PurchaseID: %i", i);
        
        for (id object in types) {
            XCTAssertTrue([object isKindOfClass:[PropType class]], @"Do not PropSize Class");
        }
        
        for (PropType *type in types) {
            XCTAssertFalse(type.name.length == 0, @"PropType.Name is Empty");
            XCTAssertTrue(type.price > 0, @"Price == %li", (unsigned long)type.price);
        }
    }
    
    
    // From 11 to 20
    for (int i=11; i<20; i++) {
        NSArray *types = [coreStore getTypesWithPurchaseID:[NSString stringWithFormat:@"%i", i]];
        XCTAssertFalse(types.count == 0, @"Types empty. PurchaseID: %i", i);
        
        for (id object in types) {
            XCTAssertTrue([object isKindOfClass:[PropType class]], @"Do not PropType Class");
        }
        
        // Перебираем ТИП (type)
        for (PropType *type in types) {
            XCTAssertFalse(type.name.length == 0, @"PropType.Name is Empty");
            XCTAssertTrue(type.price > 0, @"Price == %li", (unsigned long)type.price);
 
        }
    }
    
    
    // from 21 to 22
    for (int i=21; i<22; i++) {
        NSArray *types = [coreStore getTypesWithPurchaseID:[NSString stringWithFormat:@"%i", i]];
        XCTAssertFalse(types.count == 0, @"Types empty. PurchaseID: %i", i);
        
        for (id object in types) {
            XCTAssertTrue([object isKindOfClass:[PropType class]], @"Do not PropSize Class");
        }
        
        for (PropType *type in types) {
            XCTAssertFalse(type.name.length == 0, @"PropType.Name is Empty");
            XCTAssertTrue(type.price > 0, @"Price == %li", (unsigned long)type.price);
        }
    }
}*/

#pragma mark - Album Params
- (void) testCoreDataDefaultParams
{
    PropType *propType = [coreStore getDefaultAlbumParamsWithAlbumID:@"13" andTypePropName:TypeNameConstructor];
    
    
    /*XCTAssertTrue(propType.defaultUturns.count == 1, @"UTurn one. %li", (unsigned long)propType.defaultUturns.count);
    XCTAssertTrue(propType.defaultSizes.count == 1, @"Sizes one. %li", (unsigned long)propType.defaultSizes.count);
    XCTAssertTrue(propType.defaultCovers.count == 1, @"Uturns one. %li", (unsigned long)propType.defaultCovers.count);
    XCTAssertTrue(propType.defaultStyles.count == 1, @"Styles one. %li", (unsigned long)propType.defaultStyles.count);
    
    
    XCTAssertFalse(propType.defaultUturns.count == 0, @"Sizes is Empty");
    XCTAssertFalse(propType.defaultSizes.count == 0, @"Uturn is Empty");
    XCTAssertFalse(propType.defaultCovers.count == 0, @"Covers is Empty");
    XCTAssertFalse(propType.defaultStyles.count == 0, @"Styles is Empty");*/
    
    
    // Size
    NSArray *sizes = propType.sizes;
    for (PropSize *size in sizes) {
        XCTAssertFalse(size.sizeName.length == 0, @"Size is Empty");
    }
    
    
    // Uturn
    NSArray *uturns = propType.uturns;
    for (id object in uturns) {
        XCTAssertTrue([object isKindOfClass:[PropUturn class]], @"Do not PropUturn Class");
    }
    
    for (PropUturn *uturn in uturns) {
        XCTAssertFalse(uturn.uturn.length == 0, @"Uturn is Empty");
    }
    
    
    // Cover
    NSArray *covers = propType.covers;
    for (id object in covers) {
        XCTAssertTrue([object isKindOfClass:[PropCover class]], @"Do not PropCover Class");
    }
    
    for (PropCover *cover in covers) {
        XCTAssertFalse(cover.cover.length == 0, @"Cover is Empty");
    }
    
    
    // Styles
    NSArray *styles = propType.styles;
    for (id object in styles) {
        XCTAssertTrue([object isKindOfClass:[PropStyle class]], @"Do not PropStyle Class");
    }
    
    for (PropStyle *style in styles) {
        XCTAssertFalse(style.styleName.length == 0, @"Style is Empty");
    }
}


- (void) testAlbumSizes
{
    NSArray *sizes = [coreStore getSizesWithPurchaseID:@"13" andTypePropName:TypeNameDesign];
    
    XCTAssertFalse(sizes.count == 0, @"Sizes is Empty");
    //XCTAssertFalse(propType.uturns.count == 0, @"Uturn is Empty");
    //XCTAssertFalse(propType.covers.count == 0, @"Covers is Empty");
    
    
    // Size
    for (PropSize *size in sizes) {
        XCTAssertFalse(size.sizeName.length == 0, @"Size is Empty");
    }

    for (id object in sizes) {
        XCTAssertTrue([object isKindOfClass:[PropSize class]], @"Do not PropSize Class");
    }
}

- (void) testAlbumUturns
{
    NSArray *uturns = [coreStore getUturnWithPurchaseID:@"13" andTypePropName:TypeNameDesign];
    
    XCTAssertFalse(uturns.count == 0, @"Utuns is Empty");
    //XCTAssertFalse(propType.uturns.count == 0, @"Uturn is Empty");
    //XCTAssertFalse(propType.covers.count == 0, @"Covers is Empty");
    
    
    // Size
    for (PropUturn *uturn in uturns) {
        XCTAssertFalse(uturn.uturn.length == 0, @"Uturn is Empty");
    }
    
    for (id object in uturns) {
        XCTAssertTrue([object isKindOfClass:[PropUturn class]], @"Do not PropUturn Class");
    }
}


- (void) testAlbumStylesDesign
{
    NSArray *styles = [coreStore getStylesWithPurchaseID:@"13" andTypePropName:TypeNameDesign];
    
    XCTAssertFalse(styles.count == 0, @"Styles is Empty");
    //XCTAssertFalse(propType.uturns.count == 0, @"Uturn is Empty");
    //XCTAssertFalse(propType.covers.count == 0, @"Covers is Empty");
    
    
    // Size
    for (PropStyle *style in styles) {
        XCTAssertFalse(style.styleName.length == 0, @"Style is Empty");
    }
    
    for (id object in styles) {
        XCTAssertTrue([object isKindOfClass:[PropStyle class]], @"Do not PropStyle Class");
    }
}



- (void) testAlbumStylesConstructor
{
    NSArray *styles = [coreStore getStylesWithPurchaseID:@"13" andTypePropName:TypeNameConstructor];
    
    XCTAssertFalse(styles.count == 0, @"Styles is Empty");
    //XCTAssertFalse(propType.uturns.count == 0, @"Uturn is Empty");
    //XCTAssertFalse(propType.covers.count == 0, @"Covers is Empty");
    
    
    // Size
    for (PropStyle *style in styles) {
        XCTAssertFalse(style.styleName.length == 0, @"Style is Empty");
    }
    
    for (id object in styles) {
        XCTAssertTrue([object isKindOfClass:[PropStyle class]], @"Do not PropStyle Class");
    }
}



- (void) testAlbumCovers
{
    NSArray *covers = [coreStore getCoversWithPurchaseID:@"13" andTypePropName:TypeNameDesign];
    
    XCTAssertFalse(covers.count == 0, @"Utuns is Empty");
    //XCTAssertFalse(propType.uturns.count == 0, @"Uturn is Empty");
    //XCTAssertFalse(propType.covers.count == 0, @"Covers is Empty");
    
    
    // Size
    for (PropCover *cover in covers) {
        XCTAssertFalse(cover.cover.length == 0, @"Cover is Empty");
    }
    
    for (id object in covers) {
        XCTAssertTrue([object isKindOfClass:[PropCover class]], @"Do not PropCover Class");
    }
}



#pragma mark - TShirt
- (void) testTShirtSize {
    NSArray *sizes = [coreStore getSizesWithPurchaseID:@"2" andTypePropName:@"default"];
    
    XCTAssertFalse(sizes.count == 0, @"Sizes is Empty. %lu", (unsigned long)sizes.count);
    //XCTAssertFalse(propType.uturns.count == 0, @"Uturn is Empty");
    //XCTAssertFalse(propType.covers.count == 0, @"Covers is Empty");
    
    
    // Size
    for (PropSize *size in sizes) {
        XCTAssertFalse(size.sizeName.length == 0, @"Size is Empty");
    }
    
    for (id object in sizes) {
        XCTAssertTrue([object isKindOfClass:[PropSize class]], @"Do not PropSize Class");
    }

}



#pragma mark - Mug
- (void) testMugColor{
    NSArray *colors = [coreStore getColorsWithPurchaseID:@"1" andTypePropName:@"heart"];
    
    XCTAssertFalse(colors.count == 0, @"Colors is Empty. %lu", (unsigned long)colors.count);
    //XCTAssertFalse(propType.uturns.count == 0, @"Uturn is Empty");
    //XCTAssertFalse(propType.covers.count == 0, @"Covers is Empty");
    
    
    // Size
    for (PropColor *propcolor in colors) {
        XCTAssertFalse(propcolor.color.length == 0, @"Size is Empty");
    }
    
    for (id object in colors) {
        XCTAssertTrue([object isKindOfClass:[PropColor class]], @"Do not PropSize Class");
    }
    
}



#pragma mark - Category's Store
- (void) testGetStoreCategoryes
{
    NSArray *categoties = [coreStore getStoreCategoryes];
    XCTAssertFalse(categoties.count == 0, @"Categories is Empty");
    
    for (NSString *categoryName in categoties) {
        XCTAssertFalse(categoryName.length == 0, @"Category is Empty");
    }
}


- (void) testGetStoreCategoryesWithCategoryId
{
    NSString *categoryName = [coreStore getCategoryTitleWithCategoryID:2];
    XCTAssertFalse(categoryName.length == 0, @"Category is Empty");
}



- (void) testGetItemsWithCategoryCoversAndMagnits
{
    NSString *const categoryName = @"Чехлы и магниты";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    XCTAssertFalse(storeItems.count == 0, @"PropTypes is Empty");
    
    for (StoreItem *store in storeItems) {
        XCTAssertFalse(store.categoryID == 0, @"CategoryID is Empty");
        XCTAssertFalse(store.categoryName.length == 0, @"categoryName is Empty");
        XCTAssertFalse(store.namePurchase.length == 0, @"namePurchase is Empty");
        XCTAssertFalse(store.purchaseID.length == 0, @"purchaseID is Empty");
        XCTAssertTrue(store.available, @"unavailable : %@", store.purchaseID);
        XCTAssertNotNil(store.iconShopCart, @"IconShopCart == nil");
        XCTAssertNotNil(store.iconStoreImage, @"IconShopCart == nil");
        
        XCTAssertFalse(store.types.count == 0, @"Types is Empty");
        XCTAssertTrue(store.types.count == 1, @"PropTypes is not == 1. id = %@, count = %li", store.purchaseID, (unsigned long)store.types.count);
        
        
        // Types
        for (PropType *propType in store.types) {
            XCTAssertFalse(propType.name.length == 0, @"PropType.name is Empty");
            XCTAssertFalse(propType.price == 0, @"PropType.price == 0");
        }
    }
}


- (void) testGetItemsWithCategorySouvenirs
{
    NSString *const categoryName = @"Сувениры и подарки";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    XCTAssertFalse(storeItems.count == 0, @"PropTypes is Empty");
    
    for (StoreItem *store in storeItems) {
        XCTAssertFalse(store.categoryID == 0, @"CategoryID is Empty");
        XCTAssertFalse(store.categoryName.length == 0, @"categoryName is Empty");
        XCTAssertFalse(store.namePurchase.length == 0, @"namePurchase is Empty");
        XCTAssertFalse(store.purchaseID.length == 0, @"purchaseID is Empty");
        XCTAssertTrue(store.available, @"unavailable : %@", store.purchaseID);
        XCTAssertNotNil(store.iconShopCart, @"IconShopCart == nil");
        XCTAssertNotNil(store.iconStoreImage, @"IconShopCart == nil");
        
        XCTAssertFalse(store.types.count == 0, @"Types is Empty");
        XCTAssertTrue(store.types.count == 1, @"PropTypes is not == 1. id = %@, count = %li", store.purchaseID, (unsigned long)store.types.count);

        
        // Types
        for (PropType *propType in store.types) {
            XCTAssertFalse(propType.name.length == 0, @"PropType.name is Empty");
            XCTAssertFalse(propType.price == 0, @"PropType.price == 0");
        }
    }
}



- (void) testGetItemsWithCategoryPhotoPrint
{
    NSString *const categoryName = @"Фотопечать";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    XCTAssertFalse(storeItems.count == 0, @"PropTypes is Empty");
    
    for (StoreItem *store in storeItems) {
        XCTAssertFalse(store.categoryID == 0, @"CategoryID is Empty");
        XCTAssertFalse(store.categoryName.length == 0, @"categoryName is Empty");
        XCTAssertFalse(store.namePurchase.length == 0, @"namePurchase is Empty");
        XCTAssertFalse(store.purchaseID.length == 0, @"purchaseID is Empty");
        XCTAssertTrue(store.available, @"unavailable : %@", store.purchaseID);
        XCTAssertNotNil(store.iconShopCart, @"IconShopCart == nil");
        XCTAssertNotNil(store.iconStoreImage, @"IconShopCart == nil");
        
        XCTAssertFalse(store.types.count == 0, @"Types is Empty");
        XCTAssertTrue(store.types.count == 1, @"PropTypes is not == 1. id = %@, count = %li", store.purchaseID, (unsigned long)store.types.count);
        
        
        // Types
        for (PropType *propType in store.types) {
            XCTAssertFalse(propType.name.length == 0, @"PropType.name is Empty");
            XCTAssertFalse(propType.price == 0, @"PropType.price == 0");
        }
    }
}


- (void) testGetItemsWithCategoryAlbums
{
    NSString *const categoryName = @"Альбомы";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    XCTAssertFalse(storeItems.count == 0, @"PropTypes is Empty");
    
    for (StoreItem *store in storeItems) {
        XCTAssertFalse(store.categoryID == 0, @"CategoryID is Empty");
        XCTAssertFalse(store.categoryName.length == 0, @"categoryName is Empty");
        XCTAssertFalse(store.namePurchase.length == 0, @"namePurchase is Empty");
        XCTAssertFalse(store.purchaseID.length == 0, @"purchaseID is Empty");
        XCTAssertTrue(store.available, @"unavailable : %@", store.purchaseID);
        XCTAssertNotNil(store.iconShopCart, @"IconShopCart == nil");
        XCTAssertNotNil(store.iconStoreImage, @"IconStoreImage == nil");
        
        XCTAssertFalse(store.types.count == 0, @"Types is Empty");
        XCTAssertTrue(store.types.count == 1, @"PropTypes is not == 1. id = %@, count = %li", store.purchaseID, (unsigned long)store.types.count);
        
        
        // Types
        for (PropType *propType in store.types) {
            XCTAssertFalse(propType.name.length == 0, @"PropType.name is Empty");
            XCTAssertFalse(propType.price == 0, @"PropType.price == 0");
        }
    }
}


- (void) testGetItemsWithCategorySpecial
{
    NSString *const categoryName = @"Спец.предложения";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    XCTAssertTrue(storeItems.count == 0, @"PropTypes is Empty"); // Здесь == 0
    
    for (StoreItem *store in storeItems) {
        XCTAssertFalse(store.categoryID == 0, @"CategoryID is Empty");
        XCTAssertFalse(store.categoryName.length == 0, @"categoryName is Empty");
        XCTAssertFalse(store.namePurchase.length == 0, @"namePurchase is Empty");
        XCTAssertFalse(store.purchaseID.length == 0, @"purchaseID is Empty");
        XCTAssertTrue(store.available, @"unavailable : %@", store.purchaseID);
        XCTAssertNotNil(store.iconShopCart, @"IconShopCart == nil");
        XCTAssertNotNil(store.iconStoreImage, @"IconShopCart == nil");
        
        XCTAssertFalse(store.types.count == 0, @"Types is Empty");
        XCTAssertTrue(store.types.count == 1, @"PropTypes is not == 1. id = %@, count = %li", store.purchaseID, (unsigned long)store.types.count);
        
        
        // Types
        for (PropType *propType in store.types) {
            XCTAssertFalse(propType.name.length == 0, @"PropType.name is Empty");
            XCTAssertFalse(propType.price == 0, @"PropType.price == 0");
        }
    }
}

- (void) testGetTypesWithPurchaseID
{
    NSArray *types = [coreStore getTypesWithPurchaseID:@"13"];

    for (id object in types) {
        XCTAssertTrue([object isKindOfClass:[PropType class]], @"Do not PropType Class");
    }
    
    // Перебираем ТИП (type)
    for (PropType *type in types) {
        XCTAssertFalse(type.name.length == 0, @"PropType.Name is Empty");
        XCTAssertTrue(type.price > 0, @"Price == %li", (unsigned long)type.price);
        
    }
}

@end
