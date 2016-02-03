//
//  CoreDataShoppingCartTiest.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/4/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CoreDataShopCart.h"
#import "CoreDataStore.h"
#import "CoreDataSocialImages.h"

#import "UIImage+Crop.h"
#import "UIImage+Merge.h"

#import "ResponseGetItems.h"
#import "ResponseAlbumV2.h"
#import "StoreItem.h"
#import "PropSize.h"
#import "PropType.h"
#import "PropStyle.h"

#import "PrintData.h"
#import "PrintImage.h"

#import "Template.h"
#import "Layout.h"
#import "Layer.h"
#import "Image.h"
#import "PlaceHolder.h"

#import "SaveImageManager.h"

#import "BundleDefault.h"

@interface CoreDataShoppingCartTiest : XCTestCase <SaveImageManagerDelegate>
@property (nonatomic) XCTestExpectation *expectation;
@property (nonatomic) Template *template;
@end



@implementation CoreDataShoppingCartTiest
{
    CoreDataShopCart *coreShop;
    CoreDataStore *coreStore;
    CoreDataSocialImages *coreSocial;
    ResponseGetItems *response;
    BundleDefault *bundle;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    coreStore = [[CoreDataStore alloc] init];
    coreShop = [[CoreDataShopCart alloc] init];
    coreSocial = [[CoreDataSocialImages alloc] init];
    
    [coreShop removeAll];
    
    bundle = [[BundleDefault alloc] init];
    NSData *dataItems = [bundle defaultDataWithBundleName:BundleDefaultTypeAllItems];
    ResponseAlbumV2 *responseAlbum = [[ResponseAlbumV2 alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    response = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbum.oldTemplates];

    
    
}

- (void)tearDown
{
    [coreStore clearStory];
    coreStore = nil;
    
    [coreShop removeAll];
    coreShop = nil;
    
    [coreSocial removeAllImages];
    coreSocial = nil;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSaveToShopCartAlbum
{
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    
    /*PrintImage *merge1 = [[PrintImage alloc] initMergeImage:[UIImage imageNamed:@"sectionInConstructor"] withName:@"merge1"];
    PrintImage *merge2 = [[PrintImage alloc] initMergeImage:[UIImage imageNamed:@"sectionInConstructor"] withName:@"merge2"];
    [printData addMergedImages:[NSArray arrayWithObjects:merge1, merge2, nil]];*/
    [printData createAndAddMergedImageWithPrintImage:printImage.previewImage];
    
    [coreShop savePrintData:printData];
    
    
    // Get
    NSArray *prints = [coreShop getAllItemsWithNeedAddImages:YES];
    XCTAssertFalse(prints.count == 0, @"Prints is Empty; %li", (unsigned long)prints.count);
    
    for (PrintData *print in prints) {
        XCTAssertTrue(print.purchaseID > 0, @"PurchaseId == %li",(long)printData.purchaseID);
        XCTAssertFalse(print.namePurchase.length == 0, @"namePurchase is Empty");
        XCTAssertFalse([print count] == 0, @"Count == %lu", (unsigned long)printData.count);
        XCTAssertFalse([print price] == 0, @"Price == %li", (long)printData.price);
        XCTAssertNotNil([print iconShopCart], @"Icon image nil: ID: %li", (long)printData.purchaseID);
        
        //Images
        // Картинок нет, т.к перенесены в отдельный метод, для ускорения быстродействия
        /*XCTAssertFalse(print.images.count == 0, @"Images is Empty; %li", (unsigned long)print.images.count);
        for (id object in print.images) {
            XCTAssertTrue([object isKindOfClass:[PrintImage class]], @"Do not PrintImage Class");
        }
        
        for (PrintImage *image in print.images) {
            if (image.isMergedImage) {
                XCTAssertNotNil(image.previewImage, @"Icon image nil:");
            }
            XCTAssertFalse(image.urlLibrary.length == 0, @"empty: %@", image.urlLibrary);
            
            XCTAssertNotNil(image.editedImageSetting, @"Setting image nil:");
            XCTAssertFalse(image.editedImageSetting.filterName.length == 0, @"Filter Empty");
        }*/
    }
}



- (void) testUpdateSettingWithAlbums
{
    
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    NSString *filter1 = @"filter1";
    NSString *filter2 = @"filter2";
    CGFloat saturation1 = 0.5f;
    CGFloat saturation2 = 0.7f;
    EditImageSetting *setting = [[EditImageSetting alloc] initFilterName:filter1
                                                           andSaturation:saturation1
                                                           andBrightness:DEFAULT_BRIGHTNESS
                                                             andContrast:DEFAULT_CONSTRAST
                                                             andCropRect:CGRectZero
                                                        andRectToVisible:CGRectZero
                                                  andAutoResizingEnabled:YES
                                                     andImageOrientation:UIImageOrientationUp andImageDefautlOrientation:UIImageOrientationUp];
    PrintImage *printImage1 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo" andEditSetting:setting originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *printImage2 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo2" andEditSetting:setting originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObjects:printImage1, printImage2, nil]];
    
    
    [coreShop savePrintData:printData];
    
    
    // Change
    PrintImage *chooseImage = [printData.imagesPreview firstObject];
    NSString *cutterName = chooseImage.urlLibrary;
    EditImageSetting *chooseSetting = chooseImage.editedImageSetting;
    [chooseSetting changeFilter:filter2];
    [chooseSetting changeSaturation:saturation2];
    
    
    [coreShop updateAfterEditorPrintData:printData andPrintImage:chooseImage];
    
    
    //Result
    NSArray *resultPrints = [coreShop getAllItemsWithNeedAddImages:YES];
    PrintData *resultPrintData = [coreShop getItemImagesWithPrintData:[resultPrints firstObject]];
    PrintImage *resultImage;
    for (PrintImage *img in resultPrintData.imagesPreview) {
        if ([img.urlLibrary isEqualToString:cutterName]) {
            resultImage = img;
        }
    }
    EditImageSetting *resultSetting = resultImage.editedImageSetting;
    
    XCTAssertTrue(resultPrints.count == 1, @"ResultPrints: %li", (unsigned long)resultPrints.count);
    XCTAssertTrue([resultSetting.filterName isEqualToString:filter2], @"Filter Dont Change: %@ - %@", resultSetting.filterName, filter2);
    XCTAssertTrue(resultSetting.saturationValue == saturation2, @"Saturaton Dont Change");
}



- (void) testUpdateSettingWithMug
{
    NSString *const categoryName = @"Сувениры и подарки";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"2"]) {
            storeItem = item;
        }
    }
    
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    NSString *filter1 = @"filter1";
    NSString *filter2 = @"filter2";
    CGFloat saturation1 = 0.5f;
    CGFloat saturation2 = 0.7f;
    EditImageSetting *setting = [[EditImageSetting alloc] initFilterName:filter1
                                                           andSaturation:saturation1
                                                           andBrightness:DEFAULT_BRIGHTNESS
                                                             andContrast:DEFAULT_CONSTRAST
                                                             andCropRect:CGRectZero
                                                        andRectToVisible:CGRectZero
                                                  andAutoResizingEnabled:YES
                                                     andImageOrientation:UIImageOrientationUp andImageDefautlOrientation:UIImageOrientationUp];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo" andEditSetting:setting originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    
    //PrintImage *merge1 = [[PrintImage alloc] initMergeImage:[UIImage imageNamed:@"sectionInConstructor"] withName:@"merge1"];
    //PrintImage *merge2 = [[PrintImage alloc] initMergeImage:[UIImage imageNamed:@"sectionInConstructor"] withName:@"merge2"];
    //[printData addMergedImages:[NSArray arrayWithObjects:merge1, merge2, nil]];
    //[printData createAndAddMergedImageWithPrintImage:printImage.previewImage];
    
    [coreShop savePrintData:printData];

    
    // Change
    PrintImage *chooseImage = [printData.imagesPreview firstObject];
    NSString *cutterName = chooseImage.urlLibrary;
    EditImageSetting *chooseSetting = chooseImage.editedImageSetting;
    [chooseSetting changeFilter:filter2];
    [chooseSetting changeSaturation:saturation2];
    
    
    [coreShop updateAfterEditorPrintData:printData andPrintImage:nil];
    
    
    //Result
    NSArray *resultPrints = [coreShop getAllItemsWithNeedAddImages:YES];
    PrintData *resultPrintData = [coreShop getItemImagesWithPrintData:[resultPrints firstObject]];
    PrintImage *resultImage;
    for (PrintImage *img in resultPrintData.imagesPreview) {
        if ([img.urlLibrary isEqualToString:cutterName]) {
            resultImage = img;
        }
    }
    EditImageSetting *resultSetting = resultImage.editedImageSetting;
    
    XCTAssertTrue(resultPrints.count == 1, @"ResultPrints: %li", (unsigned long)resultPrints.count);
    XCTAssertTrue([resultSetting.filterName isEqualToString:filter2], @"Filter Dont Change: %@ - %@", resultSetting.filterName, filter2);
    XCTAssertTrue(resultSetting.saturationValue == saturation2, @"Saturaton Dont Change");
}




