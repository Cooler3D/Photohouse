
//
//  CoreDataShopCart.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/16/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "CoreDataShopCart.h"
#import "CoreDataStore.h"

#import "StoreItem.h"
#import "PropType.h"

#import "PrintData.h"
#import "PrintImage.h"
#import "EditImageSetting.h"

#import "Template.h"
#import "Layout.h"
#import "Layer.h"
#import "Image.h"
#import "PlaceHolder.h"

#import "ShopCartImageEntity.h"
#import "ShopCartPrintEntity.h"
#import "ShopCartSettingEntity.h"
#import "ShopCartPropsEntity.h"

#import "ShopTemplateEntity.h"
#import "ShopLayoutEntity.h"
#import "ShopImageLayerEntity.h"
#import "ShopPlaceHolderEntity.h"

#import "NSDictionary+Rect.h"

#import "DeviceManager.h"

#import "UIImage+AssetResize.h"
#import "UIImage+Crop.h"

#import "MDPhotoLibrary.h"


typedef enum {
    AlbumTypeFrontImage,    // Передняя картинка разворот
    AlbumTypeBackImage,     // Задняя картинка разворот
    AlbumTypeClearImage,    // Разворот очистки
    AlbumFrontImages,       // Картинки для передний пользовательские
    AlbumBackImages         // Каринки для задней пользовательские
} AlbumTypeImage;


NSString *const SHOP_CART_IMAGE_ENTITY          = @"ShopCartImageEntity";
NSString *const SHOP_CART_PRINT_ENTITY          = @"ShopCartPrintEntity";
NSString *const SHOP_CART_EDIT_SETTING_ENTITY   = @"ShopCartSettingEntity";
NSString *const SHOP_CART_PROPS_ENTITY          = @"ShopCartPropsEntity";

NSString *const SHOP_CART_TEMPLATE_ENTITY       = @"ShopTemplateEntity";
NSString *const SHOP_CART_LAYOUT_ENTITY         = @"ShopLayoutEntity";
NSString *const SHOP_CART_IMAGELAYER_ENTITY     = @"ShopImageLayerEntity";
NSString *const SHOP_CART_PLACEHOLDER_ENTITY    = @"ShopPlaceHolderEntity";



@implementation CoreDataShopCart
#pragma mark - Save
- (void) savePrintData:(PrintData *)printData
{
    /* Удаляем все которые с process == YES */
    [self removeActiveProcess];
    
    Template *userTemplate = printData.storeItem.propType.userTemplate;
    ShopCartPrintEntity *printEntity = [NSEntityDescription insertNewObjectForEntityForName:SHOP_CART_PRINT_ENTITY inManagedObjectContext:self.managedObjectContext];
    [printEntity setPurchaseID:[NSNumber numberWithInteger:printData.purchaseID]];
    [printEntity setNamePurchase:printData.namePurchase];
    [printEntity setTypeName:printData.nameType];
    [printEntity setNameCategory:printData.nameCategory];
    [printEntity setCount:[NSNumber numberWithInteger:1]];
    [printEntity setProcessInsert:[NSNumber numberWithBool:YES]];
    [printEntity setUnique_print:[NSNumber numberWithInteger:printData.unique_print]];
    [printEntity setProps:[self createPropsEntity:printData.props andPrice:printData.price andPropTypeName:printData.nameType andUserTemplate:userTemplate]];
    [printEntity addImages:[self createPrintEntityImages:printData.images]];
    
    [self.managedObjectContext save:nil];
    NSLog(@"Save.Complte:unique: %li", (long)printData.unique_print);
}





- (void) saveMergedPreviewPrintData:(PrintData *)printData withPrintImages:(NSArray *)printImages
{
    if (!printData) {
        printData = [self getUnSavedPrintData];
    }
    
    if (!printImages) {
        printImages = printData.mergedImages;
    }
    
    // Remove Merged
    [self removeMergedPrintImagesWithPrintDataUnique:printData.unique_print];
    
    
    if (printImages.count == 0) return;
    
    // Add
    ShopCartPrintEntity *printEntity = [self getActivePrintEntity];
    [printEntity addImages:[self createPrintEntityImages:printImages]];
    [self.managedObjectContext save:nil];
}




-(void)updateAfterEditorPrintData:(PrintData *)printData andPrintImage:(PrintImage *)printImage
{
    // Если printData == nil, ищем активную
    if (!printData) {
        ShopCartPrintEntity *printEntity = [self getActivePrintEntity];
        printData = [self createPrintDataWithEntity:printEntity andNeedAddImage:NO];
    }
    
    if(!printImage) {
        printImage = [printData.imagesPreview firstObject];
    }
    
    NSParameterAssert(printData);
    NSParameterAssert(printImage);
    
    
    // Если есть isMerged, значит обновляем всю PrintData
    // Иначе только данные об одной картинке, т.к это не альбом и нет множества картинок
    // PrintData уже должна содержать скленные картинки и по ним опеределяем
    /*if (printData.mergedImages.count != 0) {
        // Обновляем всю PrintData
        [self savePrintData:printData];
    } else {*/
        // Обновляем только данные о картинке
        ShopCartImageEntity *imageEntity = [self getPrintImageEntityWithPrintDataUnique:printData.unique_print andUrlLibraryImage:printImage.urlLibrary];
    if (!imageEntity) {
        return;
    }
        NSParameterAssert(imageEntity);
        
        // Создаем новуюе Setting Entity по параметрам
        ShopCartSettingEntity *settingEntity = [self createEditEntitySetting:printImage.editedImageSetting];
    NSParameterAssert(settingEntity);
    
        // Обновляем и сохраняем
        [imageEntity setImageSetting:settingEntity];
        [self.managedObjectContext save:nil];
    //}
}



