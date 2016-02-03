//
//  PhotoHouseMakeOrderMug.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 07/01/16.
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

#import "PhotoRecord.h"

#import "SaveImageManager.h"
#import "UploadImageManager.h"

#import "NSString+MD5.h"

#import "MDPhotoLibrary.h"



static CGFloat const TIMEOUT_MAKE_MUG_ORDER = 90.f;

@interface PhotoHouseMakeOrderMug : XCTestCase <SaveImageManagerDelegate, PHouseApiDelegate, UploadImageManagerDelegate>
@property (nonatomic) XCTestExpectation *expectation;
@property (nonatomic) ResponseGetDeliveries *deliveryResponse;
@property (nonatomic) NSString *mugType;
@end

@implementation PhotoHouseMakeOrderMug

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

- (void)testMakeMug {
    // Wait
    XCTestExpectation *expectation = [self expectationWithDescription:@"Order"];
    self.expectation = expectation;
    
    
    // All Items
    PHouseApi *api = [[PHouseApi alloc] init];
    [api getAllItemsWithDelegate:self];
    
    
    //
    [self waitForExpectationsWithTimeout:TIMEOUT_MAKE_MUG_ORDER handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];

}


#pragma mark - Methods Make

- (void) makeMugGlassPrintData {
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    NSString *categoryName = [coreStore getCategoryTitleWithCategoryID:StoreTypeSovenir];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"1"] && [item.propType.name isEqualToString:MUG_TYPE_GLASS]) {
            storeItem = item;
        }
    }
    
    MDPhotoLibrary *pLibrary = [[MDPhotoLibrary alloc] init];
    CGSize imageSize = CGSizeMake(1600, 1200);
    NSUInteger assetCount = 1;
    [pLibrary loadPhotoALAssetsCount:assetCount withSize:imageSize andOrientation:-1 withSuccessBlock:^(NSArray *assets, NSError *error) {
        // Массив [PrintImage]
        NSMutableArray *printImages = [NSMutableArray array];
        
        ALAsset *asset = [assets firstObject];
        XCTAssertTrue([asset isKindOfClass:[ALAsset class]]);
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        NSString *urlLibrary = [representation.url absoluteString];
        NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
        
        NSDictionary *metadata = asset.defaultRepresentation.metadata;
        CGSize imageSize = [pLibrary imageSizeWithMetaData:metadata];
        
        PhotoRecord *record = [[PhotoRecord alloc] initAssetThumbal:asset.thumbnail andNameUrlLibary:urlLibrary andDate:date andImageSize:imageSize];
        PrintImage *pImage = [[PrintImage alloc] initWithPreviewImage:record.image withName:record.name andEditSetting:nil originalSize:record.imageSize andUploadUrl:nil];
        [printImages addObject:pImage];
        
        
        XCTAssertEqual(printImages.count, assetCount);
        
        // Формируем PrintData
        PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
        [printData addPrintImagesFromPhotoLibrary:[printImages copy]];
//        [printData createAndAddMergedImageWithPrintImage:pImage.previewImage];
        
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
    XCTAssertTrue(saved.storeItem.propType.sizes.count == 0);
    XCTAssertTrue(saved.props.allKeys.count > 0);
    
    PropType *propType = saved.storeItem.propType;
    XCTAssertEqualObjects(propType.name, self.mugType);
    
    for (PrintImage *pImage in saved.images) {
        XCTAssertNotNil(pImage.urlLibrary);
        XCTAssertTrue(pImage.urlLibrary.length > 0);
        
        XCTAssertTrue(pImage.originalImageSize.width > 0);
        XCTAssertTrue(pImage.originalImageSize.height > 0);
        
        XCTAssertNotNil(pImage.previewImage);
    }
    
    
    
    
    // Auth
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        PHouseApi *api = [[PHouseApi alloc] init];
        NSString *password = @"123654";
        NSString *salt = [NSString stringWithFormat:@"%@%@", api.salt, password];
        NSString *pass = [salt MD5];
        [api authLogin:@"diman.mart@yandex.ru" andPasswordHash:pass andDelegate:self];
    });
}

- (void) makeRequestOrder:(NSArray*)items {
    DeliveryCity *deliveryCity = [self.deliveryResponse getDefaultDeliveryCity];
    StoreItem *storeItem = [[StoreItem alloc] initDelivetyCity:deliveryCity];
    PrintData *deliveryPrintData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    
    // Comments
    NSString *comment = [NSString stringWithFormat:@"This order from UnitTest.\nMug Type: '%@'", self.mugType];
    
    //
    PHouseApi *api = [[PHouseApi alloc] init];
    [api makeOrderFirstName:@"Test"
                andLastName:@"User"
                   andPhone:@"89302394832"
                 andAddress:@"Address WordWide Web"
                withComment:comment
       andPhotoRecordsArray:items
        andDeliveryPrintDta:deliveryPrintData
                andDelegate:self];
    
}


