//
//  PhotoHouseMakeOrderDesignAlbum.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 04/01/16.
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
#import "CoreDataSocialImages.h"

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


static CGFloat const TIMEOUT_DESIGNALBUM = 60.f;

typedef enum {
    ImagesTypePhoneLibrary,
    ImagesTypeSocial
} ImagesType;


@interface PhotoHouseMakeOrderDesignAlbum : XCTestCase<SaveImageManagerDelegate, PHouseApiDelegate, UploadImageManagerDelegate>
@property (nonatomic) XCTestExpectation *expectation;
@property (nonatomic) ResponseGetDeliveries *deliveryResponse;
@property (nonatomic) NSString *styleAlbum;
@property (nonatomic) NSString *sizeAlbum;
@property (nonatomic) NSString *coverAlbum;
@property (nonatomic) ImagesType imagesType;
@end

@implementation PhotoHouseMakeOrderDesignAlbum

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop removeAll];
    
    
    CoreDataSocialImages *coreSocial = [[CoreDataSocialImages alloc] init];
    [coreSocial removeAllImages];
}

- (void)tearDown {
    CoreDataSocialImages *coreSocial = [[CoreDataSocialImages alloc] init];
    [coreSocial removeAllImages];
    
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop removeAll];
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMakeOrderDesignAlbumWithPhootLibrary {
    // Wait
    XCTestExpectation *expectation = [self expectationWithDescription:@"Order"];
    self.expectation = expectation;
    
    self.imagesType = ImageLibraryPhone;
    
    // All Items
    PHouseApi *api = [[PHouseApi alloc] init];
    [api getAllItemsWithDelegate:self];
    
    //#warning ToDo: Local -> OnLine
    // SaveLocal
    //    BundleDefault *bDefault = [[BundleDefault alloc] init];
    //    NSData *dataItems = [bDefault defaultDataWithBundleName:BundleDefaultTypeAllItems];
    //    ResponseAlbumV2 *responseAlbum = [[ResponseAlbumV2 alloc] initWitParseData:[bDefault defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    //    ResponseGetItems *response;
    //    response = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbum.oldTemplates];
    //
    //    [self makeAlbum20x20UpOrientation];
    
    
    //
    [self waitForExpectationsWithTimeout:TIMEOUT_DESIGNALBUM handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}

- (void)testMakeOrderDesignAlbumWithSocialImages {
    // Wait
    XCTestExpectation *expectation = [self expectationWithDescription:@"Order"];
    self.expectation = expectation;
    
    self.imagesType = ImageLibrarySocial;
    
    // All Items
    PHouseApi *api = [[PHouseApi alloc] init];
    [api getAllItemsWithDelegate:self];
    
    //#warning ToDo: Local -> OnLine
    // SaveLocal
    //    BundleDefault *bDefault = [[BundleDefault alloc] init];
    //    NSData *dataItems = [bDefault defaultDataWithBundleName:BundleDefaultTypeAllItems];
    //    ResponseAlbumV2 *responseAlbum = [[ResponseAlbumV2 alloc] initWitParseData:[bDefault defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    //    ResponseGetItems *response;
    //    response = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbum.oldTemplates];
    //
    //    [self makeAlbum20x20UpOrientation];
    
    
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
    
    // Change Style
    PropStyle *style = storeItem.propType.selectPropStyle;
    for (PropStyle *curStyle in storeItem.propType.styles) {
        if (![curStyle.styleName isEqualToString:style.styleName]) {
            style = curStyle;
            break;
        }
    }
    self.styleAlbum = style.styleName;

    
    [self getImagesWithImportYype:self.imagesType withBlock:^(NSArray *printImages) {
        // Формируем PrintData
        PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
        [printData addPrintImagesFromPhotoLibrary:[printImages copy]];
        
        // Меняем значения
        // Change Size
        StoreItem *storeItem = printData.storeItem;
        PropSize *curSize = storeItem.propType.selectPropSize;
        for (PropSize *size in storeItem.propType.sizes) {
            if (![curSize.sizeName isEqualToString:size.sizeName]) {
                curSize = size;
                self.sizeAlbum = curSize.sizeName;
                break;
            }
        }
        
        // Change Cover
        PropCover *curCover = storeItem.propType.selectPropCover;
        for (PropCover *cover in storeItem.propType.covers) {
            if (![curCover.cover isEqualToString:cover.cover]) {
                curCover = cover;
                self.coverAlbum = curCover.cover;
                break;
            }
        }
        
        [printData changeProp:curCover];
        [printData changeProp:curSize];
        [printData changeProp:style];

        
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

- (void) getImagesWithImportYype:(ImagesType)imagesType withBlock:(void(^)(NSArray *printImages))completeBlock {
    if (imagesType == ImageLibraryPhone) {
        [self getImagesWithPhotoLibrary:completeBlock];
    } else {
        [self getImagesWithSocial:completeBlock];
    }
}


- (void) getImagesWithPhotoLibrary:(void(^)(NSArray *printImages))completeBlock {
    MDPhotoLibrary *pLibrary = [[MDPhotoLibrary alloc] init];
    
    CGSize imageSize = CGSizeMake(1600, 1200);
    NSUInteger assetCount = 5;//style.maxCount;
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
        
        if (completeBlock) {
            completeBlock(printImages);
        }
    }];
}

- (void) getImagesWithSocial:(void(^)(NSArray *printImages))completeBlock {
    ImportLibrary importLib = ImportLibraryInstagram;
    NSArray *urls = [NSArray arrayWithObjects:@"http://albumBack", @"http://squareImage", @"http://horizontalImage", @"http://style_shildren", @"http://run", nil];
    
    PhotoRecord *record1 = [[PhotoRecord alloc] initWithSocialURl:[urls objectAtIndex:0] withImage:[UIImage imageNamed:@"run1"] andImportLibrary:importLib];
    PhotoRecord *record2 = [[PhotoRecord alloc] initWithSocialURl:[urls objectAtIndex:1] withImage:[UIImage imageNamed:@"run2"] andImportLibrary:importLib];
    PhotoRecord *record3 = [[PhotoRecord alloc] initWithSocialURl:[urls objectAtIndex:2] withImage:[UIImage imageNamed:@"run3"] andImportLibrary:importLib];
    PhotoRecord *record4 = [[PhotoRecord alloc] initWithSocialURl:[urls objectAtIndex:3] withImage:[UIImage imageNamed:@"run4"] andImportLibrary:importLib];
    PhotoRecord *record5 = [[PhotoRecord alloc] initWithSocialURl:[urls objectAtIndex:4] withImage:[UIImage imageNamed:@"run5"] andImportLibrary:importLib];
    
    
    CoreDataSocialImages *social = [[CoreDataSocialImages alloc] init];
    [social savePhotoRecord:record1];
    [social savePhotoRecord:record2];
    [social savePhotoRecord:record3];
    [social savePhotoRecord:record4];
    [social savePhotoRecord:record5];

    
    // Массив [PrintImage]
    NSMutableArray *printImages = [NSMutableArray array];
    NSArray *savedrecord = [social getRecordWithNames:urls];
    XCTAssertEqual(savedrecord.count, urls.count);
    XCTAssertTrue(savedrecord.count > 0);
    
    for (PhotoRecord *rec in savedrecord) {
        XCTAssertNotNil(rec.image);
        XCTAssertNotNil(rec.name);
        XCTAssertTrue(rec.name.length > 0);
        XCTAssertTrue(rec.imageSize.width > 0);
        XCTAssertTrue(rec.imageSize.height > 0);
        
        PrintImage *pImage = [[PrintImage alloc] initWithPreviewImage:rec.image withName:rec.name andEditSetting:nil originalSize:rec.imageSize andUploadUrl:nil];
        [printImages addObject:pImage];
    }
    
    XCTAssertTrue(printImages.count > 0);
    
    if (completeBlock) {
        completeBlock(printImages);
    }
}




#pragma mark - Methods
- (void) readShopCart {
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    PrintData *saved = [[coreShop getAllItemsWithNeedAddImages:YES] firstObject];
    XCTAssertTrue(saved.storeItem.propType.sizes.count > 0);
    XCTAssertTrue(saved.props.allKeys.count > 0);
    
    XCTAssertEqualObjects(self.styleAlbum, saved.storeItem.propType.selectPropStyle.styleName);
    XCTAssertEqualObjects(self.coverAlbum, saved.storeItem.propType.selectPropCover.cover);
    XCTAssertEqualObjects(self.sizeAlbum, saved.storeItem.propType.selectPropSize.sizeName);
    
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
    NSString *comment = [NSString stringWithFormat:@"This order from UnitTest.\nAlbum Size: '%@'\nAlbum Cover: '%@'\nAlbum Style: '%@'", self.sizeAlbum, self.coverAlbum, self.styleAlbum];

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
    
    
    NSArray *pImages = printData.images;
    for (PrintImage *pImage in pImages) {
        XCTAssertTrue([pImage isKindOfClass:[PrintImage class]]);
        XCTAssertNotNil(pImage.urlLibrary);
        XCTAssertNotNil(pImage.iconPreviewImage);
        XCTAssertNotNil(pImage.previewImage);
        XCTAssertTrue(pImage.originalImageSize.width > 0.f);
        XCTAssertTrue(pImage.originalImageSize.height > 0.f);
        XCTAssertTrue(pImage.urlLibrary.length > 0);
        
//        [pImage.editedImageSetting changeFilter:@"CISepiaTone"];
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
    for (PrintImage *pImage in saved.images) {
        XCTAssertTrue([pImage isKindOfClass:[PrintImage class]]);
        XCTAssertNotNil(pImage.urlLibrary);
        XCTAssertNotNil(pImage.iconPreviewImage);
        XCTAssertNotNil(pImage.previewImage);
        XCTAssertTrue(pImage.originalImageSize.width > 0.f);
        XCTAssertTrue(pImage.originalImageSize.height > 0.f);
        XCTAssertTrue(pImage.urlLibrary.length > 0);
        
//        XCTAssertTrue([pImage.editedImageSetting.filterName isEqualToString:@"CISepiaTone"]);
    }

    
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
    [self makeAlbum20x20UpOrientation];
}


-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error {
    XCTFail(@"Error: %@", error);
    [self.expectation fulfill];
}


@end
