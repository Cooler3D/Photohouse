//
//  PrintImageTest.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 04/03/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PrintImage.h"
#import "PrintData.h"

#import "CoreDataStore.h"
#import "ResponseGetItems.h"

#import "BundleDefault.h"

#import "UIImage+Crop.h"


@interface PrintDataAndImageTest : XCTestCase

@end

@implementation PrintDataAndImageTest
{
    PrintData *printData;
    PrintImage *printImage;
    ResponseGetItems *response;
    CoreDataStore *coreStore;
}

- (void)setUp
{
    BundleDefault *bundle = [[BundleDefault alloc] init];
    response = [[ResponseGetItems alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAllItems]];
    coreStore = [[CoreDataStore alloc] init];
    
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    printData = nil;
    printImage = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateSocialPrintImage
{
    printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run1"] withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    XCTAssertNotNil(printImage.previewImage, @"Icon image nil");
    XCTAssertFalse(printImage.urlLibrary.length == 0, @"UrlLibrary is Empty");
}




- (void) testCreateMergeImage
{
    PrintImage *merge1 = [[PrintImage alloc] initMergeImage:[UIImage imageNamed:@"sectionInConstructor"] withName:@"merge1" andUploadUrl:nil];
    XCTAssertNotNil(merge1.previewImage, @"Preview image nil");
    XCTAssertFalse(merge1.urlLibrary.length == 0, @"UrlLibrary is Empty");
}



- (void)testPrintDataWithPhotoPrints
{
    NSString *const categoryName = @"Фотопечать";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *item = [storeItems firstObject];
    
    printData = [[PrintData alloc] initWithStoreItem:item andUniqueNum:0];
    printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run1"] withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    
    XCTAssertNotNil(printImage.previewImage, @"Preview image nil");
    XCTAssertNotNil(printImage.iconPreviewImage, @"Icon image nil");

    XCTAssertEqual(50, printImage.iconPreviewImage.size.width, @"Size Width Equal");
    XCTAssertEqual(50, printImage.iconPreviewImage.size.height, @"Size Height Equal");
    
    XCTAssertEqual([UIImage imageNamed:@"run1"].size.width, printImage.originalImageSize.width, @"Size Width Equal");
    XCTAssertEqual([UIImage imageNamed:@"run1"].size.height, printImage.originalImageSize.height, @"Size Height Equal");
    
    XCTAssertNotNil(printImage.editedImageSetting, @"Setting Nil");
    
    XCTAssertNotNil(printData.gridImage, @"GridEdit image nil");
}





- (void)testPrintDataWithMug
{
    NSString *const categoryName = @"Сувениры и подарки";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"2"]) {
            storeItem = item;
        }
    }
    
    printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo" andEditSetting:nil originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    
    
    /*PrintImage *merge1 = [[PrintImage alloc] initMergeImage:[UIImage imageNamed:@"sectionInConstructor"] withName:@"merge1"];
    PrintImage *merge2 = [[PrintImage alloc] initMergeImage:[UIImage imageNamed:@"sectionInConstructor"] withName:@"merge2"];
    [printData addMergedImages:[NSArray arrayWithObjects:merge1, merge2, nil]];*/
    [printData createAndAddMergedImageWithPrintImage:printImage.previewImage];
    XCTAssertFalse(printData.mergedImages.count == 0, @"Merged is Empty; %li", (unsigned long)printData.mergedImages.count);
    
    XCTAssertNotNil(printData.gridImage, @"GridEdit image nil");
    
    for (id object in printData.mergedImages) {
        XCTAssertTrue([object isKindOfClass:[PrintImage class]], @"Do not PrintImage Class");
        XCTAssertTrue([(PrintImage *)object isMergedImage], @"No Edit");
    }
}