- (void) testGetItemImagesWithPrintData
{
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    [printData createAndAddMergedImageWithPrintImage:printImage.previewImage];
    
    
    [coreShop savePrintData:printData];
    [coreShop finalCompletePrintData:printData];
    
    // Get
    NSArray *prints = [coreShop getAllItemsWithNeedAddImages:YES];
    XCTAssertFalse(prints.count == 0, @"Prints is Empty; %li", (unsigned long)prints.count);
    
    PrintData *print = [prints firstObject];
    XCTAssertNotNil(print, @"PrintData == nil");
    
    print = [coreShop getItemImagesWithPrintData:print];
    XCTAssertNotNil(print, @"PrintData == nil");
    
    
    XCTAssertTrue(print.purchaseID > 0, @"PurchaseId == %li",(long)printData.purchaseID);
    XCTAssertFalse(print.namePurchase.length == 0, @"namePurchase is Empty");
    XCTAssertFalse([print count] == 0, @"Count == %lu", (unsigned long)printData.count);
    XCTAssertFalse([print price] == 0, @"Price == %li", (long)printData.price);
    XCTAssertNotNil([print iconShopCart], @"Icon image nil: ID: %li", (long)printData.purchaseID);
    
    //Images
    XCTAssertFalse(print.images.count == 0, @"Images is Empty; %li", (unsigned long)print.images.count);
    for (id object in print.images) {
        XCTAssertTrue([object isKindOfClass:[PrintImage class]], @"Do not PrintImage Class");
    }
    
    for (PrintImage *image in print.images) {
        if (image.isMergedImage) {
            XCTAssertNotNil(image.previewImage, @"Icon image nil:");
        }
        XCTAssertFalse(image.urlLibrary.length == 0, @"empty: %@", image.urlLibrary);
        
        XCTAssertNotNil(image.editedImageSetting, @"Setting image nil:");
        XCTAssertFalse(image.editedImageSetting.filterName.length == 0, @"Filter Empty");
    }
}



- (void) testSaveImagesAndAddNewImagesWithPrintData
{
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage1 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"albumBack"] withName:@"http://albumBack" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *printImage2 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"squareImage"] withName:@"http://squareImage" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObjects:printImage1, printImage2, nil]];
    
    [coreShop savePrintData:printData];
    
    //
    PrintData *unsavedPrintData = [coreShop getUnSavedPrintData];
    XCTAssertTrue(unsavedPrintData.imagesPreview.count == 2, @"Images != 2");
    
    PrintImage *printImage3 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage3]];
    XCTAssertTrue(printData.imagesPreview.count == 3, @"PrintData.Images != 3");
}



- (void) testResavedPrintData
{
    NSInteger unique1 = 12345;
    NSInteger unique2 = 67890;
    NSInteger unique3 = 45678;
    
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    XCTAssertTrue([coreShop getAllItemsWithNeedAddImages:YES].count == 0, @"Prints not Empty");
    
    PrintData *printData1 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique1];
    PrintData *printData2 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique2];
    PrintData *printData3 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique3];
    
    [coreShop savePrintData:printData1];
    [coreShop finalCompletePrintData:printData1];
    [coreShop savePrintData:printData2];
    [coreShop savePrintData:printData3];
    
    NSArray *prints = [coreShop getAllItemsWithNeedAddImages:YES];
    XCTAssertFalse(prints.count == 0, @"Prints is Empty: %li", (unsigned long)prints.count);
    
    NSArray *printsArr = [coreShop getAllItemsWithNeedAddImages:YES];
    XCTAssertTrue(printsArr.count == 2, @"PrintsCount: %li", (unsigned long)printsArr.count);
}





- (void) testChangeCount
{
    NSString *const categoryName = @"Сувениры и подарки";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"2"]) {
            storeItem = item;
        }
    }
    
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    [printData createAndAddMergedImageWithPrintImage:printImage.previewImage];
    
    [coreShop savePrintData:printData];
    [coreShop finalCompletePrintData:nil];

    NSArray *prints = [coreShop getAllItemsWithNeedAddImages:YES];
    XCTAssertTrue(prints.count == 1, @"Prints: %li", (long)prints.count);
    
    
    
    PrintData *pData = [prints firstObject];
    [pData changeCount:2];
    [coreShop updateCountPrintData:pData];
    
    
    
    prints = [coreShop getAllItemsWithNeedAddImages:YES];
    PrintData *final = [prints firstObject];
    XCTAssertTrue(prints.count == 1, @"Prints: %li", (long)prints.count);
    XCTAssertTrue(final.count == 2, @"Count: %li", (long)final.count);
}




- (void) testChangePropsSizeTShirt
{
    NSString *const categoryName = @"Сувениры и подарки";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"2"]) {
            storeItem = item;
        }
    }
    
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    [printData createAndAddMergedImageWithPrintImage:printImage.previewImage];
    
    // Save To Cart
    [coreShop savePrintData:printData];

    
    // Change Size
    // Текущий размер
    PropSize *curSize = storeItem.propType.selectPropSize;
    for (PropSize *size in storeItem.propType.sizes) {
        if (![curSize.sizeName isEqualToString:size.sizeName]) {
            curSize = size;
            break;
        }
    }
    
    
    // Update props
    // Обновляем размер
    [printData changeProp:curSize];
    [coreShop updateTemplateOrPropsPrintData:printData];
    [coreShop finalCompletePrintData:printData];
    
    
    // Items
    PrintData *saved = [[coreShop getAllItemsWithNeedAddImages:NO] firstObject];
    XCTAssertTrue(saved.storeItem.propType.sizes.count > 0);
    XCTAssertTrue(saved.props.allKeys.count > 0);
    
    PropSize *savedSize = saved.storeItem.propType.selectPropSize;
    XCTAssertTrue([savedSize.sizeName isEqualToString:curSize.sizeName], @"Size %@ != %@", savedSize.sizeName, curSize.sizeName);
}




- (void) testGetTypesWithPurchaseId
{
    NSArray *propTypes = [coreStore getTypesWithPurchaseID:@"2"];
    XCTAssertTrue(propTypes.count > 0);
    
    for (PropType *pType in propTypes) {
        XCTAssertTrue(pType.sizes.count > 0);
    }
}





