//
//  SaveManagerTest.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 06/01/16.
//  Copyright © 2016 Мартынов Дмитрий. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PHouseApi.h"

#import "ResponseAuth.h"
#import "ResponseGetItems.h"
#import "ResponseGetDeliveries.h"

#import "CoreDataStore.h"
#import "CoreDataShopCart.h"
#import "CoreDataProfile.h"

#import "DeliveryCity.h"
#import "DeliveryType.h"
#import "Payment.h"

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
#import "PrintImage.h"

#import "SaveImageManager.h"
#import "UploadImageManager.h"

#import "NSString+MD5.h"

#import "MDPhotoLibrary.h"

#import "BundleDefault.h"
#import "ResponseGetItems.h"
#import "ResponseAlbumV2.h"

#import "PhotoRecord.h"


static CGFloat const TIMEOUT_SAVE_MANAGER = 60.f;


typedef enum {
    SaveTypeTestAllComplete,        ///< Сохраняем все
    SaveTypeTestSavePreviewCancel,  ///< Отменяем при сохраниении картинок
    SaveTypeTestSaveFinalCancel     ///< Отменяем при финальном сохранении картинок
} SaveTypeTest;


@interface SaveManagerTest : XCTestCase<SaveImageManagerDelegate, PHouseApiDelegate>
@property (nonatomic) XCTestExpectation *expectation;
@property (nonatomic) SaveTypeTest saveTypeTest;
@end


@implementation SaveManagerTest {
    MDPhotoLibrary *pLibrary;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop removeAll];
    
    pLibrary = [[MDPhotoLibrary alloc] init];
}

