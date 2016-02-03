//
//  CoreDataStoreV2Test.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/3/15.
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


/*!
 @brief Данный класс тестирует надстройку над обычным Template(Старый), AlbumTemplate(Надстройка)
 
 @author Дмитрий Мартынов
 */
@interface CoreDataStoreV2Test : XCTestCase

@end

@implementation CoreDataStoreV2Test
{
    ResponseGetItems *responseGetItems;
    ResponseAlbumV2 *responseAlbumV2;
    CoreDataStore *coreStore;

}
- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    coreStore = [[CoreDataStore alloc] init];
}

- (void)tearDown
{
    [coreStore clearStory];
    coreStore = nil;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Templates Ver2
- (void) testParseTemplateVer2
{
    BundleDefault *bundle = [[BundleDefault alloc] init];
    responseAlbumV2 = [[ResponseAlbumV2 alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];

    NSArray *albumTemplates = responseAlbumV2.templates;
    XCTAssertFalse(albumTemplates.count == 0);
    
    for (AlbumTemplate *aTemplate in albumTemplates) {
        XCTAssertNotNil(aTemplate);
        XCTAssertTrue(aTemplate.styleName.length > 0);
        XCTAssertTrue(aTemplate.formaSize.length > 0);
        
        
        // JsonTemplateLayout
        JsonTemplateLayout *jsonTemplate = aTemplate.jsonTemplate;
        XCTAssertNotNil(jsonTemplate);
        XCTAssertTrue(jsonTemplate.layouts.count > 0);
        XCTAssertTrue(jsonTemplate.styleThumbalUrl.length > 0);
        XCTAssertTrue(jsonTemplate.storeThumbalUrl.length > 0);
        
        // Layer Page
        LayerPage *layer = jsonTemplate.cover;
        XCTAssertNotNil(layer);
        XCTAssertTrue(layer.placeHolders.count > 0);
        XCTAssertNotNil(layer.combinedLayer);
        XCTAssertNotNil(layer.underLayer);
        XCTAssertNotNil(layer.overLayer);
        XCTAssertTrue(CGRectGetWidth(layer.noscaleCombinedLayer) > 0);
        XCTAssertTrue(CGRectGetHeight(layer.noscaleCombinedLayer) > 0);
        
        
        //
        for (LayerPage *layer in jsonTemplate.layouts) {
            XCTAssertNotNil(layer);
            XCTAssertTrue(layer.placeHolders.count > 0);
            XCTAssertTrue(layer.layoutSelectPng.length > 0, @"Key:%@; Style: %@; Format: %@", layer.nameKey, aTemplate.styleName, aTemplate.formaSize);
            XCTAssertTrue(layer.nameKey.length > 0);
            XCTAssertNotNil(layer.combinedLayer);
            XCTAssertNotNil(layer.underLayer);
            XCTAssertNotNil(layer.overLayer);
            XCTAssertTrue(CGRectGetWidth(layer.noscaleCombinedLayer) > 0);
            XCTAssertTrue(CGRectGetHeight(layer.noscaleCombinedLayer) > 0);
            XCTAssertTrue(CGRectGetMinX(layer.noscaleCombinedLayer) >= 0);
            XCTAssertTrue(CGRectGetMinY(layer.noscaleCombinedLayer) >= 0);
            
            
            // PlaceHolder's
            // CombinedLayer
            PlaceHolder *placeHoder = layer.combinedLayer;
            XCTAssertNotNil(placeHoder);
            XCTAssertTrue(placeHoder.psdPath.length > 0);
            XCTAssertTrue(placeHoder.layerNum.length > 0);
            XCTAssertTrue(placeHoder.pngPath.length > 0);
            XCTAssertTrue(CGRectGetWidth(placeHoder.rect) >= 0);
            XCTAssertTrue(CGRectGetHeight(placeHoder.rect) >= 0);
            
            // underLayer
            placeHoder = layer.underLayer;
            XCTAssertNotNil(placeHoder);
            XCTAssertTrue(placeHoder.psdPath.length > 0);
            XCTAssertTrue(placeHoder.layerNum.length > 0);
            XCTAssertTrue(placeHoder.pngPath.length > 0);
            XCTAssertTrue(CGRectGetWidth(placeHoder.rect) >= 0);
            XCTAssertTrue(CGRectGetHeight(placeHoder.rect) >= 0);
            
            // overLayer
            placeHoder = layer.overLayer;
            XCTAssertNotNil(placeHoder);
            XCTAssertTrue(placeHoder.psdPath.length > 0);
            XCTAssertTrue(placeHoder.layerNum.length > 0);
            XCTAssertTrue(placeHoder.pngPath.length > 0);
            XCTAssertTrue(CGRectGetWidth(placeHoder.rect) >= 0);
            XCTAssertTrue(CGRectGetHeight(placeHoder.rect) >= 0);
            
            
            for (PlaceHolder *plHoler in layer.placeHolders) {
                XCTAssertNotNil(plHoler);
                XCTAssertTrue(plHoler.psdPath.length > 0);
                XCTAssertTrue(plHoler.layerNum.length > 0);
                XCTAssertTrue(plHoler.pngPath.length > 0);
                XCTAssertTrue(plHoler.scalePngUrl.length > 0);
                XCTAssertTrue(CGRectGetWidth(plHoler.rect) >= 0);
                XCTAssertTrue(CGRectGetHeight(plHoler.rect) >= 0);
            }
        }
    }
}

- (void) testCreateTemplateWithAlbumVer2
{
    BundleDefault *bundle = [[BundleDefault alloc] init];
    responseAlbumV2 = [[ResponseAlbumV2 alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];

    NSArray *albumTemplates = responseAlbumV2.templates;
    XCTAssertFalse(albumTemplates.count == 0);
    
    NSArray *oldTemplates = responseAlbumV2.oldTemplates;
    
    XCTAssertFalse(oldTemplates.count == 0, @"Styles Empty");
    for (Template *template in oldTemplates) {
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
                
                // Rect
                CGRect rect = image.rect;
                XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
                XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
                
                // Crop
//                CGRect crop = image.rect;
//                XCTAssertNotEqual(CGRectGetWidth(crop), 0.f);
//                XCTAssertNotEqual(CGRectGetHeight(crop), 0.f);
            }
            // *******
            
            
            
            //            // *******
            //            // Front
            //            Layer *frontLayer = layout.frontLayer;
            //            XCTAssertNotNil(frontLayer.image);
            //            XCTAssertFalse(frontLayer.images.count == 0, @"Images Empty");
            //
            //            Image *frontImage = frontLayer.image;
            //            XCTAssertFalse(frontImage.pixelsMin.length == 0);
            //            XCTAssertFalse(frontImage.pixelsLimit.length == 0);
            //            XCTAssertFalse(frontImage.z.length == 0);
            //            XCTAssertFalse(frontImage.permanent.length == 0);
            //            XCTAssertFalse(frontImage.url_image.length == 0);
            ////            XCTAssertNotNil(frontImage.image);
            //
            //
            //            // Maket
            //            for (Image *image in frontLayer.images) {
            //                XCTAssertFalse(image.pixelsMin.length == 0);
            //                XCTAssertFalse(image.pixelsLimit.length == 0);
            //                XCTAssertFalse(image.z.length == 0);
            //                XCTAssertFalse(image.permanent.length == 0);
            //                //                XCTAssertFalse(image.url_image.length == 0);
            //
            //                Position *rect = image.rect;
            //                XCTAssertNotEqual(rect.right, 0.f);
            //                XCTAssertNotEqual(rect.bottom, 0.f);
            //
            //                // Crop
            //                Position *crop = image.crop;
            //                XCTAssertNotEqual(crop.right, 0.f);
            //                XCTAssertNotEqual(crop.bottom, 0.f);
            //            }
            //            // *******
            
            
            
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
            //                Position *rect = image.rect;
            //                XCTAssertNotEqual(rect.right, 0.f);
            //                XCTAssertNotEqual(rect.bottom, 0.f);
            //
            //                // Crop
            //                Position *crop = image.crop;
            //                XCTAssertNotEqual(crop.right, 0.f);
            //                XCTAssertNotEqual(crop.bottom, 0.f);
            //            }
            //            // *******
        }
    }
}


- (void) testSaveToCoreDataAlbumConvertV2
{
    BundleDefault *bundle = [[BundleDefault alloc] init];
    responseAlbumV2 = [[ResponseAlbumV2 alloc] initWitParseData:[bundle defaultDataWithBundleName:BundleDefaultTypeAlbumTestVer2]];
    
    NSData *dataItems = [bundle defaultDataWithBundleName:BundleDefaultTypeAllItems];
    responseGetItems = [[ResponseGetItems alloc] initWitParseData:dataItems andTemplates:responseAlbumV2.oldTemplates];
    
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
                XCTAssertFalse(image.url_image.length == 0);
                
                CGRect rect = image.rect;
                XCTAssertNotEqual(CGRectGetWidth(rect), 0.f);
                XCTAssertNotEqual(CGRectGetHeight(rect), 0.f);
                
                XCTAssertFalse(CGRectGetMinX(rect) > 1000, @"%f", CGRectGetMinX(rect));
                XCTAssertFalse(CGRectGetMinY(rect) > 1000, @"%f", CGRectGetMinY(rect));
                XCTAssertFalse(CGRectGetWidth(rect) > 1000, @"%f", CGRectGetWidth(rect));
                XCTAssertFalse(CGRectGetHeight(rect) > 1000, @"%f", CGRectGetHeight(rect));
            }
            // *******
            
            
            
            //            // *******
            //            // Front
            //            Layer *frontLayer = layout.frontLayer;
            //            XCTAssertNotNil(frontLayer.image);
            //            XCTAssertFalse(frontLayer.images.count == 0, @"Images Empty");
            //
            //            Image *frontImage = frontLayer.image;
            //            XCTAssertFalse(frontImage.pixelsMin.length == 0);
            //            XCTAssertFalse(frontImage.pixelsLimit.length == 0);
            //            XCTAssertFalse(frontImage.z.length == 0);
            //            XCTAssertFalse(frontImage.permanent.length == 0);
            //            XCTAssertFalse(frontImage.url_image.length == 0);
            ////            XCTAssertNotNil(frontImage.image);
            //
            //
            //            // Maket
            //            for (Image *image in frontLayer.images) {
            //                XCTAssertFalse(image.pixelsMin.length == 0);
            //                XCTAssertFalse(image.pixelsLimit.length == 0);
            //                XCTAssertFalse(image.z.length == 0);
            //                XCTAssertFalse(image.permanent.length == 0);
            //                //                XCTAssertFalse(image.url_image.length == 0);
            //
            //                Position *rect = image.rect;
            //                XCTAssertNotEqual(rect.right, 0.f);
            //                XCTAssertNotEqual(rect.bottom, 0.f);
            //
            //                // Crop
            //                Position *crop = image.crop;
            //                XCTAssertNotEqual(crop.right, 0.f);
            //                XCTAssertNotEqual(crop.bottom, 0.f);
            //            }
            //            // *******
            
            
            
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
            //                Position *rect = image.rect;
            //                XCTAssertNotEqual(rect.right, 0.f);
            //                XCTAssertNotEqual(rect.bottom, 0.f);
            //
            //                // Crop
            //                Position *crop = image.crop;
            //                XCTAssertNotEqual(crop.right, 0.f);
            //                XCTAssertNotEqual(crop.bottom, 0.f);
            //            }
            //            // *******
        }
    }
}

@end