- (void) updateAfterUploadPrintDataUnique:(NSInteger)unique andPrintImage:(PrintImage *)printImage
{
    ShopCartPrintEntity *printEntity = [[self getPrintEntityUnique:unique] firstObject];
    NSParameterAssert(printEntity);
    
    
    // Update PrintImage
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlLibrary == %@", printImage.urlLibrary];
    NSSet *filterImages = [printEntity.images filteredSetUsingPredicate:predicate];
    
    ShopCartImageEntity *imageEntity = [filterImages anyObject];
    NSParameterAssert(imageEntity);
    
    [imageEntity setUploadURL:printImage.uploadURL.absoluteString];
    
    ShopCartSettingEntity *settingEntity = imageEntity.imageSetting;
    [settingEntity setCrop:NSStringFromCGRect(printImage.editedImageSetting.cropRect)];
    
    
    
    
    // Update UserTemplate
    ShopCartPropsEntity *propsEntity = printEntity.props;
    ShopTemplateEntity *userTemplateEntity = propsEntity.templateAlbum;
    
    for (ShopLayoutEntity *layoutEntity in userTemplateEntity.layouts) {
        for (ShopImageLayerEntity *imageEntity in layoutEntity.layers) {
            if ([imageEntity.urlPage isEqualToString:printImage.urlLibrary]) {
                [imageEntity setUrlUpload:printImage.uploadURL.absoluteString];
            }
        }
    }
    
    
    // Save
    [self.managedObjectContext save:nil];
}


-(void)updateURLLibraryWithPrintDataUnique:(NSInteger)unique andPrintImage:(PrintImage *)printImage andNewUrlLibraryKey:(NSString *)newUrlLibrary {
    ShopCartPrintEntity *printEntity = [[self getPrintEntityUnique:unique] firstObject];
    NSParameterAssert(printEntity);
    
    
    // Update PrintImage
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlLibrary == %@", printImage.urlLibrary];
    NSSet *filterImages = [printEntity.images filteredSetUsingPredicate:predicate];
    
    ShopCartImageEntity *imageEntity = [filterImages anyObject];
    NSParameterAssert(imageEntity);
    
    [imageEntity setUrlLibrary:newUrlLibrary];
    [imageEntity setImportLibrary:[NSNumber numberWithInteger:printImage.imageLibrary]];
    
    ShopCartSettingEntity *settingEntity = [self createEditEntitySetting:printImage.editedImageSetting];
    [imageEntity setImageSetting:settingEntity];
    
    
    
    
    // Update UserTemplate
    ShopCartPropsEntity *propsEntity = printEntity.props;
    ShopTemplateEntity *userTemplateEntity = propsEntity.templateAlbum;
    
    for (ShopLayoutEntity *layoutEntity in userTemplateEntity.layouts) {
        for (ShopImageLayerEntity *imageEntity in layoutEntity.layers) {
            if ([imageEntity.urlPage isEqualToString:printImage.urlLibrary]) {
                [imageEntity setUrlPage:newUrlLibrary];
            }
        }
    }
    
    // Save
    [self.managedObjectContext save:nil];
}



- (void) updateCountPrintData:(PrintData *)printData
{
    ShopCartPrintEntity *printEntity = [[self getPrintEntityUnique:printData.unique_print] firstObject];
    
    NSParameterAssert(printEntity != nil);
    
    [printEntity setCount:[NSNumber numberWithInteger:printData.count]];
    [self.managedObjectContext save:nil];
}



- (void) updateTemplateOrPropsPrintData:(PrintData *)printData
{
    ShopCartPrintEntity *printEntity = [[self getPrintEntityUnique:printData.unique_print] firstObject];
    NSParameterAssert(printEntity);
    
    Template *userTemplate = printData.storeItem.propType.userTemplate;
    ShopCartPropsEntity *propEntity = [self createPropsEntity:printData.props
                                                     andPrice:printData.price
                                              andPropTypeName:printData.storeItem.propType.name
                                              andUserTemplate:userTemplate];
    [printEntity setProps:propEntity];
    
    
    
    // Устанавливаем значения EditSettings
    for (PrintImage *printImage in printData.imagesPreview) {
        EditImageSetting *setting = printImage.editedImageSetting;
        ShopCartSettingEntity *settingEntity = [self createEditEntitySetting:setting];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlLibrary == %@", printImage.urlLibrary];
        ShopCartImageEntity *imageEntity = [[printEntity.images filteredSetUsingPredicate:predicate] anyObject];
        NSParameterAssert(imageEntity != nil);
        [imageEntity setImageSetting:settingEntity];
        
        CGSize standartSize = printImage.originalImageSize;
        CGSize invertSize = CGSizeMake(printImage.originalImageSize.height, printImage.originalImageSize.width);
        [imageEntity setSizeLargeImage:setting.imageOrientation == UIImageOrientationUp || setting.imageOrientation == UIImageOrientationDown ? NSStringFromCGSize(standartSize) : NSStringFromCGSize(invertSize)];
    }
    
    
    [self.managedObjectContext save:nil];
}



- (void)finalCompletePrintData:(PrintData *)printData
{
    ShopCartPrintEntity *printEntity = [self getActivePrintEntity];
    if ([printEntity.unique_print integerValue] == printData.unique_print) {
        [printEntity setProcessInsert:[NSNumber numberWithBool:NO]];
        [self.managedObjectContext save:nil];
    }
}



