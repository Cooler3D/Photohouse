//
//  PhotoHouseStoreAndTemplate.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 06/12/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PHouseApi.h"

#import "ResponseGetItems.h"

#import "CoreDataStore.h"

#import "Template.h"
#import "Layout.h"
#import "Layer.h"
#import "Image.h"

#import "StoreItem.h"
#import "PropType.h"
#import "PropCover.h"
#import "PropSize.h"
#import "PropUturn.h"
#import "PropColor.h"
#import "PropStyle.h"

#import "PrintData.h"

static CGFloat const TIMEOUT_STORE = 80.f;



@interface PhotoHouseStoreAndTemplateTest : XCTestCase <PHouseApiDelegate>
@property (nonatomic) XCTestExpectation *expectation;
@property (nonatomic) NSMutableArray *allTemplates;
@end

@implementation PhotoHouseStoreAndTemplateTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TemplateDownloadComplateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TemplateDownloadProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TemplateDownloadErrorNotification object:nil];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStoreItemAndTemplates {
    // Expectation
    XCTestExpectation *expectation = [self expectationWithDescription:@"Auth"];
    self.expectation = expectation;
    
    
    // Api
    PHouseApi *api = [[PHouseApi alloc] init];
    [api getAllItemsWithDelegate:self];
    
    
    // Wait
    [self waitForExpectationsWithTimeout:TIMEOUT_STORE handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}


#pragma mark - Methods Check
- (void) checkCategoties:(NSArray*)items {
    NSMutableArray *categoryNames = [NSMutableArray array];
    
    for (StoreItem *sItem in items) {
        NSInteger count = 0;
        NSInteger categoryID = sItem.categoryID;
        for (StoreItem *item in items) {
            if (categoryID == item.categoryID) {
                count++;
            }
        }
        XCTAssertTrue(count == 1);
        [categoryNames addObject:sItem.categoryName];
    }
    
    
    
    // Проверка всех занчений с сервера
    NSArray* (^ReadCoreStoreBlock)(NSString*) = ^(NSString *categoryName){
        CoreDataStore *coreStore = [[CoreDataStore alloc] init];
        NSArray *array = [coreStore getStoreItemsWithCategoryName:categoryName];
        return array;
    };
    
    
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        NSArray *items = ReadCoreStoreBlock([categoryNames objectAtIndex:0]);
        StoreItem *it = [items firstObject];
        if (it.categoryID == StoreTypePhotoAlbum) {
            [self checkStoreItemsAlbum:items];
        } else {
            [self checkStoreItems:items];
        }
    });
    dispatch_group_async(group, queue, ^{
        NSArray *items = ReadCoreStoreBlock([categoryNames objectAtIndex:1]);
        StoreItem *it = [items firstObject];
        if (it.categoryID == StoreTypePhotoPrint) {
            [self chectPhotoPrints:items];
        } else {
            [self checkStoreItems:items];
        }

    });
    dispatch_group_async(group, queue, ^{
        NSArray *items = ReadCoreStoreBlock([categoryNames objectAtIndex:2]);
        [self checkStoreItems:items];
    });
    dispatch_group_async(group, queue, ^{
        NSArray *items = ReadCoreStoreBlock([categoryNames objectAtIndex:3]);
        [self checkStoreItems:items];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"All task are done");
//        [self.expectation fulfill];
        
        // Download Templates
        CoreDataStore *coreStore = [[CoreDataStore alloc] init];
        NSArray *allTemplates = [coreStore getAllTemplatesWithPurchaseID:@"13" andPropTypeName:TypeNameConstructor];
        self.allTemplates = [allTemplates mutableCopy];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(notificationTemplateDownloadComplete:) name:TemplateDownloadComplateNotification object:nil];   // Успешно загруженны верска шаблона
        [nc addObserver:self selector:@selector(notificationTemplateProgressComplete:) name:TemplateDownloadProgressNotification object:nil];   // Прогресс загрузки верски
        [nc addObserver:self selector:@selector(notificationTemplateDownloadError:) name:TemplateDownloadErrorNotification object:nil];         // Ошибка загрузки верски
        
        // Start
        [self nextLoadTemplate:self.allTemplates];
    });
}


