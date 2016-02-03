//
//  UploadImageManager.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/24/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PrintData;
@class PrintImage;
@protocol UploadImageManagerDelegate;




/*!
 @brief Менеджер для загрузки картинок на сервер PhotoHouse.\n
 Дочерние классы UploadOperation
 
 @author Дмитрий Мартынов
 */
@interface UploadImageManager : NSObject
@property (weak, nonatomic) id<UploadImageManagerDelegate> delegate;


/// Иницализируем очередь для загрузок на сервер Photohouse
/** Инициализируем очередь загрузки картинок на сервер PhotoHouse
 *@warning Для того чтобы началась загрузка, нужно использовать мтод startUpload
 *@param printDatas массив объектов PrintData
 */
- (id) initShopCartPrintDatas:(NSArray *)printDatas;


/// Старт загрузки на сервер
- (void) startUpload;


/// Остановка загрузки
- (void) stopUpload;
@end



@protocol UploadImageManagerDelegate <NSObject>
@required
/// Все картинки загруженны на сервер Phothouse
- (void) uploadImageManager:(UploadImageManager *)manager didAllImagesSaved:(PrintData *)printData;

/// Одна картинка загружена на сервер PhotoHouse
- (void) uploadImageManager:(UploadImageManager *)manager didImagesSaved:(PrintImage *)printImage withPrintData:(PrintData *)printData;

/// Прогресс загрузки одной картинки
- (void) uploadImageManager:(UploadImageManager *)manager didUploadProgress:(CGFloat)progress;

/// Прогресс загрузок текущей картинки от общего числа в очереди
- (void) uploadImageManager:(UploadImageManager *)manager didUploadAllImagesProgress:(CGFloat)progress;

/// Отменяем загрузку
- (void) uploadImageManager:(UploadImageManager *)manager didCancelUpload:(PrintData *)printData;
@end