- (void) savePrepareFinalPrintData:(PrintData *)printData andPrintImage:(PrintImage *)printImage
{
    if (!printData) {
        ShopCartPrintEntity *printEntity = [self getActivePrintEntity];
        printData = [self createPrintDataWithEntity:printEntity andNeedAddImage:NO];
    }
    
    NSParameterAssert(printData);
    NSParameterAssert(printImage);
    
    
    // Обновляем только данные о картинке
    ShopCartImageEntity *imageEntity = [self getPrintImageEntityWithPrintDataUnique:printData.unique_print andUrlLibraryImage:printImage.urlLibrary];
    
    NSParameterAssert(imageEntity);
    
    // Создаем новуюе Setting Entity по параметрам
    ShopCartSettingEntity *settingEntity = [self createEditEntitySetting:printImage.editedImageSetting];
    
    // Обновляем и сохраняем
    [imageEntity setImageSetting:settingEntity];
//    [imageEntity setImagePreview:UIImagePNGRepresentation(printImage.previewImage)];
    [self.managedObjectContext save:nil];
}



- (PrintImage *) saveOriginalImagePrintDataUnique:(NSUInteger)print_unique andPrintImage:(PrintImage *)printImage andSocialImageData:(NSData *)imageData
{
    ShopCartPrintEntity *printEntity = [[self getPrintEntityUnique:print_unique] firstObject];
    if (printEntity == nil) {
        printEntity = [self getActivePrintEntity];
    }
    NSParameterAssert(printEntity);
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlLibrary == %@", printImage.urlLibrary];
    NSSet *filterImages = [printEntity.images filteredSetUsingPredicate:predicate];
    
    
    ShopCartImageEntity *imageEntity = [filterImages anyObject];
    if (!imageEntity) {
        return nil;
    }
    NSParameterAssert(imageEntity);
    
    if ([imageEntity.importLibrary integerValue] == ImageLibrarySocial && imageData == nil) {
        NSLog(@"Error: Social");
    }
    
    NSData *imageAssetData = imageData;
//    if (printImage.imageLibrary == ImageLibraryPhone) {
//        ALAssetRepresentation *rep = printImage.assetImage.defaultRepresentation;
//        Byte *buffer = (Byte*)malloc(rep.size);
//        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
//        imageAssetData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
//        
//        NSInteger maxBiggerSide = 640;
//        UIImage *resizedImage = [[UIImage imageWithCGImage:rep.fullScreenImage] resizeImageToBiggerSide:maxBiggerSide];
//        [imageEntity setImagePreview:UIImagePNGRepresentation(resizedImage)];
//    } else {
//        UIImage *preview = [UIImage imageWithData:imageData];
//        NSInteger maxBiggerSide = 640;
//        UIImage *resizedImage = [preview resizeImageToBiggerSide:maxBiggerSide];
//        [imageEntity setImagePreview:UIImagePNGRepresentation(resizedImage)];
//        [imageEntity setSizeLargeImage:NSStringFromCGSize(preview.size)];
//    }
    
    [imageEntity setImagePreview:imageAssetData];
    
//    [imageEntity setImageLarge:imageAssetData];
    NSLog(@"saveOriginalImagePrint.Size: %@", imageEntity.sizeLargeImage);
    [self.managedObjectContext save:nil];
    
    
    // НЕ забываем добавить оригинальную картинку
//    PrintImage *resultImage = [[self createPrintImagesWithEntity:[NSSet setWithObject:imageEntity]] firstObject];
//    [resultImage addOriginalSocilaImage:[UIImage imageWithData:imageData] orOriginalAsset:printImage.assetImage];
    [printImage updatePreviewImage:[UIImage imageWithData:imageAssetData]];
    return printImage;
}





- (void) addImageWithPrintDataUnique:(NSInteger)unique andImage:(PrintImage *)printImage
{
    ShopCartPrintEntity *printEntity = [[self getPrintEntityUnique:unique] firstObject];
    [printEntity addImages:[self createPrintEntityImages:[NSArray arrayWithObject:printImage]]];
    [self.managedObjectContext save:nil];
}





#pragma mark - Get
- (NSArray *)getAllItemsWithNeedAddImages:(BOOL)needImages
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:SHOP_CART_PRINT_ENTITY inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"fetchError: %@", fetchError);
    }
    
    
    NSMutableArray *array = [NSMutableArray array];
    for (ShopCartPrintEntity *printEntity in result) {
        PrintData *print = [self createPrintDataWithEntity:printEntity andNeedAddImage:needImages];
        [array addObject:print];
    }

    return [array copy];
}





- (PrintData *) getItemImagesWithPrintData:(PrintData *)printData
{
    ShopCartPrintEntity *printEntity = [[self getPrintEntityUnique:printData.unique_print] firstObject];
    printData = [self createPrintDataWithEntity:printEntity andNeedAddImage:YES];
    return printData;
}




//- (PrintImage *) getOriginalImagePrintData:(PrintData *)printData andPrintImage:(PrintImage *)printImage
//{
//    ShopCartPrintEntity *shopPrintEntity = [[self getPrintEntityUnique:printData.unique_print] firstObject];
//    NSParameterAssert(shopPrintEntity);
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlLibrary == %@", printImage.urlLibrary];
//    NSSet *filterImages = [shopPrintEntity.images filteredSetUsingPredicate:predicate];
//    
//    ShopCartImageEntity *imageEntity = [filterImages anyObject];
//    NSParameterAssert(imageEntity);
//    
//    PrintImage *printLargeImage = [self createLargePrintImageWithEntity:imageEntity];
//    return printLargeImage;
//}




- (PrintData *) getUnSavedPrintData
{
    ShopCartPrintEntity *printEntity = [self getActivePrintEntity];
    PrintData *printData = [self createPrintDataWithEntity:printEntity andNeedAddImage:YES];
    return printData.purchaseID == 0 ? nil : printData;
}


