//
//  FilterImageManagerTest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/31/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "BundleDefault.h"
#import "ResponseGetItems.h"
#import "ResponseAlbumV2.h"

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
#import "EditImageSetting.h"
#import "FilterImageManager.h"

#import "MDPhotoLibrary.h"

static CGFloat const TIMEOUT_FILTER = 15.f;

@interface FilterImageManagerTest : XCTestCase <FilterImageManagerDelegate>
@property (nonatomic) XCTestExpectation *expectation;
@end

@implementation FilterImageManagerTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    BundleDefault *bDefault = [[BundleDefault alloc] init];
    NSData *dataItems = [bDefault defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseAlbumV2 *responseAlbum = [[ResponseAlbumV2 alloc] initWitParseData:[bDefault defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    ResponseGetItems *response;
    response = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbum.oldTemplates];
}

- (void)tearDown
{
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop removeAll];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testApplyImage
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Filter"];
    self.expectation = expectation;
    
    MDPhotoLibrary *lib = [[MDPhotoLibrary alloc] init];
    [lib loadPhotoALAssetsCount:1 withSize:CGSizeMake(600, 600) andOrientation:-1 withSuccessBlock:^(NSArray *assets, NSError *error) {
        ALAsset *asset = [assets firstObject];
        [self makePrintData:asset];
    }];
    
    [self waitForExpectationsWithTimeout:TIMEOUT_FILTER handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout: %@", error);
        }
    }];
}

- (void) makePrintData:(ALAsset *)asset {
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    NSString *categoryName = [coreStore getCategoryTitleWithCategoryID:StoreTypeSovenir];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"2"]) {
            storeItem = item;
        }
    }
    
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    EditImageSetting *setting = [[EditImageSetting alloc] initFilterName:@"CLDefaultInvertFilter"
                                                 andSaturation:DEFAULT_SATURATION
                                                 andBrightness:DEFAULT_BRIGHTNESS
                                                   andContrast:0.5f
                                                   andCropRect:CGRectZero
                                              andRectToVisible:CGRectZero
                                        andAutoResizingEnabled:YES
                                           andImageOrientation:UIImageOrientationUp andImageDefautlOrientation:UIImageOrientationUp];
        
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageWithCGImage:asset.thumbnail] withName:[asset.defaultRepresentation.url absoluteString] andEditSetting:setting originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:@[printImage]];
    
    // Здесть просто сохраняем, не используя SaveManeger
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop savePrintData:printData];
    [coreShop finalCompletePrintData:printData];
    
    // Читаем и проверяем
    PrintData *pData = [[coreShop getAllItemsWithNeedAddImages:YES] firstObject];
    PrintImage *pImage = [pData.images firstObject];
    XCTAssertEqualObjects(pImage.editedImageSetting.filterName, setting.filterName);
    XCTAssertEqual(pImage.editedImageSetting.contrastValue, setting.contrastValue);
    
    
    FilterImageManager *manager = [[FilterImageManager alloc] initWithPrintDataUnique:pData.unique_print andPrintImage:printImage andDelegate:self];
    [manager apply];
}

#pragma mark - FilterImageManagerDelegate
-(void)filterImageManager:(FilterImageManager *)manager didApplyImage:(PrintImage *)printImage {
    XCTAssertNotNil(printImage.urlLibrary);
    XCTAssertTrue(printImage.urlLibrary.length > 0);
    
    XCTAssertTrue(printImage.originalImageSize.width > 0);
    XCTAssertTrue(printImage.originalImageSize.height > 0);

    MDPhotoLibrary *lib = [[MDPhotoLibrary alloc] init];
    [lib getAssetWithURL:printImage.urlLibrary  withResultBlock:^(NSData *imageData, UIImageOrientation orientation) {
        UIImage *image = [UIImage imageWithData:imageData];
        XCTAssertNotNil(image);
        XCTAssertNotNil(imageData);
        XCTAssertTrue(image.size.width > 0);
        XCTAssertTrue(image.size.height > 0);
        [self.expectation fulfill];
        
    } failBlock:^(NSError *error) {
        XCTFail(@"Error: %@", error);
        [self.expectation fulfill];
    }];
    
    
}

@end
