//
//  AlbumDesignTest.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 01/01/16.
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


static CGFloat const TIMEOUT_DESIGNALBUM = 100.f;

@interface AlbumDesignTest : XCTestCase<SaveImageManagerDelegate, PHouseApiDelegate/*, UploadImageManagerDelegate*/>
@property (nonatomic) XCTestExpectation *expectation;
@end

@implementation AlbumDesignTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop removeAll];
}

- (void)tearDown {
    
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop removeAll];
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDesignAlbum {
    // Wait
    XCTestExpectation *expectation = [self expectationWithDescription:@"Order"];
    self.expectation = expectation;
    
    
    // All Items
//    PHouseApi *api = [[PHouseApi alloc] init];
//    [api getAllItemsWithDelegate:self];
    
//#warning ToDo: Local -> OnLine
    // SaveLocal
    BundleDefault *bDefault = [[BundleDefault alloc] init];
    NSData *dataItems = [bDefault defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseAlbumV2 *responseAlbum = [[ResponseAlbumV2 alloc] initWitParseData:[bDefault defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    ResponseGetItems *response;
    response = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbum.oldTemplates];
    
    [self makeAlbum20x20UpOrientation];
    
    
    //
    [self waitForExpectationsWithTimeout:TIMEOUT_DESIGNALBUM handler:^(NSError * _Nullable error) {
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
    
    MDPhotoLibrary *pLibrary = [[MDPhotoLibrary alloc] init];
    PropStyle *style = storeItem.propType.selectPropStyle;
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




#pragma mark - Methods
- (void) readShopCart {
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    PrintData *saved = [[coreShop getAllItemsWithNeedAddImages:YES] firstObject];
    XCTAssertTrue(saved.storeItem.propType.sizes.count > 0);
    XCTAssertTrue(saved.props.allKeys.count > 0);
    
    for (PrintImage *pImage in saved.images) {
        XCTAssertNotNil(pImage.urlLibrary);
        XCTAssertTrue(pImage.urlLibrary.length > 0);
        
        XCTAssertTrue(pImage.originalImageSize.width > 0);
        XCTAssertTrue(pImage.originalImageSize.height > 0);
        
        XCTAssertNotNil(pImage.previewImage);
    }
    
    [self.expectation fulfill];
    
    // Auth
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        PHouseApi *api = [[PHouseApi alloc] init];
//        NSString *password = @"123654";
//        NSString *salt = [NSString stringWithFormat:@"%@%@", api.salt, password];
//        NSString *pass = [salt MD5];
//        [api authLogin:@"diman.mart@yandex.ru" andPasswordHash:pass andDelegate:self];
//    });
}

//- (void) makeRequestOrder:(NSArray*)items {
//    DeliveryCity *deliveryCity = [self.deliveryResponse getDefaultDeliveryCity];
//    StoreItem *storeItem = [[StoreItem alloc] initDelivetyCity:deliveryCity];
//    PrintData *deliveryPrintData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
//    
//    
//    //
//    PHouseApi *api = [[PHouseApi alloc] init];
//    [api makeOrderFirstName:@"Test"
//                andLastName:@"User"
//                   andPhone:@"89302394832"
//                 andAddress:@"Address WordWide Web"
//                withComment:@"This order from UnitTest"
//       andPhotoRecordsArray:items
//        andDeliveryPrintDta:deliveryPrintData
//                andDelegate:self];
//    
//}


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
    });
}

-(void)saveImageManager:(SaveImageManager *)manager didBigImagesSaved:(PrintImage *)printImage withPrintData:(PrintData *)printData {
    
}

-(void)saveImageManager:(SaveImageManager *)manager didCancelSave:(PrintData *)printData {
}

-(void)saveImageManager:(SaveImageManager *)manager didSaveAllToPrepareFinalSave:(PrintData *)printData {
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop finalCompletePrintData:printData];
    
    
    // Items
    PrintData *saved = [[coreShop getAllItemsWithNeedAddImages:NO] firstObject];
    XCTAssertTrue(saved.storeItem.propType.sizes.count > 0);
    XCTAssertTrue(saved.props.allKeys.count > 0);
    
    [self readShopCart];
}

-(void)saveImageManager:(SaveImageManager *)manager didSavedToProgress:(CGFloat)progress {
}



#pragma mark - UploadImageManagerDelegate
//-(void)uploadImageManager:(UploadImageManager *)manager didImagesSaved:(PrintImage *)printImage withPrintData:(PrintData *)printData {
//    
//}
//
//-(void)uploadImageManager:(UploadImageManager *)manager didAllImagesSaved:(PrintData *)printData {
//    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
//    [self makeRequestOrder:[coreShop getAllItemsWithNeedAddImages:YES]];
//}
//
//-(void)uploadImageManager:(UploadImageManager *)manager didUploadProgress:(CGFloat)progress {
//}
//
//-(void)uploadImageManager:(UploadImageManager *)manager didUploadAllImagesProgress:(CGFloat)progress {
//}
//
//
//
//-(void)uploadImageManager:(UploadImageManager *)manager didCancelUpload:(PrintData *)printData {
//}




#pragma mark - PHouseApiDelegate
//-(void)pHouseApi:(PHouseApi *)phApi didAuthReceiveData:(PHResponse *)response {
//    // Проверяем ответ
//    ResponseAuth *auth = (ResponseAuth*)response;
//    XCTAssertTrue(auth.email.length > 0);
//    XCTAssertTrue(auth.passwordHash.length > 0);
//    XCTAssertTrue(auth.firstname.length > 0);
//    XCTAssertTrue(auth.lastname.length > 0);
//    XCTAssertTrue(auth.id_user.length > 0);
//    XCTAssertTrue(auth.passwordHash.length > 0);
//    XCTAssertTrue(auth.regdate.length > 0);
//    
//    // Проверяем сохраненность
//    CoreDataProfile *profile = [[CoreDataProfile alloc] init];
//    ResponseAuth *rAuth = [profile profile];
//    XCTAssertTrue(rAuth.firstname.length > 0);
//    XCTAssertTrue(rAuth.lastname.length > 0);
//    XCTAssertTrue(rAuth.id_user.length > 0);
//    XCTAssertTrue(rAuth.passwordHash.length > 0);
//    XCTAssertTrue(rAuth.regdate.length > 0);
//    
//    
//    // Получаем данные о доставке
//    [phApi getDeliveriesWithDelegate:nil orBlock:^(PHResponse *responce, NSError *error) {
//        self.deliveryResponse = (ResponseGetDeliveries*)responce;
//        
//        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
//        NSArray *allOrders = [coreShop getAllItemsWithNeedAddImages:YES];
//        
//        UploadImageManager *uploadManager = [[UploadImageManager alloc] initShopCartPrintDatas:allOrders];
//        [uploadManager setDelegate:self];
//        [uploadManager startUpload];
//    }];
//}


-(void)pHouseApi:(PHouseApi *)phApi didMakeOrderCompleteData:(PHResponse *)response {
    [self.expectation fulfill];
}

-(void)pHouseApi:(PHouseApi *)phApi didStoreItemsReceiveData:(PHResponse *)response {
    [self makeAlbum20x20UpOrientation];
}


-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error {
    XCTFail(@"Error: %@", error);
    [self.expectation fulfill];
}




@end