- (NSArray *) getUnsavedURLNamesPrintData:(NSInteger)unique
{
    ShopCartPrintEntity *printEntity = [[self getPrintEntityUnique:unique] firstObject];
    if (!printEntity) {
        printEntity = [self getActivePrintEntity];
    }
    if (![printEntity.processInsert boolValue]) {
        return [NSArray array];
    }
    PrintData *printData = [self createPrintDataWithEntity:printEntity andNeedAddImage:YES];
    NSMutableArray *imageNames = [NSMutableArray array];
    for (PrintImage *printImage in printData.imagesPreview) {
        [imageNames addObject:printImage.urlLibrary];
    }
    return [imageNames copy];
}



- (PrintImage *) getPreviewImageWithPrintDataUnique:(NSInteger)unique andPrintImage:(PrintImage *)printImage
{
    UIImage *preview = [self getPreviewImageWithPrintDataUnique:unique andPrintImageUrlLibrary:printImage.urlLibrary];
    [printImage updatePreviewImage:preview];
    return printImage;
}



#pragma mark - Remove
- (void) removeAll
{
    NSArray *objects = [self allObjects];
    
    for (id object in objects) {
        [self.managedObjectContext deleteObject:object];
    }
    
    NSError *error = nil;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Clear.Story.Error: %@", error);
    }
}



-(void)removeImages:(NSArray *)urlLiabraryImages
{
    ShopCartPrintEntity *printEntty = [self getActivePrintEntity];
    NSSet *imageEntitys = printEntty.images;
    
    // Блок сравнения NSSet и urlLiabraryImages
    // Если возвращается YES, картинку нужно удалить, если NO - то не требуется
    BOOL (^ComplateUrlLibraryBlock)(ShopCartImageEntity*, NSArray *) = ^(ShopCartImageEntity *currentEntity, NSArray *urlLibraries){
        for (NSString *urlLibrary in urlLibraries) {
            if ([urlLibrary isEqualToString:currentEntity.urlLibrary]) {
                return YES;
            }
        }
        return NO;
    };
    

    // Remove
    for (ShopCartImageEntity *imageEntity in [imageEntitys allObjects]) {
        if (ComplateUrlLibraryBlock(imageEntity, urlLiabraryImages)) {
            [self.managedObjectContext deleteObject:imageEntity];
        }
    }
}



- (void) removeFromShopCartUnique:(NSInteger)unique withBlock:(void(^)(void))completeBlock;
{
    /*NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:SHOP_CART_PRINT_ENTITY inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unique_print == %i", unique];
    [request setEntity:description];
    [request setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"fetchError: %@", fetchError);
    }*/
    NSArray *result;
    if (unique == 0) {
        ShopCartPrintEntity *printEntity = [self getActivePrintEntity];
        if (printEntity == nil) return;
        result = [NSArray arrayWithObject:printEntity];
    } else {
        result = [self getPrintEntityUnique:unique];
    }
    
    // Remove
    for (ShopCartPrintEntity *printEntity in result) {
        [self.managedObjectContext deleteObject:printEntity];
    }
    
    [self.managedObjectContext save:nil];
    

    // Block
    if (completeBlock) {
        completeBlock();
    }
}



#pragma mark - Private: Prints -> Entity
- (NSSet *) createPrintEntityImages:(NSArray *)images
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (PrintImage *printImage in images) {
        ShopCartImageEntity *imageEntity = [NSEntityDescription insertNewObjectForEntityForName:SHOP_CART_IMAGE_ENTITY inManagedObjectContext:self.managedObjectContext];
        [imageEntity setImagePreview:UIImagePNGRepresentation(printImage.previewImage)];
        [imageEntity setIndex:[NSNumber numberWithInteger:printImage.index]];
        [imageEntity setUnique_image:[NSNumber numberWithInteger:printImage.unique_imageID]];
        [imageEntity setIsMerged:[NSNumber numberWithBool:printImage.isMergedImage]];
        [imageEntity setImageSetting:[self createEditEntitySetting:printImage.editedImageSetting]];
        [imageEntity setImportLibrary:[NSNumber numberWithInteger:printImage.imageLibrary]];
        [imageEntity setUrlLibrary:printImage.urlLibrary];
        [imageEntity setSizeLargeImage:NSStringFromCGSize(printImage.originalImageSize)];
        [array addObject:imageEntity];
    }
    
    return [NSSet setWithArray:array];
}


- (ShopCartSettingEntity *) createEditEntitySetting:(EditImageSetting *)editSetting
{
    ShopCartSettingEntity *settingEntity = [NSEntityDescription insertNewObjectForEntityForName:SHOP_CART_EDIT_SETTING_ENTITY inManagedObjectContext:self.managedObjectContext];
    [settingEntity setFilterName:editSetting.filterName];
    [settingEntity setSaturation:[NSNumber numberWithFloat:editSetting.saturationValue]];
    [settingEntity setBrightness:[NSNumber numberWithFloat:editSetting.brightnessValue]];
    [settingEntity setConstast:[NSNumber numberWithFloat:editSetting.contrastValue]];
    [settingEntity setOrientation:[NSNumber numberWithInteger:editSetting.imageOrientation]];
    [settingEntity setOrientationDefault:[NSNumber numberWithInteger:editSetting.imageDefaultOrientation]];
    [settingEntity setCrop:NSStringFromCGRect(editSetting.cropRect)];//[NSString stringWithFormat:@"%@",[NSDictionary dictionaryFromCGRect:editSetting.cropRect]]];
    return settingEntity;
}


