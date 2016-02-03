//
//  UploadImageManager.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/24/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "UploadImageManager.h"
#import "UploadOperation.h"

#import "PrintData.h"
#import "PrintImage.h"

#import "CoreDataShopCart.h"

typedef enum {
    UploadAllow,
    UploadDeny
} UploadSwitch;

@interface UploadImageManager () <UploadOperationDelegate>
@property (strong, nonatomic) NSArray *printsDatas;
@property (assign, nonatomic) NSInteger currentUploadNum;
@property (strong, nonatomic) NSArray *queues;
@property (assign, nonatomic) UploadSwitch uploadSwitch;
@end



@implementation UploadImageManager
- (id) initShopCartPrintDatas:(NSArray *)printDatas
{
    self = [super init];
    if (self) {
        self.printsDatas = printDatas;
        self.currentUploadNum = 0;
        
        [self prepareToUpload];
    }
    return self;
}




- (void) prepareToUpload
{
    NSMutableArray *queues = [NSMutableArray array];
    
    
    // Create Operation
    for (PrintData *printData in self.printsDatas) {
        for (PrintImage *printImage in printData.images) {
            if (!printImage.uploadURL.absoluteString) {
                UploadOperation *operation = [[UploadOperation alloc] initSaveWithPrintData:printData andCurrentPrintImage:printImage andDelegate:nil];
                [queues addObject:operation];
            }
        }
    }
    
    self.queues = [queues copy];
}


- (void) startUpload
{
    if (self.queues.count == 0) {
        [self.delegate uploadImageManager:self didAllImagesSaved:nil];
        return;
    }
    
    UploadOperation *operation = [self.queues objectAtIndex:self.currentUploadNum];
    [operation setDelegate:self];
    [operation upload];
    
    self.currentUploadNum++;
    
    
    CGFloat mainProgress = (float)self.currentUploadNum / (float)self.queues.count;
    [self.delegate uploadImageManager:self didUploadAllImagesProgress:mainProgress];
}


- (void) stopUpload
{
    self.uploadSwitch = UploadDeny;
    
    if (self.queues.count == 0) {
        [self.delegate uploadImageManager:self didCancelUpload:nil];
    }
}


#pragma mark - UploadOperationDelegate
-(void)uploadOperation:(UploadOperation *)operation didUploadComplete:(PrintImage *)printImage andPrintData:(PrintData *)printData
{
    //
    [operation setDelegate:nil];
    
    // Костыль, присваиваем значения
//    for (PrintData *data in self.printsDatas) {
//        for (PrintImage *img in printData.images) {
//            if ([img.urlLibrary isEqualToString:printImage.urlLibrary] && data.unique_print == printData.unique_print) {
//                //NSLog(@"%@", img);
//                img.uploadURL = printImage.uploadURL;
//            }
//        }
//    }
    
    if (self.uploadSwitch == UploadDeny) {
        [self.delegate uploadImageManager:self didCancelUpload:printData];
        return;
    }
    
    // Проверям все ли загрузили
    if (self.currentUploadNum >= self.queues.count) {
        // Проверяем все ли загрузилось
        NSLog(@"Finish");
        [self prepareToUpload];
        if (self.queues.count > 0) {
            self.currentUploadNum = 0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startUpload];
            });
            
        } else {
            [self.delegate uploadImageManager:self didAllImagesSaved:nil];
        }
    } else {
        [self startUpload];
    }
}


-(void)uploadOperation:(UploadOperation *)operation didUploadProgress:(CGFloat)progress
{
    [self.delegate uploadImageManager:self didUploadProgress:progress];
}


-(void)uploadOperation:(UploadOperation *)operation didAddToSendPreviewPrintImage:(PrintImage *)printImage andPrintData:(PrintData *)printData
{
    // Save ShopCart
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop addImageWithPrintDataUnique:printData.unique_print andImage:printImage];
    
    
    
    // Add In PrintData
    for (PrintData *pData in self.printsDatas) {
        if (pData.unique_print == printData.unique_print) {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:pData.images];
            [arr addObject:printImage];
            [pData addPrintImagesFromPhotoLibrary:[arr copy]];
            
            // Add Operation
            UploadOperation *oper = [[UploadOperation alloc] initSaveWithPrintData:pData andCurrentPrintImage:printImage andDelegate:self];
            self.queues = [self.queues arrayByAddingObject:oper];
        }
    }
}

@end
