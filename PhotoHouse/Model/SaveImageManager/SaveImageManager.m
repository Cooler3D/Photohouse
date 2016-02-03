//
//  SaveImageManager.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/10/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "SaveImageManager.h"

#import "PrintData.h"
#import "PrintImage.h"
#import "EditImageSetting.h"

#import "SaveOperation.h"
#import "SaveFinalOperation.h"

#import "CoreDataShopCart.h"

#import "NSTimer+TimerSupport.h"


typedef enum {
    SaveBigImages,
    SaveFinalImages
} SaveType;

CGFloat const waitTimer = 10.f;


@interface SaveImageManager () <SaveOperationDelegate, SaveFinalOperationDelegate>
@property (strong, nonatomic) PrintData *printData;
@property (assign, nonatomic) NSInteger count;
//@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) NSMutableArray *printImages;

/// Тип сохранения
@property (assign, nonatomic) SaveType saveType;

/// Тамер для ожидания сохранения
//@property (weak, nonatomic) NSTimer *saveTimer;

/// Массив операций
@property (strong, nonatomic) NSMutableArray *queueOperations;

/// Массив незаконченных операций(SaveOperation)
@property (strong, nonatomic) NSMutableArray *unfinishedSaveOperations;
@end



@implementation SaveImageManager
#pragma mark - Init
- (id) initManagerWithPrintData:(PrintData *)printData andDelegate:(id<SaveImageManagerDelegate>)delegate orPrintImages:(NSArray *)printImages
{
    self = [super init];
    if (self) {
        _saveType = SaveBigImages;
        _count = 0;
        _printData = printData;
        _delegate = delegate;
        _printImages = [printImages mutableCopy];
    }
    return self;
}



- (id) initFinalSavePrintData:(PrintData *)printData andDelegate:(id<SaveImageManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _saveType = SaveFinalImages;
        _count = 0;
        _printData = printData;
        _delegate = delegate;
    }
    return self;
}



-(void)dealloc
{
    NSLog(@"Save manager dealloc");
}


#pragma mark - Public
- (void) startSave {
    if (self.saveType == SaveBigImages) {
        [self startSaveBigImages];
    } else {
        [self startSaveFinalImages];
    }
}


-(void)stopSave {
    NSLog(@"Canceled Save Big");
    [self.delegate saveImageManager:self didCancelSave:self.printData];
    [self.queueOperations removeAllObjects];
    self.delegate = nil;
}

#pragma mark - Private
/*! Сохраняем большие картинки в корзину */
- (void) startSaveBigImages {
    // Create Operation
    NSArray *imagesPreview = _printImages.count == 0 ? _printData.imagesPreview : _printImages;
    for (PrintImage *image in imagesPreview) {
        SaveOperation *operation = [[SaveOperation alloc] initSaveWithPrintData:_printData andCurrentPrintImage:image andDelegate:self];
        // Добавяем в очередь, только картинки  без картинок, т.к остальные могут быть уже там
        if (image.previewImage == nil) {
            [self.queueOperations addObject:operation];
        }
    }
    
    [self checkQueue:self.queueOperations];
}



- (void) finishAllOperations {
    // Все успешно сохранилось
    if (self.saveType == SaveBigImages) {
        [self.delegate saveImageManager:self didAllBigImagesSaved:_printData];
    } else {
        [self.delegate saveImageManager:self didSaveAllToPrepareFinalSave:_printData];
    }
}

- (void) continueOperation:(NSObject<SaveOperationProtocol> *)operation {
    [operation startSave];
}




/*! Сохраняем финальные картинки, после добавления в корзину */
- (void) startSaveFinalImages
{
    // Create Operation
    for (PrintImage *image in _printData.imagesPreview) {
        SaveFinalOperation *finalOperation = [[SaveFinalOperation alloc] initSaveWithPrintData:_printData andCurrentPrintImage:image andDelegate:self];
        [self.queueOperations addObject:finalOperation];
    }
    
    [self checkQueue:self.queueOperations];
}


- (void) checkQueue:(NSMutableArray *)queueList {
    if (queueList.count == 0) {
        NSLog(@"Save.Manager: All Complete");
        [self finishAllOperations];
    } else {
        NSLog(@"Save.Manager: Continue");
        [self continueOperation:[self.queueOperations firstObject]];
    }
}



#pragma mark - SaveOperationDelegate
-(void)saveOperation:(SaveOperation *)saveOperation didSavedImage:(PrintImage *)printImage {
    
    // Удаляем первый элемент
    if (self.queueOperations.count > 0) {
        [self.queueOperations removeObjectAtIndex:0];
    }
    
    
    saveOperation.delegate = nil;
    [self.delegate saveImageManager:self didBigImagesSaved:printImage withPrintData:_printData];
    
//    NSLog(@"Operations: %i", self.operationQueue.operations.count);
    //NSLog(@"Count: %i", self.operationQueue.operationCount);
    
    CGFloat persent = (float)self.queueOperations.count / (float)self.printData.imagesPreview.count;
    NSLog(@"progress.Prepare: %f", 1 - persent);
    [self.delegate saveImageManager:self didSavedToProgress:1 - persent];
    
    // Continue
    [self checkQueue:self.queueOperations];
}


#pragma mark - SaveFinalOperationDelegate
-(void)saveFinalOperation:(SaveFinalOperation *)saveFinalOperation didSavedImage:(PrintImage *)printImage {
    //
    [saveFinalOperation setDelegate:nil];
    
    // Удаляем первый элемент
    if (self.queueOperations.count > 0) {
        [self.queueOperations removeObjectAtIndex:0];
    }
    
    //
    //[self.delegate saveImageManager:self didPrepareToFinalSave:printImage];
    
    //
    CGFloat persent = (float)self.queueOperations.count / (float)self.printData.imagesPreview.count;
    NSLog(@"progress.Prepare.Final: %f", 1 - persent);
    [self.delegate saveImageManager:self didSavedToProgress:1 - persent];
    
    //
    [self checkQueue:self.queueOperations];
}


#pragma mark - Property
- (NSMutableArray *)queueOperations {
    if (!_queueOperations) {
        _queueOperations = [NSMutableArray array];
    }
    
    return _queueOperations;
}
@end