- (void) testSaveLargeImagesSocial
{
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    // Save Social
    NSString *urlLibrary = @"http://url1";
    UIImage *image = [UIImage imageNamed:@"run1"];
    NSInteger library = 4;
    [coreSocial saveImage:image withURL:urlLibrary andLibraryType:(ImportLibrary)library];
    
    
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:image withName:urlLibrary andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    
    [coreShop savePrintData:printData];
    [coreShop saveOriginalImagePrintDataUnique:printData.unique_print andPrintImage:printImage andSocialImageData:[coreSocial getImageDataWithURL:urlLibrary]];
    //[coreShop finalCompletePrintData:printData];
    
    
    NSArray *prints = [coreShop getAllItemsWithNeedAddImages:YES];
    XCTAssertTrue(prints.count == 1, @"Prints is Empty: %li", (unsigned long)prints.count);
    
    
    PrintData *print = [coreShop getItemImagesWithPrintData:[prints firstObject]];
    XCTAssertTrue(print.imagesPreview.count == 1, @"Images is Empty: %li", (unsigned long)print.imagesPreview.count);
    
    for (PrintImage *image in print.imagesPreview) {
        XCTAssertNotNil(image.previewImage, @"Image not nil");
        
        EditImageSetting *editSetting = image.editedImageSetting;
        XCTAssertFalse(CGRectEqualToRect(CGRectZero, editSetting.cropRect), @"Rect Equal");
    }
    
    
    
    PrintImage *originalPrintImage = [coreShop saveOriginalImagePrintDataUnique:printData.unique_print
                                                                  andPrintImage:printImage
                                                             andSocialImageData:[coreSocial getImageDataWithURL:urlLibrary]];
    XCTAssertNotNil(originalPrintImage.previewImage, @"Image Preview nil");
    XCTAssertNotNil(originalPrintImage.iconPreviewImage, @"Image icon nil");
    XCTAssertTrue(CGSizeEqualToSize(CGSizeMake(50, 50), originalPrintImage.iconPreviewImage.size), @"Size not Equal");
}




- (void) testSavePrintImageURLLibrary
{
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    // Save Social
    NSString *urlLibrary = @"http://url1";
    UIImage *image = [UIImage imageNamed:@"style_children"];
    
    
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:image withName:urlLibrary andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    
    [coreShop savePrintData:printData];
    [coreShop finalCompletePrintData:printData];

    
    // Compare
    PrintImage *pImage = [printData.images firstObject];
    XCTAssertEqualObjects(pImage.urlLibrary, urlLibrary);
    
    // Update
    NSString *newUrlLibrary = @"Url2";
    [pImage updateUrlLibrary:newUrlLibrary andImageLibrary:ImageLibrarySocial withPrintDataUnique:printData.unique_print];
    
    PrintData *pData = [[coreShop getAllItemsWithNeedAddImages:YES] firstObject];
    PrintImage *pImg = [pData.images firstObject];
    XCTAssertEqualObjects(pImg.urlLibrary, newUrlLibrary);
}




- (void) testSaveUploadServerURL
{
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    // Save Social
    NSString *urlLibrary = @"http://url1";
    UIImage *image = [UIImage imageNamed:@"style_children"];
    
    
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:image withName:urlLibrary andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    
    [coreShop savePrintData:printData];
    [coreShop saveOriginalImagePrintDataUnique:printData.unique_print andPrintImage:printImage andSocialImageData:UIImagePNGRepresentation(printImage.previewImage)];
    [coreShop finalCompletePrintData:printData];

    NSString *uploadUrl = @"http://www.ph.info";
    [printImage updateUploadUrl:uploadUrl withPrintDataUnique:printData.unique_print];
    
    //All Items
    NSArray *prints = [coreShop getAllItemsWithNeedAddImages:YES];
    XCTAssertTrue(prints.count == 1, @"Prints is Empty: %li", (unsigned long)prints.count);
    
    
    PrintData *print = [coreShop getItemImagesWithPrintData:[prints firstObject]];
    XCTAssertTrue(print.imagesPreview.count == 1, @"Images is Empty: %li", (unsigned long)print.imagesPreview.count);
    
    for (PrintImage *image in print.imagesPreview) {
        XCTAssertFalse(image.uploadURL.absoluteString.length == 0, @"URL == Nil");
    }
}




- (void) testGetUnSavedPrintData
{
    NSInteger unique1 = 12345;
    NSInteger unique2 = 67890;
    
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    PrintData *printData1 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique1];
    PrintData *printData2 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique2];
    
    [coreShop savePrintData:printData1];
    [coreShop finalCompletePrintData:printData1];
    [coreShop savePrintData:printData2];
    //[coreShop finalCompletePrintData:printData2];
    
    PrintData *unsavedPrintData = [coreShop getUnSavedPrintData];
    XCTAssertNotNil(unsavedPrintData, @"PrintData is Nil");
    XCTAssertTrue(unsavedPrintData.storeItem.propType.sizes.count > 1);
    XCTAssertTrue(unsavedPrintData.storeItem.propType.covers.count > 1);
}


- (void) testGetSavedAllPrintData
{
    NSInteger unique1 = 12345;
    NSInteger unique2 = 67890;
    
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    PrintData *printData1 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique1];
    PrintData *printData2 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique2];
    
    [coreShop savePrintData:printData1];
    [coreShop finalCompletePrintData:printData1];
    [coreShop savePrintData:printData2];
    [coreShop finalCompletePrintData:printData2];
    
    PrintData *unsavedPrintData = [coreShop getUnSavedPrintData];
    XCTAssertNil(unsavedPrintData, @"PrintData Not Nil");
}





- (void) testGetPreviewImageForEditorWithEmptyPrintData
{
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    UIImage *image = [UIImage imageNamed:@"run1"];
    image = [image scaledImageToSize:CGSizeMake(2000, image.size.height / image.size.width * 2000)];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:image withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    
    // Prepare To Add Cart
    [coreShop savePrintData:printData];
    
    // ApplyFilter
    CIImage *ciimage = image.CIImage;
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
    [filter setValue:ciimage forKey:kCIInputImageKey];
    
    CIImage *result = [filter outputImage];
    UIImage *final = [UIImage imageWithCIImage:result];
    [printImage updatePreviewImage:final];
    
    PrintImage *finalImage = [coreShop getPreviewImageWithPrintDataUnique:printData.unique_print andPrintImage:printImage];
    XCTAssertNotNil(finalImage.previewImage, @"Image Nil");
}





- (void) testGetPreviewImageForEditorWithPrintData
{
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    UIImage *image = [UIImage imageNamed:@"run1"];
    image = [image scaledImageToSize:CGSizeMake(2000, image.size.height / image.size.width * 2000)];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:image withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    
    // Prepare To Add Cart
    [coreShop savePrintData:printData];
    
    // ApplyFilter
    CIImage *ciimage = image.CIImage;
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
    [filter setValue:ciimage forKey:kCIInputImageKey];
    
    CIImage *result = [filter outputImage];
    [printImage updatePreviewImage:[UIImage imageWithCIImage:result]];
    
    PrintImage *finalImage = [coreShop getPreviewImageWithPrintDataUnique:printData.unique_print andPrintImage:printImage];
    XCTAssertNotNil(finalImage.previewImage, @"Image Nil");
}






- (void) testSavedMerged
{
    NSString *const categoryName = @"Сувениры и подарки";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"2"]) {
            storeItem = item;
        }
    }
    
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    [coreShop savePrintData:printData];
    
    // Cerate And Merge And Save
    [printData createAndAddMergedImageWithPrintImage:printImage.previewImage];
    
    // Unsaved
    PrintData *unsavedPrintData = [coreShop getUnSavedPrintData];
    XCTAssertTrue(unsavedPrintData.mergedImages.count == 1, @"Prints is Empty: %li", (unsigned long)unsavedPrintData.mergedImages.count);
    XCTAssertTrue(unsavedPrintData.imagesPreview.count == 1, @"Prints is Empty: %li", (unsigned long)unsavedPrintData.imagesPreview.count);

    for (PrintImage *image in unsavedPrintData.mergedImages) {
        XCTAssertNotNil(image.previewImage, @"Merge image nil:");
    }
}



- (void) testGetUnSavedImagesUnsavedPrintData
{
    NSString *const categoryName = @"Сувениры и подарки";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"2"]) {
            storeItem = item;
        }
    }
    
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    [printData createMergedImageWithPreview:printImage.previewImage andCompleteBlock:nil andProgressBlock:nil];
    
    [coreShop savePrintData:printData];
    //[coreShop finalCompletePrintData:nil];
    
    NSArray *imageNames = [coreShop getUnsavedURLNamesPrintData:printData.unique_print];
    XCTAssertFalse(imageNames.count == 0, @"Image Empty");
}