- (ShopCartPropsEntity *) createPropsEntity:(NSDictionary *)props andPrice:(NSInteger)price andPropTypeName:(NSString *)typeName andUserTemplate:(Template *)userTemplate
{
    NSString *cover = [props objectForKey:@"cover"];
    NSString *color = [props objectForKey:@"color"];
    NSString *size = [props objectForKey:@"size"];
    NSString *style = [props objectForKey:@"style"];
    NSString *type = typeName;
    NSString *uturn = [props objectForKey:@"uturn"];
    
    ShopCartPropsEntity *propEntity = [NSEntityDescription insertNewObjectForEntityForName:SHOP_CART_PROPS_ENTITY inManagedObjectContext:self.managedObjectContext];
    [propEntity setSize:size];
    [propEntity setStyle:style];
    [propEntity setCover:cover];
    [propEntity setColor:color];
    [propEntity setType:type];
    [propEntity setUturn:uturn];
    [propEntity setPrice:[NSNumber numberWithInteger:price]];
    [propEntity setTemplateAlbum:[self createTemplateEntityWithTemplate:userTemplate]];
    [self.managedObjectContext save:nil];
    return propEntity;
}



- (ShopTemplateEntity *) createTemplateEntityWithTemplate:(Template *)userTemplate
{
    ShopTemplateEntity *templateEntity = [NSEntityDescription insertNewObjectForEntityForName:SHOP_CART_TEMPLATE_ENTITY inManagedObjectContext:self.managedObjectContext];
    [templateEntity setFont:userTemplate.fontName];
    [templateEntity setName_template:userTemplate.name];
    [templateEntity setId_template:userTemplate.id_template];
    [templateEntity setSize_template:userTemplate.size];
    
    NSSet *layouts = [self createLayoutEntitysWithLayouts:userTemplate.layouts];
    [templateEntity addLayouts:layouts];
    
    return templateEntity;
}


- (NSSet *) createLayoutEntitysWithLayouts:(NSArray *)layouts
{
    NSMutableSet *mutablelayouts = [NSMutableSet set];
    
    for (Layout *layout in layouts) {
        ShopLayoutEntity *layoutEntity = [NSEntityDescription insertNewObjectForEntityForName:SHOP_CART_LAYOUT_ENTITY inManagedObjectContext:self.managedObjectContext];
        [layoutEntity setId_layout:layout.id_layout];
        [layoutEntity setLayoutType:layout.layoutType];
        [layoutEntity setTemplate_psd:layout.template_psd];
        [layoutEntity setPageIndex:[NSNumber numberWithInteger:layout.pageIndex]];
        [layoutEntity setCombinedLayer:[self createPlaceHolderEntityWithPlaceHolder:layout.combinedLayer]];
        [layoutEntity setNoScaleCombined:NSStringFromCGRect(layout.noscaleCombinedLayer)];
        
        
        NSArray *back = [self createLayerImageEntityWithImages:[NSArray arrayWithObject:layout.backLayer.image] andLayerTypeImage:AlbumTypeBackImage];
        NSArray *front = [self createLayerImageEntityWithImages:[NSArray arrayWithObject:layout.frontLayer.image] andLayerTypeImage:AlbumTypeFrontImage];
//        NSArray *clear = [self createLayerImageEntityWithImages:[NSArray arrayWithObject:layout.clearLayer.image] andLayerTypeImage:AlbumTypeClearImage];
        
        NSArray *backImages = [self createLayerImageEntityWithImages:layout.backLayer.images andLayerTypeImage:AlbumBackImages];
        NSArray *frontImages = [self createLayerImageEntityWithImages:layout.frontLayer.images andLayerTypeImage:AlbumFrontImages];
        
        NSMutableSet *set = [NSMutableSet set];
        [set addObjectsFromArray:back];
        [set addObjectsFromArray:front];
//        [set addObjectsFromArray:clear];
        [set addObjectsFromArray:backImages];
        [set addObjectsFromArray:frontImages];
        [layoutEntity addLayers:[set copy]];
        
        [mutablelayouts addObject:layoutEntity];
    }
    
    
    return [mutablelayouts copy];
}


- (NSArray *) createLayerImageEntityWithImages:(NSArray *)images andLayerTypeImage:(AlbumTypeImage)layerTypeImage
{
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    for (Image *image in images) {
        ShopImageLayerEntity *layerEntity = [NSEntityDescription insertNewObjectForEntityForName:SHOP_CART_IMAGELAYER_ENTITY inManagedObjectContext:self.managedObjectContext];
        [layerEntity setLayerType:[NSNumber numberWithInteger:layerTypeImage]];
        [layerEntity setPixelLimit:[NSNumber numberWithInteger:[image.pixelsLimit integerValue]]];
        [layerEntity setPixelMin:[NSNumber numberWithInteger:[image.pixelsMin integerValue]]];
        [layerEntity setZ:image.z];
        [layerEntity setRect:NSStringFromCGRect(image.rect)/*[self getStringRectWithPosition:image.rect]*/];
        [layerEntity setCrop:NSStringFromCGRect(image.crop)/*[self getStringRectWithPosition:image.crop]*/];
        [layerEntity setImage:UIImagePNGRepresentation(image.image)];
        [layerEntity setUrlPage:image.url_image];
        [layerEntity setOrientation:[NSNumber numberWithInteger:image.orientation]];
        [layerEntity setOrientationDefault:[NSNumber numberWithInteger:image.orientationDefault]];
        
        [mutableArray addObject:layerEntity];
    }
    
    return [mutableArray copy];
}



