//
//  UploadOperation.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/24/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "UploadOperation.h"
#import "PropType.h"
#import "PrintData.h"
#import "PrintImage.h"
#import "EditImageSetting.h"

#import "CoreDataShopCart.h"
#import "PHouseApi.h"

#import "FilterImageManager.h"
#import "DeviceManager.h"

#import "UIImage+Crop.h"

#import "MDPhotoLibrary.h"

@interface UploadOperation () <FilterImageManagerDelegate>
@property (strong, nonatomic) PrintData *printData;
@property (strong, nonatomic) PrintImage *printImage;

//@property (strong, nonatomic) PrintImage *large;
@end


@implementation UploadOperation
-(id)initSaveWithPrintData:(PrintData *)printData andCurrentPrintImage:(PrintImage *)printImage andDelegate:(id<UploadOperationDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.printData = printData;
        self.printImage = printImage;
        self.delegate = delegate;
    }
    
    return self;
}


-(void)upload
{
//    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
//    PrintImage *image = [coreShop getOriginalImagePrintData:_printData andPrintImage:_printImage];
//    EditImageSetting *setting = image.editedImageSetting;
    
    // Если картинка НЕ кленная && картинка РЕДАКТИРОВАЛАСЬ && Размеры больше 2500 хоть по одно стороне
//    if (!image.isMergedImage && setting.isDidEditing && (image.originalImageSize.width > 2500 || image.originalImageSize.height > 2500)) {
//        // Отправляем не редактированный оригинал
//        [self startUploadProcessing:self.printImage];
//    }
//    if (image.imageLargeData == nil) {
//        image = self.printImage;
//        //[self.delegate uploadOperation:self didUploadComplete:image andPrintData:_printData];
//    }
    
    PrintImage *image = self.printImage;
    NSLog(@"PrintImage: Size: %@; isEdit: %@; isMerge: %@", NSStringFromCGSize(image.originalImageSize), image.isDidEdited ? @"YES" : @"NO", image.isMergedImage ? @"YES" : @"NO");
    
//    DeviceManager *device = [[DeviceManager alloc] init];
//    NSUInteger const MAX_IMAGE_SIZE = [self getMaxImageSide:[device getDeviceName]];
    
    // Если конструкторский альбом, то применяем фильтр по любому
//    if ([self.printData.storeItem.propType.name isEqualToString:TypeNameConstructor]) {
//        [self applyFilter:image];
//    }
//    
//    // Картинка скленная
//    else if (image.isMergedImage || !image.isDidEdited)
//    {
//        [self startUploadProcessing:image];
//    }
//    // Картинка редактирована и одна из сторон меньше MAX_IMAGE_SIZE
//    else if (setting.isDidEditing/* && (image.originalImageSize.width < MAX_IMAGE_SIZE || image.originalImageSize.height < MAX_IMAGE_SIZE)*/)
//    {
//        [self applyFilter:image];
//    } else {
//        NSLog(@"Error");
//    }
    
    // Редактировалась ли картинка
    if (![image isDidEdited]) {
        // Нет НЕ редактировалась
        [self startUploadProcessing:image];
        
    } else {
        // Редактировалась
        [self applyFilter:image];
    }
}



//- (void) parse:(NSString *)urlImage {
//    //
//    [self.printImage updateUploadUrl:urlImage withPrintDataUnique:self.printData.unique_print];
//    
//    //
//    [self.delegate uploadOperation:self didUploadComplete:_printImage andPrintData:_printData];
//}


- (void) startUploadProcessing:(PrintImage *)printImage {
    // Отправка
    PHouseApi *api = [[PHouseApi alloc] init];
    [api uploadImageFromPrintImage:printImage andCompleteBlockSuccess:^(NSString *responseURL) {
        // Complete
        NSLog(@"Uplad.Complete: %@", responseURL);
        [self.printImage updateUploadUrl:responseURL withPrintDataUnique:self.printData.unique_print];
        
        //
        [self.delegate uploadOperation:self didUploadComplete:_printImage andPrintData:_printData];
        
    } andUpdateProgress:^(CGFloat progress) {
        // Progress
        //NSLog(@"Progress: %f", progress);
        [self.delegate uploadOperation:self didUploadProgress:progress];
    } andErrorBlockFail:^(NSError *error) {
        // Error
        NSLog(@"Error.UplaodOperation: %@", error);
        [self.delegate uploadOperation:self didUploadComplete:_printImage andPrintData:_printData];
    }];
}


- (void) applyFilter:(PrintImage *)printImage
{
    FilterImageManager *manager = [[FilterImageManager alloc] initWithPrintDataUnique:self.printData.unique_print andPrintImage:printImage andDelegate:self];
    [manager apply];
}

#pragma mark - FilterImageManagerDelegate
-(void)filterImageManager:(FilterImageManager *)manager didApplyImage:(PrintImage *)printImage
{
    [manager setDelegate:nil];
    [self startUploadProcessing:printImage];
}

#pragma mark - Device
/// Возвращаем максимально возможный размер фотографии для текущего устройства, чтобы не упало приложение
- (NSUInteger) getMaxImageSide:(NSString *)deviceName {
    NSUInteger side = 2500;
    
    if ([deviceName isEqualToString:IPHONE4]) {
        side = 2500;
    } else if ([deviceName isEqualToString:IPHONE5]) {
        side = 3500;
    } else {
        side = 4500;
    }
    
    return side;
}

@end