- (void) checkStoreItems:(NSArray *)storeItems {
    for (StoreItem *store in storeItems) {
        PrintData *printData = [[PrintData alloc] initWithStoreItem:store andUniqueNum:0];
        XCTAssertTrue(printData.purchaseID > 0, @"PurchaseId == %li",(long)printData.purchaseID);
        XCTAssertFalse([printData count] == 0, @"Count == %lu", (unsigned long)printData.count);
        XCTAssertFalse([printData price] == 0, @"Price == %li", (long)printData.price);
        XCTAssertNotNil([printData iconShopCart], @"Icon image nil: ID: %li", (long)printData.purchaseID);
        XCTAssertNotNil([printData gridImage], @"Grid image nil: ID: %li", (long)printData.purchaseID);
        XCTAssertNotNil([printData showCaseImage], @"ShowCaseImage == nil; PurchaseId: %i", (int)printData.purchaseID);
        
        
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



- (void) chectPhotoPrints:(NSArray *)storeItems {
    for (StoreItem *store in storeItems) {
        PrintData *printData = [[PrintData alloc] initWithStoreItem:store andUniqueNum:0];
        XCTAssertTrue(printData.purchaseID > 0, @"PurchaseId == %li",(long)printData.purchaseID);
        XCTAssertFalse([printData count] == 0, @"Count == %lu", (unsigned long)printData.count);
        XCTAssertFalse([printData price] == 0, @"Price == %li", (long)printData.price);
        XCTAssertNotNil([printData iconShopCart], @"Icon image nil: ID: %li", (long)printData.purchaseID);
        XCTAssertNotNil(store.iconStoreImage, @"Icon store nil: ID: %li", (long)printData.purchaseID);
        XCTAssertNotNil([printData gridImage], @"Grid image nil: ID: %li", (long)printData.purchaseID);
    }

}


- (void) checkStoreItemsAlbum:(NSArray*)storeItems {
    XCTAssertFalse(storeItems.count == 0, @"Store is Empty");
    
    for (StoreItem *store in storeItems) {
        PrintData *printData = [[PrintData alloc] initWithStoreItem:store andUniqueNum:0];
        XCTAssertTrue(printData.purchaseID > 0, @"PurchaseId == %li",(long)printData.purchaseID);
        XCTAssertFalse(printData.namePurchase.length == 0, @"namePurchase is Empty");
        XCTAssertFalse([printData count] == 0, @"Count == %lu", (unsigned long)printData.count);
        XCTAssertFalse([printData price] == 0, @"Price == %li", (long)printData.price);
        XCTAssertNotNil([printData iconShopCart], @"Icon image nil: ID: %li", (long)printData.purchaseID);
        XCTAssertNil([printData gridImage], @"Grid image nil: ID: %i", (int)printData.purchaseID);
        
        
        
        
        // Props album
        NSArray *keys = [[printData props] allKeys];
        XCTAssertFalse([keys count] == 0, @"Prop Keys == %i", (int)printData.count);
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

- (void) checkTemplate:(Template*)originalTemplate {
    
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
        XCTAssertNotNil(backImage.image);
        
        
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
        XCTAssertNotNil(frontImage.image);
        
        
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


#pragma mark - Methods
-(void) removeFromArray:(NSMutableArray *)allTemplates withTemplate:(Template*)template {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS %@", template.name];
    NSArray *filtred = [self.allTemplates filteredArrayUsingPredicate:predicate];
    XCTAssertTrue(filtred.count > 0);
    
    Template *removeTemplate;
    for (Template *fTemplate in filtred) {
        if ([fTemplate.size isEqualToString:template.size]) {
            removeTemplate = fTemplate;
        }
    }
    
    XCTAssertNotNil(removeTemplate);
    [self.allTemplates removeObject:removeTemplate];
    
    [self nextLoadTemplate:self.allTemplates];
}


- (void) nextLoadTemplate:(NSMutableArray *)templates {
    if (templates.count == 0) {
        [self.expectation fulfill];
    } else {
        Template *alTemplate = [templates firstObject];
        [alTemplate downloadImages];
    }
}


#pragma mark - Notification
- (void) notificationTemplateDownloadComplete:(NSNotification *)notification
{
    // Read
    NSDictionary *userInfo = notification.userInfo;
    Template *template = [userInfo objectForKey:TemplateKey];
    
    [self removeFromArray:self.allTemplates withTemplate:template];
}


- (void) notificationTemplateProgressComplete:(NSNotification *)notification
{
    
}


- (void) notificationTemplateDownloadError:(NSNotification *)notification
{
    //
    NSDictionary *userInfo = notification.userInfo;
    Template *template = [userInfo objectForKey:TemplateKey];
    
    
    [self removeFromArray:self.allTemplates withTemplate:template];
}






#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didStoreItemsReceiveData:(PHResponse *)response {
    NSMutableArray *categores = [NSMutableArray array];
    
    NSArray* (^ReadCoreStoreBlock)(StoreType) = ^(StoreType store){
        CoreDataStore *coreStore = [[CoreDataStore alloc] init];
        NSString *name = [coreStore getCategoryTitleWithCategoryID:store];
        NSArray *array = [coreStore getStoreItemsWithCategoryName:name];
        return array;
    };
    
    
    
    
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        [categores addObject:ReadCoreStoreBlock(StoreTypePhotoPrint)];
    });
    dispatch_group_async(group, queue, ^{
        [categores addObject:ReadCoreStoreBlock(StoreTypePhotoAlbum)];
    });
    dispatch_group_async(group, queue, ^{
        [categores addObject:ReadCoreStoreBlock(StoreTypeSovenir)];
    });
    dispatch_group_async(group, queue, ^{
        [categores addObject:ReadCoreStoreBlock(StoreTypeCoverCase)];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSMutableArray *storeMenu = [NSMutableArray array];
        for (NSArray *array in categores) {
            StoreItem *item = [array firstObject];
            [storeMenu addObject:item];
        }
        StoreItem *special = [[StoreItem alloc] initStoreWithPurchaseID:@"" andTypeStore:@"" andDescriptionStory:@"" andNamePurchase:@"" andCategoryID:@"5" andCategoryName:@"Спец.предложения" andAvailable:YES andTypes:nil];
        [storeMenu addObject:special];
        
        
        // Sort
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryID" ascending:YES];
        NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray *final = [storeMenu sortedArrayUsingDescriptors:descriptors];
        [self checkCategoties:final];
    });
}



-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error {
    XCTFail(@"Error: %@", error);
    
    [self.expectation fulfill];
}

@end