- (ShopPlaceHolderEntity *) createPlaceHolderEntityWithPlaceHolder:(PlaceHolder *)placeHolder
{
    ShopPlaceHolderEntity *placeHoderEntity = [NSEntityDescription insertNewObjectForEntityForName:SHOP_CART_PLACEHOLDER_ENTITY inManagedObjectContext:self.managedObjectContext];
    [placeHoderEntity setPsdPath:placeHolder.psdPath];
    [placeHoderEntity setLayerNum:placeHolder.layerNum];
    [placeHoderEntity setPngPath:placeHolder.pngPath];
    [placeHoderEntity setRect:NSStringFromCGRect(placeHolder.rect)];
    return placeHoderEntity;
}



#pragma mark - Private: Entity -> Print
/*! Создаем PrintData из ShopCartPrintEntity и выбыием добавлять ли картинки
 *@param printEntity текущая сущноть Entity
 *@param needAddImage нужно ли добавлять картинки, YES - нужно, No - Не требуется. если будет YES, то дольше времени на ответ
 *@return Возвращаем printData
 */
- (PrintData *) createPrintDataWithEntity:(ShopCartPrintEntity *)printEntity andNeedAddImage:(BOOL)needAddImage
{
    NSString *purchaseID = [NSString stringWithFormat:@"%li", (long)[printEntity.purchaseID integerValue]];
    PropType *propType = [self createPtopTypeWithEntity:printEntity.props andPurchaseId:purchaseID];
    StoreItem *storeitem = [[StoreItem alloc] initStoreWithPurchaseID:[NSString stringWithFormat:@"%li", (long)[printEntity.purchaseID integerValue]]
                                                         andTypeStore:@""
                                                  andDescriptionStory:@""
                                                      andNamePurchase:printEntity.namePurchase
                                                        andCategoryID:@""
                                                      andCategoryName:printEntity.nameCategory
                                                         andAvailable:YES
                                                             andTypes:[NSArray arrayWithObject:propType]];
    
    PrintData *print = [[PrintData alloc] initWithStoreItem:storeitem andUniqueNum:[printEntity.unique_print integerValue]];
    [print changeCount:[printEntity.count integerValue]];
    if (needAddImage) {
        [print addPrintImagesFromPhotoLibrary:[self createPrintImagesWithEntity:printEntity.images]];
    }
    return print;
}


- (PropType *) createPtopTypeWithEntity:(ShopCartPropsEntity *)propEntity andPurchaseId:(NSString *)purchaseID
{
    Template *aTemplate = [self createTemplateWithEntityTemplates:propEntity.templateAlbum];
    
    // Block поиска PropType в CoreDataStore.h
    // Требуется, в основном для альбомов, при возврате Конструктор -> Конфигуратор
    // Чтобы были доступны другие размеры и стили
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    NSArray *propTypes = [coreStore getTypesWithPurchaseID:purchaseID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", propEntity.type];
    PropType *storePropType = (PropType *)[[[propTypes mutableCopy] filteredArrayUsingPredicate:predicate] firstObject];
    
    PropType *propType = [[PropType alloc] initTypeName:propEntity.type
                                               andPrice:[propEntity.price integerValue]
                                            andSizeName:propEntity.size
                                           andUturnName:propEntity.uturn
                                           andCoverName:propEntity.cover
                                           andColorName:propEntity.color
                                           andStyleName:propEntity.style
                                        andUserTemplate:aTemplate
                                               andSizes:storePropType.sizes
                                              andUturns:storePropType.uturns
                                              andCovers:storePropType.covers
                                              andColors:storePropType.colors
                                              andStyles:storePropType.styles];
    return propType;
}



- (NSArray *) createPrintImagesWithEntity:(NSSet *)images
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (ShopCartImageEntity *imageEntity in [images allObjects]) {
        EditImageSetting *editSetting = [self createEdtSettingWithEntity:imageEntity.imageSetting];
        PrintImage *image;
        if ([imageEntity.isMerged boolValue]) {
            image = [[PrintImage alloc] initMergeImage:[UIImage imageWithData:imageEntity.imagePreview] withName:imageEntity.urlLibrary andUploadUrl:imageEntity.uploadURL];
        } else {
           image = [[PrintImage alloc] initWithPreviewImage:[UIImage imageWithData:imageEntity.imagePreview]
                                                   withName:imageEntity.urlLibrary
                                             andEditSetting:editSetting
                                               originalSize:CGSizeFromString(imageEntity.sizeLargeImage) andUploadUrl:imageEntity.uploadURL];
        }
        [image setImageLibrary:(ImageLibrary)[imageEntity.importLibrary integerValue]];
        [array addObject:image];
    }
    
    return [array copy];
}



//- (PrintImage *) createLargePrintImageWithEntity:(ShopCartImageEntity *)imageEntity
//{
//    EditImageSetting *editSetting = [self createEdtSettingWithEntity:imageEntity.imageSetting];
//    
//    PrintImage *printImage;
//    if ([imageEntity.isMerged boolValue]) {
//        printImage = [[PrintImage alloc] initMergeImage:[UIImage imageWithData:imageEntity.imagePreview] withName:imageEntity.urlLibrary];
//    }
//    else {
//        NSData *imageData = [imageEntity.isMerged boolValue] ? imageEntity.imagePreview : imageEntity.imageLarge;
//        printImage = [[PrintImage alloc] initLargeImageData:imageData
//                                            andPreviewImage:[editSetting isDidEditing] ? [UIImage imageWithData:imageEntity.imagePreview] : nil
//                                                   withName:imageEntity.urlLibrary
//                                             andEditSetting:editSetting];
//    }
//
//    //
//    [printImage setImageLibrary:(ImageLibrary)[imageEntity.importLibrary integerValue]];
//    
//    return printImage;
//}