- (void)tearDown {
    
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop removeAll];
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSaveManagerWait {
    // Wait
    XCTestExpectation *expectation = [self expectationWithDescription:@"Order"];
    self.expectation = expectation;
    
    self.saveTypeTest = SaveTypeTestAllComplete;
    
    //     SaveLocal
    BundleDefault *bDefault = [[BundleDefault alloc] init];
    NSData *dataItems = [bDefault defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseAlbumV2 *responseAlbum = [[ResponseAlbumV2 alloc] initWitParseData:[bDefault defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    ResponseGetItems *response;
    response = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbum.oldTemplates];


    [self makeAlbum20x20UpOrientation];
    
    
    //
    [self waitForExpectationsWithTimeout:TIMEOUT_SAVE_MANAGER handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}

- (void)testSaveManagerCancelWithSaveOriginal {
    // Wait
    XCTestExpectation *expectation = [self expectationWithDescription:@"Order"];
    self.expectation = expectation;
    
    self.saveTypeTest = SaveTypeTestSavePreviewCancel;
    
    //     SaveLocal
    BundleDefault *bDefault = [[BundleDefault alloc] init];
    NSData *dataItems = [bDefault defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseAlbumV2 *responseAlbum = [[ResponseAlbumV2 alloc] initWitParseData:[bDefault defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    ResponseGetItems *response;
    response = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbum.oldTemplates];
    
    
    [self makeAlbum20x20UpOrientation];
    
    
    //
    [self waitForExpectationsWithTimeout:TIMEOUT_SAVE_MANAGER handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}


- (void)testSaveManagerCancelWithSaveFinal {
    // Wait
    XCTestExpectation *expectation = [self expectationWithDescription:@"Order"];
    self.expectation = expectation;
    
    self.saveTypeTest = SaveTypeTestSaveFinalCancel;
    
    //     SaveLocal
    BundleDefault *bDefault = [[BundleDefault alloc] init];
    NSData *dataItems = [bDefault defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseAlbumV2 *responseAlbum = [[ResponseAlbumV2 alloc] initWitParseData:[bDefault defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    ResponseGetItems *response;
    response = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbum.oldTemplates];
    
    
    [self makeAlbum20x20UpOrientation];
    
    
    //
    [self waitForExpectationsWithTimeout:TIMEOUT_SAVE_MANAGER handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}



#pragma mark - Methods Make
- (void) makeAlbum20x20UpOrientation {
    NSString *const categoryName = @"Альбомы";
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"] && [item.propType.name isEqualToString:TypeNameDesign]) {
            storeItem = item;
        }
    }
    
    /// Блок поиска наибольшего кол-ва фотографий
    PropStyle* (^MaxStyleImageBlock)(StoreItem *storeItem) = ^(StoreItem *storeItem) {
        PropStyle *style = nil;
        
        for (PropStyle *stl in storeItem.propType.styles) {
            if (!style) {
                style = stl;
            }
            
            if (stl.maxCount > style.maxCount) {
                style = stl;
            }
        }
        
        return style;
    };
    
    
    PropStyle *style = MaxStyleImageBlock(storeItem);
    CGSize imageSize = CGSizeMake(1600, 1200);
    NSUInteger assetCount = style.maxCount;
    [pLibrary loadPhotoALAssetsCount:assetCount withSize:imageSize andOrientation:-1 withSuccessBlock:^(NSArray *assets, NSError *error) {
        // Массив [PrintImage]
        NSMutableArray *printImages = [NSMutableArray array];
        
        // Перебираем
        for (ALAsset *asset in assets) {
            XCTAssertTrue([asset isKindOfClass:[ALAsset class]]);
            ALAssetRepresentation *representation = asset.defaultRepresentation;
            NSString *urlLibrary = [representation.url absoluteString];
            NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
            
            NSDictionary *metadata = asset.defaultRepresentation.metadata;
            CGSize imageSize = [pLibrary imageSizeWithMetaData:metadata];
            
            PhotoRecord *record = [[PhotoRecord alloc] initAssetThumbal:asset.thumbnail andNameUrlLibary:urlLibrary andDate:date andImageSize:imageSize];
            PrintImage *pImage = [[PrintImage alloc] initWithPreviewImage:record.image withName:record.name andEditSetting:nil originalSize:record.imageSize andUploadUrl:nil];
            [printImages addObject:pImage];
        }
        
        XCTAssertEqual(printImages.count, assetCount);
        
        // Формируем PrintData
        PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
        [printData addPrintImagesFromPhotoLibrary:[printImages copy]];
        
        //
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        [coreShop savePrintData:printData];
        
        // Save Manager
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SaveImageManager *manager = [[SaveImageManager alloc] initManagerWithPrintData:printData andDelegate:self orPrintImages:nil];
            [manager startSave];
        });
    }];
}



#pragma mark - SaveImageManagerDelegate
-(void)saveImageManager:(SaveImageManager *)manager didAllBigImagesSaved:(PrintData *)printData {
    
    NSArray *pImages = printData.images;
    for (PrintImage *pImage in pImages) {
        XCTAssertTrue([pImage isKindOfClass:[PrintImage class]]);
        XCTAssertNotNil(pImage.urlLibrary);
        XCTAssertNotNil(pImage.iconPreviewImage);
        XCTAssertNotNil(pImage.previewImage);
        XCTAssertTrue(pImage.originalImageSize.width > 0.f);
        XCTAssertTrue(pImage.originalImageSize.height > 0.f);
        XCTAssertTrue(pImage.urlLibrary.length > 0);
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SaveImageManager *manager = [[SaveImageManager alloc] initFinalSavePrintData:printData andDelegate:self];
        [manager startSave];
        
//        [manager stopSave];
    });
}

-(void)saveImageManager:(SaveImageManager *)manager didBigImagesSaved:(PrintImage *)printImage withPrintData:(PrintData *)printData {
    if (self.saveTypeTest == SaveTypeTestSavePreviewCancel) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [manager stopSave];
        });
    }
}

-(void)saveImageManager:(SaveImageManager *)manager didCancelSave:(PrintData *)printData {
    if (self.saveTypeTest == SaveTypeTestSavePreviewCancel || self.saveTypeTest == SaveTypeTestSaveFinalCancel) {
        [self.expectation fulfill];
    }
}

-(void)saveImageManager:(SaveImageManager *)manager didSaveAllToPrepareFinalSave:(PrintData *)printData {
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop finalCompletePrintData:printData];
    
    
    // Items
    PrintData *saved = [[coreShop getAllItemsWithNeedAddImages:NO] firstObject];
    XCTAssertTrue(saved.storeItem.propType.sizes.count > 0);
    XCTAssertTrue(saved.props.allKeys.count > 0);
    
    [self.expectation fulfill];
}

-(void)saveImageManager:(SaveImageManager *)manager didSavedToProgress:(CGFloat)progress {
//    if (self.saveTypeTest == SaveTypeTestSaveFinalCancel) {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            [manager stopSave];
//        });
//    }
}

@end