- (void) testGetUnSavedImagesActivePrintData
{
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"] && [item.propType.name isEqualToString:TypeNameConstructor]) {
            storeItem = item;
        }
    }
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage1 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"albumBack"] withName:@"http://albumBack" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *printImage2 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"squareImage"] withName:@"http://squareImage" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *printImage3 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"horizontalImage"] withName:@"http://horizontalImage" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *printImage4 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"style_children"] withName:@"http://style_shildren" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObjects:printImage1, printImage2, printImage3, printImage4, nil]];
    
    [coreShop savePrintData:printData];
    
    
    NSArray *unsavedUrls = [coreShop getUnsavedURLNamesPrintData:0];
    XCTAssertTrue(unsavedUrls.count > 0, @"Count: %li", (long)unsavedUrls.count);
}



- (void) testGetUnSavedImagesSavedPrintData
{
    NSString *const categoryName = @"Сувениры и подарки";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"2"]) {
            storeItem = item;
        }
    }
    
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    //[printData createMergedImageWithPreview:printImage.previewImage andCompleteBlock:nil];
    
    [coreShop savePrintData:printData];
    [coreShop finalCompletePrintData:nil];
    
    NSArray *imageNames = [coreShop getUnsavedURLNamesPrintData:printData.unique_print];
    XCTAssertFalse(imageNames.count == 0, @"Image Empty");
}




// В процессе сохранения возникли трудности, пробуем пересохранить, использую CoreDataShopCart removeImage
- (void) testErrorSaveAndResaveAlbumDesign
{
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"] && [item.propType.name isEqualToString:TypeNameDesign]) {
            storeItem = item;
        }
    }
    
    // Create
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage1 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"albumBack"] withName:@"http://albumBack" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *printImage2 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"squareImage"] withName:@"http://squareImage" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *printImage3 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"horizontalImage"] withName:@"http://horizontalImage" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *printImage4 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"style_children"] withName:@"http://style_shildren" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObjects:printImage1, printImage2, printImage3, printImage4, nil]];
    
    // Save
    [coreShop savePrintData:printData];


    
    PrintData *unsaved = [coreShop getUnSavedPrintData];
    XCTAssertTrue(unsaved.imagesPreview.count == 4);
    XCTAssertTrue(printData.imagesPreview.count == 4);
    
    // Удаляем 3 и 4, т.к они не сохранились(Теоретически)
    NSArray *removeUrls = @[@"http://horizontalImage", @"http://style_shildren"];
    [coreShop removeImages:removeUrls];
    [printData removeImagesWithUrls:removeUrls];
    
    // Read Unsaved
    unsaved = [coreShop getUnSavedPrintData];
    XCTAssertTrue(unsaved.imagesPreview.count == 2);
    XCTAssertTrue(printData.imagesPreview.count == 2);
}





- (void) testRemoveShopCartByUnique
{
    NSInteger unique1 = 12345;
    NSInteger unique2 = 67890;
    NSInteger unique3 = 45678;
    
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
//    XCTAssertTrue([coreShop getAllItemsWithNeedAddImages:YES].count == 0, @"Prints not Empty");
    
    PrintData *printData1 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique1];
    PrintData *printData2 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique2];
    PrintData *printData3 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique3];
    
    [coreShop savePrintData:printData1];
    [coreShop finalCompletePrintData:printData1];
    
    [coreShop savePrintData:printData2];
    [coreShop finalCompletePrintData:printData2];
    
    [coreShop savePrintData:printData3];
    [coreShop finalCompletePrintData:printData3];
    
    
    NSArray *prints = [coreShop getAllItemsWithNeedAddImages:YES];
    XCTAssertFalse(prints.count == 0, @"Prints is Empty: %li", (unsigned long)prints.count);
    
    // Remove
    [coreShop removeFromShopCartUnique:printData2.unique_print withBlock:nil];
    
    
    NSArray *printsArr = [coreShop getAllItemsWithNeedAddImages:YES];
    XCTAssertTrue(printsArr.count == 2, @"PrintsCount: %li", (unsigned long)printsArr.count);
}


- (void) testRemoveUnsavedShopCartByUnique
{
    NSInteger unique1 = 12345;
    
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    XCTAssertTrue([coreShop getAllItemsWithNeedAddImages:YES].count == 0, @"Prints not Empty");
    
    PrintData *printData1 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique1];
    
    [coreShop savePrintData:printData1];
    [coreShop removeFromShopCartUnique:unique1 withBlock:nil];
    
    PrintData *unsaved = [coreShop getUnSavedPrintData];
    XCTAssertNil(unsaved, @"print no not remove");
}


- (void) testRemoveAll
{
    NSInteger unique1 = 12345;
    NSInteger unique2 = 67890;
    
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    PrintData *printData1 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique1];
    PrintData *printData2 = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:unique2];
    
    [coreShop savePrintData:printData1];
    [coreShop finalCompletePrintData:printData1];
    [coreShop savePrintData:printData2];
    [coreShop finalCompletePrintData:printData2];
    
    NSArray *prints = [coreShop getAllItemsWithNeedAddImages:YES];
    XCTAssertFalse(prints.count == 0, @"Prints is Empty: %li", (unsigned long)prints.count);
    
    [coreShop removeAll];
    prints = [coreShop getAllItemsWithNeedAddImages:YES];
    XCTAssertTrue(prints.count == 0, @"Prints is Empty: %li", (unsigned long)prints.count);

}



#pragma mark - Templates
- (void) testGetOrderLayoutsDictionaryArray
{
    NSString *templateSize = @"20x15";
    NSString *templateName = @"pink_checkered";
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];
    NSArray *arrayDictionary = [originalTemplate getUserLayoutsDictionaries];
    XCTAssertFalse(arrayDictionary.count == 0, @"Dictionary Empty");
}


- (void) testGetOrderTemplateDictionary
{
    NSString *templateSize = @"20x15";
    NSString *templateName = @"pink_checkered";
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];
    NSDictionary *userTemplateDictionary = [originalTemplate getUserTemplateDictionary];
    NSLog(@"Dict: %@", userTemplateDictionary);
    XCTAssertFalse(userTemplateDictionary.allKeys.count == 0, @"Dictionary Empty");
}