- (EditImageSetting *) createEdtSettingWithEntity:(ShopCartSettingEntity *)settingEntity
{
    EditImageSetting *setting = [[EditImageSetting alloc] initFilterName:settingEntity.filterName
                                                           andSaturation:[settingEntity.saturation floatValue]
                                                           andBrightness:[settingEntity.brightness floatValue]
                                                             andContrast:[settingEntity.constast floatValue]
                                                             andCropRect:CGRectFromString(settingEntity.crop)//[NSDictionary getCGRectWithString:settingEntity.crop]
                                                        andRectToVisible:CGRectZero
                                                  andAutoResizingEnabled:NO
                                                     andImageOrientation:[settingEntity.orientation integerValue]
                                              andImageDefautlOrientation:[settingEntity.orientationDefault integerValue]];
    
    return setting;
}


- (Template *) createTemplateWithEntityTemplates:(ShopTemplateEntity *)templateEntity
{
//    NSMutableArray *templates = [NSMutableArray array];
//    for (ShopTemplateEntity *templateEntity in [entityTemplates allObjects]) {
        NSArray *layouts = [self createLayoutsWithEntityLayouts:templateEntity.layouts];
        Template *template = [[Template alloc] initTemplateName:templateEntity.name_template
                                                    andFontName:templateEntity.font
                                                  andIdTemplate:templateEntity.id_template
                                                        andSize:templateEntity.size_template
                                                     andLayouts:layouts];
//        [templates addObject:template];
//    }
    
    return template;//[templates copy];
}


- (NSArray *) createLayoutsWithEntityLayouts:(NSSet *)entitylayouts
{
    NSMutableArray *layouts = [NSMutableArray array];
    
    for (ShopLayoutEntity *layoutEntity in [entitylayouts allObjects]) {
        Layer *backLayer    = [self createLayerWithLayerImageEntitys:layoutEntity.layers withType:AlbumTypeBackImage];
        Layer *frontLayer   = [self createLayerWithLayerImageEntitys:layoutEntity.layers withType:AlbumTypeFrontImage];
        Layer *clearLayer   = [self createLayerWithLayerImageEntitys:layoutEntity.layers withType:AlbumTypeClearImage];
        PlaceHolder *combinedLayer = [self createPlaceHolderWithEntity:layoutEntity.combinedLayer];
        Layout *layout = [[Layout alloc] initLayoutWithID:layoutEntity.id_layout
                                            andLayoutType:layoutEntity.layoutType
                                           andtemplatePSD:layoutEntity.template_psd
                                             andBackLayer:backLayer
                                            andFlontLayer:frontLayer
                                            andClearLayer:clearLayer
                                             andPageIndex:[layoutEntity.pageIndex integerValue]
                                         andCombinedLayer:combinedLayer
                                  andNoscaleCombinedLayer:CGRectFromString(layoutEntity.noScaleCombined)];
        [layouts addObject:layout];
    }
    
    // Sort
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pageIndex" ascending:YES];
    NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
    NSArray *final = [layouts sortedArrayUsingDescriptors:descriptors];
    
    return final;
}

- (Layer *) createLayerWithLayerImageEntitys:(NSSet *)layerImageEntitys withType:(AlbumTypeImage )albumType
{
    Image *back;
    NSArray *backImages;
    
    switch (albumType) {
        case AlbumTypeBackImage:
            back = [[self createImagesWithLayerImageEntitys:layerImageEntitys andLayerTypeImage:AlbumTypeBackImage] firstObject];
            backImages = [self createImagesWithLayerImageEntitys:layerImageEntitys andLayerTypeImage:AlbumBackImages];
            break;
            
        case AlbumTypeFrontImage:
            back = [[self createImagesWithLayerImageEntitys:layerImageEntitys andLayerTypeImage:AlbumTypeFrontImage] firstObject];
            backImages = [self createImagesWithLayerImageEntitys:layerImageEntitys andLayerTypeImage:AlbumFrontImages];
            break;
            
        case AlbumTypeClearImage:
            back = [[self createImagesWithLayerImageEntitys:layerImageEntitys andLayerTypeImage:AlbumTypeClearImage] firstObject];
            backImages = [NSArray array];
            break;
            
        default:
            break;
    }
    
    //
    Layer *layer = [[Layer alloc] initWithImage:back andImages:backImages];
    return layer;
}


// Возвращаем массив картинок пользовательских
- (NSArray *) createImagesWithLayerImageEntitys:(NSSet *)layerImageEntitys andLayerTypeImage:(AlbumTypeImage)layerTypeImage
{
    NSPredicate *predacate = [NSPredicate predicateWithFormat:@"layerType == %i", layerTypeImage];
    NSSet *result = [layerImageEntitys filteredSetUsingPredicate:predacate];
    
    
    NSMutableArray *final = [NSMutableArray array];
    for (ShopImageLayerEntity *layerEntity in [result allObjects]) {
        Image *image = [[Image alloc] initWithPixelsMin:[NSString stringWithFormat:@"%li", (long)[layerEntity.pixelMin integerValue]]
                                         andPixelsLimit:[NSString stringWithFormat:@"%li",(long)[layerEntity.pixelLimit integerValue]]
                                                   andZ:[NSString stringWithFormat:@"%li",(long)[layerEntity.z  integerValue]]
                                            andUrlImage:layerEntity.urlPage
                                           andUrlUpload:layerEntity.urlUpload
                                           andPermanent:@"1"
                                                andRect:CGRectFromString(layerEntity.rect)//[self getPositionWithStringRect:layerEntity.rect]
                                                andCrop:CGRectFromString(layerEntity.crop)//[self getPositionWithStringRect:layerEntity.crop]
                                               andImage:[UIImage imageWithData:layerEntity.image]
                                    andImageOrientation:(UIImageOrientation)[layerEntity.orientation integerValue]
                             andImageOrientationDefault:(UIImageOrientation)[layerEntity.orientationDefault integerValue]];
        [final addObject:image];
    }
    
    return [final copy];
}