- (void) testPrintImageChangeSetting
{
    NSString *const categoryName = @"Сувениры и подарки";
    NSArray *storeItems = [coreStore getStoreItemsWithCategoryName:categoryName];
    StoreItem *storeItem;
    for (StoreItem *item in storeItems) {
        if ([item.purchaseID isEqualToString:@"1"]) {
            storeItem = item;
        }
    }
    
    printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
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
    printImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"logo"] withName:@"http://logo" andEditSetting:setting originalSize:CGSizeZero andUploadUrl:nil];
    [printData addPrintImagesFromPhotoLibrary:[NSArray arrayWithObject:printImage]];
    
    
    /*PrintImage *merge1 = [[PrintImage alloc] initMergeImage:[UIImage imageNamed:@"sectionInConstructor"] withName:@"merge1"];
    PrintImage *merge2 = [[PrintImage alloc] initMergeImage:[UIImage imageNamed:@"sectionInConstructor"] withName:@"merge2"];
    [printData addMergedImages:[NSArray arrayWithObjects:merge1, merge2, nil]];*/
    [printData createAndAddMergedImageWithPrintImage:printImage.previewImage];

    
    // Change
    PrintImage *chooseImage = [printData.imagesPreview firstObject];
    EditImageSetting *chooseSetting = chooseImage.editedImageSetting;
    [chooseSetting changeFilter:filter2];
    [chooseSetting changeSaturation:saturation2];
    
    
    //Result
    PrintImage *resultImage = [printData.imagesPreview firstObject];
    EditImageSetting *resultSetting = resultImage.editedImageSetting;
    
    
    XCTAssertTrue([resultSetting.filterName isEqualToString:filter2], @"Filter Dont Change: %@ - %@", resultSetting.filterName, filter2);
    XCTAssertTrue(resultSetting.saturationValue == saturation2, @"Saturaton Dont Change");
}

- (void) testPrintImageCropStandart {
    CGFloat aspect_ratio = 220.f/185.f;
    CGSize imageOriginalSize = CGSizeMake(775, 771);
    
    CGRect rectOriginalCrop = [[UIImage alloc] insertSizeView:imageOriginalSize withAspectRatio:aspect_ratio];
    XCTAssertTrue((int)CGRectGetMinX(rectOriginalCrop) == 0);
    XCTAssertTrue((int)CGRectGetMinY(rectOriginalCrop) == 59);
    XCTAssertTrue((int)CGRectGetWidth(rectOriginalCrop) == 775);
    XCTAssertTrue((int)CGRectGetHeight(rectOriginalCrop) == 651);
}

/// После редактора
- (void) testPrintImageCropEditor {
    /// оригинальные размеры картинки, большой которая в библиотеке/CoreData
    CGSize imageOriginalSize = CGSizeMake(775, 771);
    
    /// Размеры увеличенной картинки в редакторе
    CGSize editedImageSize = CGSizeMake(800, 795.87);
    
    /// Значения после редактора, картинку увеличили
    CGRect cropEditor = CGRectMake(85, 133, 630, 528);
    
    /// Отношение увеличенной картинки к оригинальной, значение должно быть больше 1
    CGFloat scale = editedImageSize.width / imageOriginalSize.width;
    
    CGRect cropOriginal = CGRectMake(CGRectGetMinX(cropEditor) / scale,
                                     CGRectGetMinY(cropEditor) / scale,
                                     CGRectGetWidth(cropEditor) / scale,
                                     CGRectGetHeight(cropEditor) / scale);
    
          
    XCTAssertTrue((int)(CGRectGetMinX(cropOriginal) * 2 + CGRectGetWidth(cropOriginal)) == (int)imageOriginalSize.width);
//    XCTAssertTrue((int)(CGRectGetMinY(cropOriginal) * 2 + CGRectGetHeight(cropOriginal)) == (int)imageOriginalSize.height, @"%f == %f", (CGRectGetMinY(cropOriginal) * 2) + CGRectGetHeight(cropOriginal), imageOriginalSize.height);
}

- (void) testPrintImageCalculateImageOrientationUpAndUp {
    /// оригинальные размеры картинки, большой которая в библиотеке/CoreData
    CGSize imageOriginalSize = CGSizeMake(2048, 1536);
    
    PrintImage *pImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run1"] withName:@"run1" andEditSetting:nil originalSize:imageOriginalSize andUploadUrl:nil];
    UIImageOrientation showedOrientaion = UIImageOrientationUp;
    
    CGSize size = [pImage calculateOriginalSizeWithOrientation:showedOrientaion];
    XCTAssertTrue(size.width == imageOriginalSize.width);
    XCTAssertTrue(size.height == imageOriginalSize.height);
}


- (void) testPrintImageCalculateImageOrientationUpAndDown {
    /// оригинальные размеры картинки, большой которая в библиотеке/CoreData
    CGSize imageOriginalSize = CGSizeMake(2048, 1536);
    
    PrintImage *pImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run1"] withName:@"run1" andEditSetting:nil originalSize:imageOriginalSize andUploadUrl:nil];
    UIImageOrientation showedOrientaion = UIImageOrientationDown;
    
    CGSize size = [pImage calculateOriginalSizeWithOrientation:showedOrientaion];
    XCTAssertTrue(size.width == imageOriginalSize.width);
    XCTAssertTrue(size.height == imageOriginalSize.height);
}