- (void) testSaveUserTemplate20x15InPrintData
{
    // Template
    NSString *templateSize = @"20x15";
    NSString *templateName = @"pink_checkered";
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];

    
    /// Блок создания по характеристикам старого Layout
    Layout* (^LayoutBlock)(NSUInteger, NSArray *layouts) = ^(NSUInteger countImages, NSArray *layouts) {
        Layout *layout;
        
        for (Layout *lt in layouts) {
            if (lt.backLayer.images.count == countImages) {
                
                NSMutableArray *imageBack = [NSMutableArray array];
                for (Image *image in lt.backLayer.images) {
                    Image *ig = [[Image alloc] initWithPixelsMin:image.pixelsMin
                                                  andPixelsLimit:image.pixelsLimit
                                                            andZ:image.z
                                                     andUrlImage:image.url_image
                                                    andUrlUpload:image.url_upload
                                                    andPermanent:image.permanent
                                                         andRect:image.rect
                                                         andCrop:image.crop
                                                        andImage:image.image andImageOrientation:UIImageOrientationUp andImageOrientationDefault:UIImageOrientationUp];
                    [imageBack addObject:ig];
                }
               
                Layer *layerBack = [[Layer alloc] initWithImage:lt.backLayer.image andImages:[imageBack copy]];
                Layer *layerFront = [[Layer alloc] initWithImage:lt.frontLayer.image andImages:nil];
                Layer *layerClear = [[Layer alloc] initWithImage:lt.clearLayer.image andImages:nil];
                Layout *lts = [[Layout alloc] initLayoutWithID:lt.id_layout
                                                andLayoutType:lt.layoutType
                                               andtemplatePSD:lt.template_psd
                                                 andBackLayer:layerBack
                                                andFlontLayer:layerFront
                                                andClearLayer:layerClear
                                                 andPageIndex:lt.pageIndex
                                             andCombinedLayer:lt.combinedLayer
                                      andNoscaleCombinedLayer:lt.noscaleCombinedLayer];
                layout = lts;
            }
        }
        
        return layout;
    };
    
    
    
    /// Блок установки картинок в Layout
    Layout* (^InserImageInLayout)(NSArray *images, Layout *layout) = ^(NSArray *images, Layout *layout) {
        for (int i=0;i<images.count; i++) {
            Image *frameImage = [layout.backLayer.images objectAtIndex:i];
            PrintImage *printImage = [images objectAtIndex:i];
            [frameImage updateImage:printImage.previewImage];
            [frameImage updateUrlImage:printImage.urlLibrary];
        }
        
        return layout;
    };
    
    
    
    PrintImage *image1 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run1"] withName:@"ru1" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image2 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run2"] withName:@"ru2" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image3 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run3"] withName:@"ru3" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image4 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run4"] withName:@"ru4" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image5 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run5"] withName:@"ru5" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image6 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run6"] withName:@"ru6" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image7 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run7"] withName:@"ru7" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image8 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run8"] withName:@"ru8" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image9 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run9"] withName:@"ru9" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    
    Layout *l1 = LayoutBlock(4, originalTemplate.layouts);
    Layout *l2 = LayoutBlock(4, originalTemplate.layouts);
    [l1 updatePageIndex:1];
    [l2 updatePageIndex:2];
    
    NSArray *layouts = @[l1, l2];
    XCTAssertTrue(layouts.count > 0);
    
    Layout* layout1 = InserImageInLayout(@[image1, image2, image3, image4], [layouts objectAtIndex:0]);
    Layout* layout2 = InserImageInLayout(@[image5, image6, image7, image8], [layouts objectAtIndex:1]);
    NSString *idLayout = layout1.id_layout;
    
    layouts = @[layout1, layout2];
    
    

    
    Template *userTemplate = [[Template alloc] initTemplateName:originalTemplate.name
                                                    andFontName:originalTemplate.fontName
                                                  andIdTemplate:originalTemplate.id_template
                                                        andSize:originalTemplate.size
                                                     andLayouts:layouts];
    
    
    // PrintData
    NSString *const categoryName = @"Альбомы";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    [printData addPrintImagesFromPhotoLibrary:@[image1, image2, image3, image4, image5, image6, image7, image8, image9]];
    [printData updateUserTemplate:userTemplate];
    
    [coreShop savePrintData:printData];
    
    
    
    /// Блок проверки соответсвия текущего названия картинки со всеми картинками, Yes - совпадение найдено(Хорошо), No - сопадений не найдено (Плохо)
    BOOL(^SearchImageInLayoutBlock)(NSString *urlLib, NSArray *layouts) = ^(NSString *urlLib, NSArray *layouts) {
        BOOL result = NO;
        
        for (Layout *layout in layouts) {
            for (Image *img in layout.backLayer.images) {
                if ([img.url_image isEqualToString:urlLib]) {
                    result = YES;
                }
            }
        }
        
        return result;
    };
    
    
    
    // Read
    PrintData *unsavedPrinData = [coreShop getUnSavedPrintData];
    Template *unsavedTemplate = unsavedPrinData.storeItem.propType.userTemplate;
    XCTAssertNotNil(unsavedTemplate, @"Template is Nil");
    XCTAssertFalse(unsavedTemplate.name.length == 0, @"Name is Empty: %@", unsavedTemplate.name);
    XCTAssertFalse(unsavedTemplate.fontName.length == 0, @"Font is Empty: %@", unsavedTemplate.fontName);
    XCTAssertFalse(unsavedTemplate.id_template.length == 0, @"ID is Empty: %@", unsavedTemplate.id_template);
    XCTAssertFalse(unsavedTemplate.layouts.count == 0, @"Layouts Empty");
    XCTAssertFalse(unsavedTemplate.size.length == 0, @"Size Empty");
    
    XCTAssertTrue(unsavedTemplate.layouts.count == 2);
    XCTAssertTrue([unsavedTemplate.name isEqualToString:templateName]);
    XCTAssertTrue([unsavedTemplate.size isEqualToString:templateSize]);
    
    for (Layout *layout in unsavedTemplate.layouts) {
        XCTAssertTrue([layout.id_layout isEqualToString:idLayout]);
        XCTAssertFalse(layout.id_layout.length == 0);
        XCTAssertFalse(layout.template_psd.length == 0);
        XCTAssertFalse(layout.layoutType.length == 0);
        XCTAssertFalse(layout.pageIndex == 0);
        // NoscaleCombined
        XCTAssertTrue(CGRectGetWidth(layout.noscaleCombinedLayer) > 0, @"Layout %@", layout.id_layout);
        XCTAssertTrue(CGRectGetHeight(layout.noscaleCombinedLayer) > 0, @"Layout %@", layout.id_layout);
        
        // PlaceHolder
        PlaceHolder *pHolder = layout.combinedLayer;
        XCTAssertTrue(pHolder.psdPath.length > 0, @"Layout %@", layout.id_layout);
        XCTAssertTrue(pHolder.layerNum.length > 0, @"Layout %@", layout.id_layout);
        XCTAssertTrue(pHolder.pngPath.length > 0, @"Layout %@", layout.id_layout);
        XCTAssertTrue(CGRectGetWidth(pHolder.rect) > 0, @"Layout %@", layout.id_layout);
        XCTAssertTrue(CGRectGetHeight(pHolder.rect) > 0, @"Layout %@", layout.id_layout);
        
        // *******
        // Back
        Layer *backLayer = layout.backLayer;
        XCTAssertNotNil(backLayer.image);
//        XCTAssertFalse(backLayer.images.count == 0, @"Images Empty");
        
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
            
            XCTAssertTrue(SearchImageInLayoutBlock(image.url_image, unsavedTemplate.layouts), @"Image: %@", image.url_image);
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



- (void) testUserTemplateDownloadAndAddImages {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationTemplateDownloadComplete:) name:TemplateDownloadComplateNotification object:nil];   // Успешно загруженны верска шаблона
    [nc addObserver:self selector:@selector(notificationTemplateProgressComplete:) name:TemplateDownloadProgressNotification object:nil];   // Прогресс загрузки верски
    [nc addObserver:self selector:@selector(notificationTemplateDownloadError:) name:TemplateDownloadErrorNotification object:nil];         // Ошибка загрузки верски
    
    
    // Template
    NSString *templateSize = @"20x15";
    NSString *templateName = @"pink_checkered";
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];
    
    
    
    [originalTemplate downloadImages];
    
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"template"];
    self.expectation = expectation;
    [self waitForExpectationsWithTimeout:170 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Timeout");
        }
    }];
}