- (PlaceHolder *) createPlaceHolderWithEntity:(ShopPlaceHolderEntity *)placeHoderEntity
{
    PlaceHolder *placeHolder = [[PlaceHolder alloc] initWithPsdPath:placeHoderEntity.psdPath
                                                        andLayerNum:placeHoderEntity.layerNum
                                                         andPngPath:placeHoderEntity.pngPath
                                                     andScalePngUrl:@""
                                                            andRect:CGRectFromString(placeHoderEntity.rect)];
    return placeHolder;
}



#pragma mark - Private
/*! Получаем ShopPrintEntity
 *@return возвращаем массив PrintDataEntity's, в большинстве случаев здесь 1 элемент
 */
- (NSArray *) getPrintEntityUnique:(NSInteger)unique
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:SHOP_CART_PRINT_ENTITY inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"unique_print == %i", unique];
    [request setEntity:description];
    [request setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"fetchError: %@", fetchError);
    }
    
    
    NSMutableArray *array = [NSMutableArray array];
    for (ShopCartPrintEntity *print in result) {
        [array addObject:print];
    }
    
    return [array copy];
}


/*! Получаем ShopCartEntity
 *@return возвращаем текущую PrintDataEntity
 */
- (ShopCartPrintEntity *) getActivePrintEntity
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *description = [NSEntityDescription entityForName:SHOP_CART_PRINT_ENTITY inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"processInsert == YES"];
    [request setEntity:description];
    [request setPredicate:predicate];
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"fetchError: %@", fetchError);
    }
    
    for (ShopCartPrintEntity *print in result) {
        if ([print.processInsert boolValue]) {
            return print;
        }
    }
    
    return nil;
}




/*! Получаем картинку по НЕ сохраненной PrintData и PrintImage
 *@param unique уникальный идентификатор, может быть 0, то будем искать по не сохраненному
 *@param urlLibrary адрес картинки, содержит адрес из соц.сети или адрес в библиотеке телефона
 *@return возвращаем картинку Preview
 */
- (UIImage *) getPreviewImageWithPrintDataUnique:(NSInteger)unique andPrintImageUrlLibrary:(NSString *)urlLibrary
{
    ShopCartPrintEntity *shopPrintEntity = unique == 0 ? [self getActivePrintEntity] : [[self getPrintEntityUnique:unique] firstObject];
    NSParameterAssert(shopPrintEntity);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlLibrary == %@", urlLibrary];
    NSSet *filterImages = [shopPrintEntity.images filteredSetUsingPredicate:predicate];
    
    ShopCartImageEntity *imageEntity = [filterImages anyObject];
    NSParameterAssert(imageEntity);
    
    
    return [UIImage imageWithData:imageEntity.imagePreview];
}





/*! Получаем PrintImageEntity по unique и Адресу картинки
 *@param unique уникальный идентификатор, созданный при создании PrintData
 *@param urlLibrary адрес картинки в библиотеке или URL адрес с соц.сетей
 *@return возвращаем картинку из базы
 */
- (ShopCartImageEntity *) getPrintImageEntityWithPrintDataUnique:(NSInteger)unique andUrlLibraryImage:(NSString *)urlLibrary
{
    // Ищем по уникальному, если не находим, то берез активный PrintEntity
    // Убрал, т.к тесты в некоторых случаях не проходит
    ShopCartPrintEntity *activePrint = /*[self getPrintEntityUnique:unique].count == 0 ?*/ [self getActivePrintEntity]/* : [[self getPrintEntityUnique:unique] firstObject]*/;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlLibrary == %@ AND isMerged == NO", urlLibrary];
    NSSet *images = [activePrint.images filteredSetUsingPredicate:predicate];

    
    for (ShopCartImageEntity *imgEntity in images) {
        return imgEntity;
    }
    
    return nil;
}




- (void) removeMergedPrintImagesWithPrintDataUnique:(NSInteger)unique
{
    ShopCartPrintEntity *printEntity = [[self getPrintEntityUnique:unique] firstObject];
    for (ShopCartImageEntity *imageEntity in printEntity.images) {
        if ([imageEntity.isMerged boolValue]) {
            [self.managedObjectContext deleteObject:imageEntity];
        }
    }
}



- (void) removeActiveProcess
{
    ShopCartPrintEntity *printEntity = [self getActivePrintEntity];
    if (printEntity == nil) {
        return;
    }
    [self.managedObjectContext deleteObject:printEntity];
    [self.managedObjectContext save:nil];
}






- (NSArray*) allObjects {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *desription = [NSEntityDescription entityForName:SHOP_CART_PRINT_ENTITY inManagedObjectContext:self.managedObjectContext];
    [request setEntity:desription];
    
    NSError *fetchError = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        NSLog(@"Fetch.Error: %@", fetchError);
    }
    
    return result;
}

//- (NSString *) getStringRectWithPosition:(Position *)position
//{
//    CGRect rect = CGRectMake(position.left,
//                             position.top,
//                             position.right,
//                             position.bottom);
//    return NSStringFromCGRect(rect);
//}
//
//- (Position *) getPositionWithStringRect:(NSString *)rectString
//{
//    CGRect rect = CGRectFromString(rectString);
//    Position *position = [[Position alloc] initPositionWithRect:rect];
//    return position;
//}


@end