- (void) testPrintImageCalculateImageOrientationDownAndDown {
    /// оригинальные размеры картинки, большой которая в библиотеке/CoreData
    CGSize imageOriginalSize = CGSizeMake(2048, 1536);
    
    PrintImage *pImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run1"] withName:@"run1" andEditSetting:nil originalSize:imageOriginalSize andUploadUrl:nil];
    [pImage.editedImageSetting changeOrientationDefault:UIImageOrientationDown];
    UIImageOrientation showedOrientaion = UIImageOrientationDown;
    
    CGSize size = [pImage calculateOriginalSizeWithOrientation:showedOrientaion];
    XCTAssertTrue(size.width == imageOriginalSize.width);
    XCTAssertTrue(size.height == imageOriginalSize.height);
}


- (void) testPrintImageCalculateImageOrientationUpAndRight {
    /// оригинальные размеры картинки, большой которая в библиотеке/CoreData
    CGSize imageOriginalSize = CGSizeMake(2048, 1536);
    
    PrintImage *pImage = [[PrintImage alloc] initWithPreviewImage:[UIImage imageNamed:@"run1"] withName:@"run1" andEditSetting:nil originalSize:imageOriginalSize andUploadUrl:nil];
    UIImageOrientation showedOrientaion = UIImageOrientationRight;
    
    CGSize size = [pImage calculateOriginalSizeWithOrientation:showedOrientaion];
    XCTAssertTrue(size.width == imageOriginalSize.height);
    XCTAssertTrue(size.height == imageOriginalSize.width);
}


- (void) testPrintImageCalculateImageOrientationRightAndRight {
    /// оригинальные размеры картинки, большой которая в библиотеке/CoreData
    CGSize imageOriginalSize = CGSizeMake(2048, 1536);
    
    UIImage *image = [UIImage imageNamed:@"run1"];
    UIImage *result = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
    PrintImage *pImage = [[PrintImage alloc] initWithPreviewImage:result withName:@"run1" andEditSetting:nil originalSize:imageOriginalSize andUploadUrl:nil];
    [pImage.editedImageSetting changeOrientationDefault:UIImageOrientationRight];
    UIImageOrientation showedOrientaion = UIImageOrientationRight;
    
    CGSize size = [pImage calculateOriginalSizeWithOrientation:showedOrientaion];
    XCTAssertTrue(size.width == imageOriginalSize.width);
    XCTAssertTrue(size.height == imageOriginalSize.height);
}

- (void) testPrintImageCalculateImageOrientationRightAndUp {
    /// оригинальные размеры картинки, большой которая в библиотеке/CoreData
    CGSize imageOriginalSize = CGSizeMake(2048, 1536);
    
    UIImage *image = [UIImage imageNamed:@"run1"];
    UIImage *result = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
    PrintImage *pImage = [[PrintImage alloc] initWithPreviewImage:result withName:@"run1" andEditSetting:nil originalSize:imageOriginalSize andUploadUrl:nil];
    [pImage.editedImageSetting changeOrientationDefault:UIImageOrientationRight];
    UIImageOrientation showedOrientaion = UIImageOrientationUp;
    
    CGSize size = [pImage calculateOriginalSizeWithOrientation:showedOrientaion];
    XCTAssertTrue(size.width == imageOriginalSize.height);
    XCTAssertTrue(size.height == imageOriginalSize.width);
}

- (void) testPrintImageCalculateImageOrientationRightAndDown {
    /// оригинальные размеры картинки, большой которая в библиотеке/CoreData
    CGSize imageOriginalSize = CGSizeMake(2048, 1536);
    
    UIImage *image = [UIImage imageNamed:@"run1"];
    UIImage *result = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
    PrintImage *pImage = [[PrintImage alloc] initWithPreviewImage:result withName:@"run1" andEditSetting:nil originalSize:imageOriginalSize andUploadUrl:nil];
    [pImage.editedImageSetting changeOrientationDefault:UIImageOrientationRight];
    UIImageOrientation showedOrientaion = UIImageOrientationDown;
    
    CGSize size = [pImage calculateOriginalSizeWithOrientation:showedOrientaion];
    XCTAssertTrue(size.width == imageOriginalSize.height);
    XCTAssertTrue(size.height == imageOriginalSize.width);
}


@end