#pragma mark - Notification
- (void) notificationTemplateDownloadComplete:(NSNotification *)notification
{
    // Remove Notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:TemplateDownloadComplateNotification object:nil];
    [nc removeObserver:self name:TemplateDownloadProgressNotification object:nil];
    [nc removeObserver:self name:TemplateDownloadErrorNotification object:nil];
    
    // Read
    NSDictionary *userInfo = notification.userInfo;
    Template *originalTemplate = [userInfo objectForKey:TemplateKey];
    self.template = originalTemplate;
    
    /// Блок копирования Layout
    Layout* (^LayoutCopyBlock)(Layout *lt) = ^(Layout *lt) {
        
        NSMutableArray *imageBack = [NSMutableArray array];
        for (Image *image in lt.backLayer.images) {
            Image *ig = [[Image alloc] initWithPixelsMin:image.pixelsMin
                                          andPixelsLimit:image.pixelsLimit
                                                    andZ:image.z
                                             andUrlImage:image.url_image
                                            andUrlUpload:image.url_upload
                                            andPermanent:image.permanent
                                                 andRect:image.rect
                                                 andCrop:image.crop
                                                andImage:image.image andImageOrientation:UIImageOrientationUp andImageOrientationDefault:UIImageOrientationUp];
            [imageBack addObject:ig];
        }
        
        Layer *layerBack = [[Layer alloc] initWithImage:lt.backLayer.image andImages:[imageBack copy]];
        Layer *layerFront = [[Layer alloc] initWithImage:lt.frontLayer.image andImages:nil];
        Layer *layerClear = [[Layer alloc] initWithImage:lt.clearLayer.image andImages:nil];
        Layout *lts = [[Layout alloc] initLayoutWithID:lt.id_layout
                                         andLayoutType:lt.layoutType
                                        andtemplatePSD:lt.template_psd
                                          andBackLayer:layerBack
                                         andFlontLayer:layerFront
                                         andClearLayer:layerClear
                                          andPageIndex:lt.pageIndex
                                      andCombinedLayer:lt.combinedLayer
                               andNoscaleCombinedLayer:lt.noscaleCombinedLayer];
        return lts;
    };
    
    /// Блок создания по характеристикам старого Layout
    Layout* (^LayoutBlock)(NSUInteger, NSArray *layouts) = ^(NSUInteger countImages, NSArray *layouts) {
        Layout *layout;
        
        for (Layout *lt in layouts) {
            if (lt.backLayer.images.count == countImages) {
                
                NSMutableArray *imageBack = [NSMutableArray array];
                for (Image *image in lt.backLayer.images) {
                    Image *ig = [[Image alloc] initWithPixelsMin:image.pixelsMin
                                                  andPixelsLimit:image.pixelsLimit
                                                            andZ:image.z
                                                     andUrlImage:image.url_image
                                                    andUrlUpload:image.url_upload
                                                    andPermanent:image.permanent
                                                         andRect:image.rect
                                                         andCrop:image.crop
                                                        andImage:image.image andImageOrientation:UIImageOrientationUp andImageOrientationDefault:UIImageOrientationUp];
                    [imageBack addObject:ig];
                }
                
                Layer *layerBack = [[Layer alloc] initWithImage:lt.backLayer.image andImages:[imageBack copy]];
                Layer *layerFront = [[Layer alloc] initWithImage:lt.frontLayer.image andImages:nil];
                Layer *layerClear = [[Layer alloc] initWithImage:lt.clearLayer.image andImages:nil];
                Layout *lts = [[Layout alloc] initLayoutWithID:lt.id_layout
                                                 andLayoutType:lt.layoutType
                                                andtemplatePSD:lt.template_psd
                                                  andBackLayer:layerBack
                                                 andFlontLayer:layerFront
                                                 andClearLayer:layerClear
                                                  andPageIndex:lt.pageIndex
                                              andCombinedLayer:lt.combinedLayer
                                       andNoscaleCombinedLayer:lt.noscaleCombinedLayer];
                layout = lts;
            }
        }
        
        return layout;
    };
    
    
    
    /// Блок установки картинок в Layout
    Layout* (^InserImageInLayout)(NSArray *images, Layout *layout) = ^(NSArray *images, Layout *layout) {
        for (int i=0; i<images.count; i++) {
            Image *frameImage = [layout.backLayer.images objectAtIndex:i];
            PrintImage *printImage = [images objectAtIndex:i];
            [frameImage updateImage:printImage.previewImage];
            [frameImage updateUrlImage:printImage.urlLibrary];
        }
        
        return layout;
    };
    
    
    
    PrintImage *image1 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run1"] withName:@"ru1" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image2 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run2"] withName:@"ru2" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image3 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run3"] withName:@"ru3" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image4 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run4"] withName:@"ru4" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image5 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run5"] withName:@"ru5" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image6 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run6"] withName:@"ru6" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image7 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run7"] withName:@"ru7" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image8 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run8"] withName:@"ru8" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image9 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run9"] withName:@"ru9" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    
    Layout *l1 = LayoutCopyBlock(originalTemplate.layoutCover);//LayoutBlock(4, originalTemplate.layouts);
    Layout *l2 = LayoutBlock(4, originalTemplate.layouts);
    [l1 updatePageIndex:1];
    [l2 updatePageIndex:2];
    
    NSArray *layouts = @[l1, l2];
    XCTAssertTrue(layouts.count > 0);
    
    Layout* layout1 = InserImageInLayout(@[image1/*, image2, image3, image4*/], l1/*[layouts objectAtIndex:0]*/);
    Layout* layout2 = InserImageInLayout(@[image5, image6, image7, image8], [layouts objectAtIndex:1]);
//    NSString *idLayout = layout1.id_layout;
    
    layouts = @[layout1/*, layout2*/];
    
    
    Template *userTemplate = [[Template alloc] initTemplateName:originalTemplate.name
                                                    andFontName:originalTemplate.fontName
                                                  andIdTemplate:originalTemplate.id_template
                                                        andSize:originalTemplate.size
                                                     andLayouts:layouts];
    
    
    // PrintData
    NSString *const categoryName = @"Альбомы";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    [printData addPrintImagesFromPhotoLibrary:@[image1, image2, image3, image4/*, image5, image6, image7, image8, image9*/]];
    [printData updateUserTemplate:userTemplate];
    
    [coreShop savePrintData:printData];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SaveImageManager *manager = [[SaveImageManager alloc] initManagerWithPrintData:printData andDelegate:self orPrintImages:nil];
        [manager startSave];
    });
}


- (void) notificationTemplateProgressComplete:(NSNotification *)notification {
}


- (void) notificationTemplateDownloadError:(NSNotification *)notification {
    XCTFail(@"DownLoadError");
    [self.expectation fulfill];
}


#pragma mark - SaveImageManagerDelegate
-(void)saveImageManager:(SaveImageManager *)manager didAllBigImagesSaved:(PrintData *)printData {
    
    /// Блок поиска PrintImage по адресу
    PrintImage* (^SearchPrintImageBlock)(NSString *urlKey, NSArray *images) = ^(NSString *urlKey, NSArray *images) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlLibrary == %@", urlKey];
        NSArray *result = [images filteredArrayUsingPredicate:predicate];
        PrintImage *printImage = [result firstObject];
        NSParameterAssert(printImage);
        return printImage;
    };
    
    
    Template *template = printData.storeItem.propType.userTemplate;
    Layout *layout = [template.layouts firstObject];
    
    for (Image *albumFrame in layout.backLayer.images) {
        PrintImage *pImage = SearchPrintImageBlock(albumFrame.url_image, printData.images);
        NSParameterAssert(pImage);
        [pImage cropImageWithCropSize:albumFrame.rect.size];
        [coreShop savePrepareFinalPrintData:printData andPrintImage:pImage];
        NSLog(@"Prepare: %@; Size: %@", pImage.urlLibrary, NSStringFromCGSize(pImage.editedImageSetting.cropRect.size));
    }
    
    
    [coreShop finalCompletePrintData:printData];
    
    
    [self readFromShopCartWithUnigie:printData.unique_print];
}