#pragma mark - SaveImageManagerDelegate
-(void)saveImageManager:(SaveImageManager *)manager didAllBigImagesSaved:(PrintData *)printData {
    dispatch_async(dispatch_get_main_queue(), ^{
        PrintImage *printImage = [printData.imagesPreview firstObject];
        [printData createMergedImageWithPreview:printImage.previewImage andCompleteBlock:^(NSArray *images) {
            PrintImage *merged = [printData.mergedImages firstObject];
            XCTAssertNotNil(merged);
            
            // Change Size
            // Текущий размер футболки
//            StoreItem *storeItem = printData.storeItem;
//            PropSize *curSize = storeItem.propType.selectPropSize;
//            for (PropSize *size in storeItem.propType.sizes) {
//                if (![curSize.sizeName isEqualToString:size.sizeName]) {
//                    curSize = size;
//                    break;
//                }
//            }
            
            self.mugType = printData.storeItem.propType.name;
//            
//            [printData changeProp:curSize];
//            CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
//            [coreShop updateTemplateOrPropsPrintData:printData];
//            
            SaveImageManager *manager = [[SaveImageManager alloc] initFinalSavePrintData:printData andDelegate:self];
            [manager startSave];
        } andProgressBlock:nil];
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
    XCTAssertTrue(saved.storeItem.propType.sizes.count == 0);
    XCTAssertTrue(saved.props.allKeys.count > 0);
    
    [self readShopCart];
}

-(void)saveImageManager:(SaveImageManager *)manager didSavedToProgress:(CGFloat)progress {
}



#pragma mark - UploadImageManagerDelegate
-(void)uploadImageManager:(UploadImageManager *)manager didImagesSaved:(PrintImage *)printImage withPrintData:(PrintData *)printData {
    
}

-(void)uploadImageManager:(UploadImageManager *)manager didAllImagesSaved:(PrintData *)printData {
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [self makeRequestOrder:[coreShop getAllItemsWithNeedAddImages:YES]];
}

-(void)uploadImageManager:(UploadImageManager *)manager didUploadProgress:(CGFloat)progress {
}

-(void)uploadImageManager:(UploadImageManager *)manager didUploadAllImagesProgress:(CGFloat)progress {
    
}



-(void)uploadImageManager:(UploadImageManager *)manager didCancelUpload:(PrintData *)printData {
}




#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didAuthReceiveData:(PHResponse *)response {
    // Проверяем ответ
    ResponseAuth *auth = (ResponseAuth*)response;
    XCTAssertTrue(auth.email.length > 0);
    XCTAssertTrue(auth.passwordHash.length > 0);
    XCTAssertTrue(auth.firstname.length > 0);
    XCTAssertTrue(auth.lastname.length > 0);
    XCTAssertTrue(auth.id_user.length > 0);
    XCTAssertTrue(auth.passwordHash.length > 0);
    XCTAssertTrue(auth.regdate.length > 0);
    
    // Проверяем сохраненность
    CoreDataProfile *profile = [[CoreDataProfile alloc] init];
    ResponseAuth *rAuth = [profile profile];
    XCTAssertTrue(rAuth.firstname.length > 0);
    XCTAssertTrue(rAuth.lastname.length > 0);
    XCTAssertTrue(rAuth.id_user.length > 0);
    XCTAssertTrue(rAuth.passwordHash.length > 0);
    XCTAssertTrue(rAuth.regdate.length > 0);
    
    
    // Получаем данные о доставке
    [phApi getDeliveriesWithDelegate:nil orBlock:^(PHResponse *responce, NSError *error) {
        self.deliveryResponse = (ResponseGetDeliveries*)responce;
        
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        NSArray *allOrders = [coreShop getAllItemsWithNeedAddImages:YES];
        
        UploadImageManager *uploadManager = [[UploadImageManager alloc] initShopCartPrintDatas:allOrders];
        [uploadManager setDelegate:self];
        [uploadManager startUpload];
    }];
}


-(void)pHouseApi:(PHouseApi *)phApi didMakeOrderCompleteData:(PHResponse *)response {
    [self.expectation fulfill];
}

-(void)pHouseApi:(PHouseApi *)phApi didStoreItemsReceiveData:(PHResponse *)response {
    [self makeMugGlassPrintData];
}


-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error {
    XCTFail(@"Error: %@", error);
    [self.expectation fulfill];
}


@end
