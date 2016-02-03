//
//  SaveOperation.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/10/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "SaveOperation.h"

#import "PrintData.h"
#import "PrintImage.h"

#import "CoreDataShopCart.h"
#import "CoreDataSocialImages.h"

#import "MDPhotoLibrary.h"

#import "UIImage+Crop.h"
#import "UIImage+Additions.h"


@interface SaveOperation ()
@property (strong, nonatomic) PrintData *printData;
@end

@implementation SaveOperation
- (id) initSaveWithPrintData:(PrintData *)printData andCurrentPrintImage:(PrintImage *)printImage andDelegate:(id<SaveOperationDelegate>)delegate
{
    self = [super init];
    if (self) {
        _printData = printData;
        _printImage = printImage;
        _delegate = delegate;
    }
    return self;
}

-(void)startSave
{
    __weak SaveOperation *wSelf = self;

    NSLog(@"SaveOperation.main");
//    @autoreleasepool {
        NSLog(@"main: %@", self.printImage.urlLibrary);
    
//    __weak SaveOperation *weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"TimeOut Dispatch: Finished: %hhd; \nCanceled: %hhd", weakSelf.isFinished, weakSelf.isCancelled);
//        
//    });
    
//    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];

//    CoreDataSocialImages *coreSocial = [[CoreDataSocialImages alloc] init];
//    NSLog(@"SaveOperation.readSocial");
//    NSData *socialImage = [coreSocial getImageDataWithURL:_printImage.urlLibrary];
    
    
//    if (self.isCancelled) {
//        return;
//    }
    
    [self setCompletionBlock:^{
        [wSelf waitUntilFinished];
    }];
//    }
}

-(void)waitUntilFinished {
    NSLog(@"SaveOperation.dispatch");
    __weak SaveOperation *wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"finish %@", wSelf.printImage.urlLibrary);
        [self.delegate saveOperation:self didSavedImage:wSelf.printImage];
    });
}



-(void)setCompletionBlock:(void (^)(void))completionBlock {
    
    /// Блок окончания всех действий
    void (^CompleteBlock)(void) = ^{
        if (completionBlock) {
            completionBlock();
        }
    };
    
//    __weak SaveOperation *wSelf = self;
    /// Преобразования картинки из оригинальной, до минимальной
    void (^MakePreviewImageBlock)(NSData *imageData, UIImageOrientation orientation) = ^(NSData *imageData, UIImageOrientation orientation) {
        
        UIImage *imageOriginal = [UIImage imageWithData:imageData];
        
        NSInteger const maxBiggerSide = 640;
        UIImage *resizedImage = [[UIImage imageWithCGImage:imageOriginal.CGImage] resizeImageToBiggerSide:maxBiggerSide];
        UIImage *normalImageOrientation = [UIImage imageWithCGImage:resizedImage.CGImage scale:resizedImage.scale orientation:orientation];
        NSData *imagePreviewData = UIImageJPEGRepresentation(normalImageOrientation, 0.6f);
        
        [self.printImage.editedImageSetting changeOrientation:orientation];
        [self.printImage.editedImageSetting changeOrientationDefault:orientation];
        
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        [coreShop saveOriginalImagePrintDataUnique:self.printData.unique_print andPrintImage:self.printImage andSocialImageData:imagePreviewData];
        CompleteBlock();
    };
    
    
    // Читаем данные из сохраненных картинок соц.сетей
    if (self.printImage.imageLibrary == ImageLibrarySocial) {
        NSLog(@"SaveOperation.readSocial");
        CoreDataSocialImages *coreSocial = [[CoreDataSocialImages alloc] init];
        NSData *socialImage = [coreSocial getImageDataWithURL:_printImage.urlLibrary];
        MakePreviewImageBlock(socialImage, UIImageOrientationUp);
        
    } else {
        /// Библиотека
        MDPhotoLibrary *lib = [[MDPhotoLibrary alloc] init];
        [lib getAssetWithURL:self.printImage.urlLibrary withResultBlock:^(NSData *imageData, UIImageOrientation orientation) {
            MakePreviewImageBlock(imageData, orientation);
//            UIImage *imageOriginal = [UIImage imageWithData:imageData];
//            NSInteger const maxBiggerSide = 640;
//            UIImage *resizedImage = [[UIImage imageWithCGImage:imageOriginal.CGImage] resizeImageToBiggerSide:maxBiggerSide];
//            NSData *imagePreviewData = UIImageJPEGRepresentation(resizedImage, 0.6f);

            
        } failBlock:^(NSError *error) {
            CompleteBlock();
        }];
    }
}



@end