- (void) readFromShopCartWithUnigie:(NSUInteger)unique {
    
    /// Блок поиска PrintImage по адресу
    PrintImage* (^SearchPrintImageBlock)(NSString *urlKey, NSArray *images) = ^(NSString *urlKey, NSArray *images) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlLibrary == %@", urlKey];
        NSArray *result = [images filteredArrayUsingPredicate:predicate];
        PrintImage *printImage = [result firstObject];
        return printImage;
    };
    
    
    PrintData *printData = [[coreShop getAllItemsWithNeedAddImages:YES] firstObject];
    
    Template *template = printData.storeItem.propType.userTemplate;
    Layout *layout = [template.layouts firstObject];
    
    CGSize originalSize = layout.noscaleCombinedLayer.size;
    CGFloat zoomScale = originalSize.width / layout.backLayer.image.image.size.width;
    UIImage *layoutImage = [layout.backLayer.image.image scaledImageToSize:originalSize];
    
    for (Image *albumFrame in layout.backLayer.images) {
        PrintImage *pImage = SearchPrintImageBlock(albumFrame.url_image, printData.images);
        
        // Оригинальная картинка в очень плохом качестве
        UIImage *scaledImage = [pImage.previewImage scaledImageToSize:pImage.originalImageSize];
        
        UIImage *cropImage = [[UIImage alloc] cropImageFrom:scaledImage WithRect:pImage.editedImageSetting.cropRect];
        NSLog(@"CropImage: %@; OrigainalLayerSize: %@", NSStringFromCGSize(cropImage.size), NSStringFromCGSize(CGSizeMake(CGRectGetWidth(albumFrame.rect)*zoomScale, CGRectGetHeight(albumFrame.rect)*zoomScale)));
        
        UIImage *scaledCropImage = [cropImage scaledImageToSize:CGSizeMake(CGRectGetWidth(albumFrame.rect)*zoomScale, CGRectGetHeight(albumFrame.rect)*zoomScale)];
        NSLog(@"scaledCop: %@", NSStringFromCGSize(scaledCropImage.size));
        
        CGPoint point = CGPointMake(CGRectGetMinX(albumFrame.rect)*zoomScale, CGRectGetMinY(albumFrame.rect)*zoomScale);
        UIImage *result = [layoutImage mergeImage:scaledCropImage withAtPoint:point];
        layoutImage = result;
    }
    
    [self.expectation fulfill];
}




- (void) testSeveUserTemplate20x15AndBackToChangeStyle {
    // Template
    NSString *templateSize = @"20x15";
    NSString *templateName = @"pink_checkered";
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];
    
    
    /// Блок создания по характеристикам старого Layout
    Layout* (^LayoutBlock)(NSUInteger, NSArray *layouts) = ^(NSUInteger countImages, NSArray *layouts) {
        Layout *layout;
        
        for (Layout *lt in layouts) {
            if (lt.backLayer.images.count == countImages) {
                
                NSMutableArray *imageBack = [NSMutableArray array];
                for (Image *image in lt.backLayer.images) {
                    Image *ig = [[Image alloc] initWithPixelsMin:image.pixelsMin
                                                  andPixelsLimit:image.pixelsLimit
                                                            andZ:image.z
                                                     andUrlImage:image.url_image
                                                    andUrlUpload:image.url_upload
                                                    andPermanent:image.permanent
                                                         andRect:image.rect
                                                         andCrop:image.crop
                                                        andImage:image.image andImageOrientation:UIImageOrientationUp andImageOrientationDefault:UIImageOrientationUp];
                    [imageBack addObject:ig];
                }
                
                Layer *layerBack = [[Layer alloc] initWithImage:lt.backLayer.image andImages:[imageBack copy]];
                Layer *layerFront = [[Layer alloc] initWithImage:lt.frontLayer.image andImages:nil];
                Layer *layerClear = [[Layer alloc] initWithImage:lt.clearLayer.image andImages:nil];
                Layout *lts = [[Layout alloc] initLayoutWithID:lt.id_layout
                                                 andLayoutType:lt.layoutType
                                                andtemplatePSD:lt.template_psd
                                                  andBackLayer:layerBack
                                                 andFlontLayer:layerFront
                                                 andClearLayer:layerClear
                                                  andPageIndex:lt.pageIndex
                                              andCombinedLayer:lt.combinedLayer
                                       andNoscaleCombinedLayer:lt.noscaleCombinedLayer];
                layout = lts;
            }
        }
        
        return layout;
    };
    
    
    
    /// Блок установки картинок в Layout
    Layout* (^InserImageInLayout)(NSArray *images, Layout *layout) = ^(NSArray *images, Layout *layout) {
        for (int i=0;i<images.count; i++) {
            Image *frameImage = [layout.backLayer.images objectAtIndex:i];
            PrintImage *printImage = [images objectAtIndex:i];
            [frameImage updateImage:printImage.previewImage];
            [frameImage updateUrlImage:printImage.urlLibrary];
        }
        
        return layout;
    };
    
    
    
    PrintImage *image1 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run1"] withName:@"ru1" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image2 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run2"] withName:@"ru2" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image3 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run3"] withName:@"ru3" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image4 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run4"] withName:@"ru4" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image5 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run5"] withName:@"ru5" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image6 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run6"] withName:@"ru6" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image7 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run7"] withName:@"ru7" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image8 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run8"] withName:@"ru8" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *image9 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run9"] withName:@"ru9" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    
    Layout *l1 = LayoutBlock(4, originalTemplate.layouts);
    Layout *l2 = LayoutBlock(4, originalTemplate.layouts);
    [l1 updatePageIndex:1];
    [l2 updatePageIndex:2];
    
    NSArray *layouts = @[l1, l2];
    XCTAssertTrue(layouts.count > 0);
    
    Layout* layout1 = InserImageInLayout(@[image1, image2, image3, image4], [layouts objectAtIndex:0]);
    Layout* layout2 = InserImageInLayout(@[image5, image6, image7, image8], [layouts objectAtIndex:1]);
    NSString *idLayout = layout1.id_layout;
    
    layouts = @[layout1, layout2];
    
    
    
    
    Template *userTemplate = [[Template alloc] initTemplateName:originalTemplate.name
                                                    andFontName:originalTemplate.fontName
                                                  andIdTemplate:originalTemplate.id_template
                                                        andSize:originalTemplate.size
                                                     andLayouts:layouts];
    
    
    // PrintData
    NSString *const categoryName = @"Альбомы";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    [printData addPrintImagesFromPhotoLibrary:@[image1, image2, image3, image4, image5, image6, image7, image8, image9]];
    [printData updateUserTemplate:userTemplate];
    
    [coreShop savePrintData:printData];
    
    // Read
    PrintData *unsavedPrinData = [coreShop getUnSavedPrintData];
    Template *unsavedTemplate = unsavedPrinData.storeItem.propType.userTemplate;
    XCTAssertNotNil(unsavedTemplate, @"Template is Nil");
    XCTAssertFalse(unsavedTemplate.name.length == 0, @"Name is Empty: %@", unsavedTemplate.name);
    XCTAssertFalse(unsavedTemplate.fontName.length == 0, @"Font is Empty: %@", unsavedTemplate.fontName);
    XCTAssertFalse(unsavedTemplate.id_template.length == 0, @"ID is Empty: %@", unsavedTemplate.id_template);
    XCTAssertFalse(unsavedTemplate.layouts.count == 0, @"Layouts Empty");
    XCTAssertFalse(unsavedTemplate.size.length == 0, @"Size Empty");
    
    XCTAssertTrue(unsavedTemplate.layouts.count == 2);
    XCTAssertTrue([unsavedTemplate.name isEqualToString:templateName]);
    XCTAssertTrue([unsavedTemplate.size isEqualToString:templateSize]);
    
    
    
    // После того как сохранили, меняем стиль и удаляем из корзины
    NSArray *styles = [coreStore getStylesWithPurchaseID:@"13" andTypePropName:TypeNameConstructor];
    XCTAssertTrue(styles.count > 0);
    
    PropStyle *styleNew;
    for (PropStyle *style in styles) {
        if (![style.styleName isEqualToString:printData.storeItem.propType.selectPropStyle.styleName]) {
            styleNew = style;
        }
    }
    
    [unsavedPrinData changeProp:styleNew];
    
    
    [coreShop removeFromShopCartUnique:0 withBlock:^{
        
    }];
    
    
    Template *unTemplate = unsavedPrinData.storeItem.propType.userTemplate;
    XCTAssertNil(unTemplate);
    XCTAssertTrue(unTemplate.layouts.count == 0);
    
//        Template *selectTemplate = unsavedPrinData.storeItem.propType.selectTemplate;
//        XCTAssertNotNil(selectTemplate);
//        XCTAssertTrue(selectTemplate.layouts.count > 0);
}



- (void) testOriginalTemplateLayoutSort
{
    // Template
    NSString *templateSize = @"20x15";
    NSString *templateName = @"pink_checkered";
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];

    NSArray *layouts = originalTemplate.layouts;
    for (int page=0; page<layouts.count; page++) {
        Layout *layout = [layouts objectAtIndex:page];
        if (page == 0) {
            XCTAssertTrue([layout.id_layout isEqualToString:LayoutCover]);
        } else {
            NSString *layoutId = [NSString stringWithFormat:@"%@%d", (page < 10 ? @"unwrap_0" : @"unwrap_"), page];
            XCTAssertTrue([layoutId isEqualToString:layout.id_layout], @"layout.id_layout: %@; Sort: %@", layout.id_layout, layoutId);
        }
    }
}


- (void) testSaveURLAfterUploadImage
{
    // Template
    NSString *templateSize = @"20x15";
    NSString *templateName = @"pink_checkered";
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];
    
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 2)];
    NSArray *layouts = [originalTemplate.layouts objectsAtIndexes:indexSet];
    NSInteger page = 1;
    for (Layout *layout in layouts) {
        [layout updatePageIndex:page];
        page++;
    }
    Template *userTemplate = [[Template alloc] initTemplateName:originalTemplate.name
                                                    andFontName:originalTemplate.fontName
                                                  andIdTemplate:originalTemplate.id_template
                                                        andSize:originalTemplate.size
                                                     andLayouts:layouts];
    
    
    // PrintData
    NSString *const categoryName = @"Альбомы";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"]) {
            storeItem = item;
        }
    }
    
    
    NSString *urlLibrary = @"http://www.imageLibrary.ru";
    UIImage *image = [UIImage imageNamed:@"style_children"];
    NSInteger library = 4;
    [coreSocial saveImage:image withURL:urlLibrary andLibraryType:(ImportLibrary)library];
    
    
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:nil withName:urlLibrary andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    Image *aImage = [[[[originalTemplate.layouts firstObject] frontLayer] images] firstObject];
    [aImage updateUrlImage:urlLibrary];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    [printData updateUserTemplate:userTemplate];
    
    [coreShop savePrintData:printData];
    [coreShop saveOriginalImagePrintDataUnique:printData.unique_print andPrintImage:printImage andSocialImageData:[coreSocial getImageDataWithURL:urlLibrary]];
    [coreShop finalCompletePrintData:nil];
    
    
    // Read
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unique_print == %li", (long)printData.unique_print];
    PrintData *cartPrintData = [[[coreShop getAllItemsWithNeedAddImages:YES] filteredArrayUsingPredicate:predicate] firstObject];
    
    
    
    // Загрузили на сервер и нам вернулась ссылка
    PrintImage *cartPrintImage = [cartPrintData.images firstObject];
    NSString *uploadURL = @"http://www.ya.ru";
    [cartPrintImage updateUploadUrl:uploadURL withPrintDataUnique:cartPrintData.unique_print];
    
    // Read и проверяем сохранилась ли ссылка и на пользовательском шаблоне тоже
    cartPrintData = [[[coreShop getAllItemsWithNeedAddImages:YES] filteredArrayUsingPredicate:predicate] firstObject];
    cartPrintImage = [cartPrintData.images firstObject];
    Template *cartUserTemplate = cartPrintData.storeItem.propType.userTemplate;
    
    
    XCTAssertTrue([[cartPrintImage.uploadURL absoluteString] isEqualToString:uploadURL]);    for (Layout *layout in cartUserTemplate.layouts) {
        for (Image *image in layout.frontLayer.images) {
            if ([image.url_image isEqualToString:urlLibrary]) {
                XCTAssertTrue([image.url_upload isEqualToString:[cartPrintImage.uploadURL absoluteString]]);
            }
        }
    }
}


- (void) testSaveURLAfterUploadImageOrher
{
    // Template
    NSString *templateSize = @"20x15";
    NSString *templateName = @"pink_checkered";
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)PhotoHousePrintAlbum]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:templateSize
                                                      andTemplateName:templateName];
    
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 2)];
    NSArray *layouts = [originalTemplate.layouts objectsAtIndexes:indexSet];
    NSInteger page = 1;
    for (Layout *layout in layouts) {
        [layout updatePageIndex:page];
        page++;
    }
    Template *userTemplate = [[Template alloc] initTemplateName:originalTemplate.name
                                                    andFontName:originalTemplate.fontName
                                                  andIdTemplate:originalTemplate.id_template
                                                        andSize:originalTemplate.size
                                                     andLayouts:layouts];
    

    
    //
    NSString *const categoryName = @"Сувениры и подарки";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem = [storeItems firstObject];

    
    // Image save Social
    NSString *urlLibrary = @"http://www.imageLibrary.ru";
    UIImage *image = [UIImage imageNamed:@"style_children"];
    NSInteger library = 4;
    [coreSocial saveImage:image withURL:urlLibrary andLibraryType:(ImportLibrary)library];
    
    
    
    // Create Print Data and Save
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:nil withName:urlLibrary andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    Image *aImage = [[[[originalTemplate.layouts firstObject] frontLayer] images] firstObject];
    [aImage updateUrlImage:urlLibrary];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    [printData updateUserTemplate:userTemplate];
    
    // Save To CoreData
    [coreShop savePrintData:printData];
    [coreShop saveOriginalImagePrintDataUnique:printData.unique_print andPrintImage:printImage andSocialImageData:[coreSocial getImageDataWithURL:urlLibrary]];
    [coreShop finalCompletePrintData:nil];
    
    
    
    // Read from CoreData
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unique_print == %li", (long)printData.unique_print];
    PrintData *cartPrintData = [[[coreShop getAllItemsWithNeedAddImages:YES] filteredArrayUsingPredicate:predicate] firstObject];
    
    
    
    // Загрузили на сервер и нам вернулась ссылка
    PrintImage *cartPrintImage = [cartPrintData.images firstObject];
    NSString *uploadURL = @"http://www.ya.ru";
    [cartPrintImage updateUploadUrl:uploadURL withPrintDataUnique:cartPrintData.unique_print];
    
    
    // Read и проверяем сохранилась ли ссылка и на пользовательском шаблоне тоже
    cartPrintData = [[[coreShop getAllItemsWithNeedAddImages:YES] filteredArrayUsingPredicate:predicate] firstObject];
    cartPrintImage = [cartPrintData.images firstObject];
    Template *cartUserTemplate = cartPrintData.storeItem.propType.userTemplate;
    
    
    XCTAssertTrue([[cartPrintImage.uploadURL absoluteString] isEqualToString:uploadURL]);    for (Layout *layout in cartUserTemplate.layouts) {
        for (Image *image in layout.frontLayer.images) {
            if ([image.url_image isEqualToString:urlLibrary]) {
                XCTAssertTrue([image.url_upload isEqualToString:[cartPrintImage.uploadURL absoluteString]]);
            }
        }
    }
}



- (void) testAddToShopCartAndRemoveUnUserdImages
{
    NSString *const categoryName = @"Альбомы";
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"13"] && [item.propType.name isEqualToString:TypeNameConstructor]) {
            storeItem = item;
        }
    }
    
    PrintData *printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    PrintImage *printImage1 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"albumBack"] withName:@"http://albumBack" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *printImage2 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"squareImage"] withName:@"http://squareImage" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *printImage3 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"horizontalImage"] withName:@"http://horizontalImage" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    PrintImage *printImage4 = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"style_children"] withName:@"http://style_shildren" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObjects:printImage1, printImage2, printImage3, printImage4, nil]];
    
    [coreShop savePrintData:printData];
    [coreShop removeImages:[NSArray arrayWithObject:@"http://albumBack"]];
    
    PrintData *unsaved = [coreShop getUnSavedPrintData];
    XCTAssertTrue(unsaved.images.count == 3, @"Count: %li", (long)unsaved.images.count);
}


@end
