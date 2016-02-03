//
//  UploadOperation.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/24/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PrintData;
@class PrintImage;
@protocol UploadOperationDelegate;


/*!
 \brief Операция загрузки картинки на сервер PhotoHouse
 \warning Используется речная очередь, а НЕ NSOperation
 \author Дмитрий Мартынов
 */
@interface UploadOperation : NSObject//NSOperation
@property (strong, nonatomic) id<UploadOperationDelegate> delegate;


/// Иницализируем очередь
/*! Иницализируем очередь для загрузки на сервер PhotoHouse
 *@param printData покупка текущая
 *@param printImage картинка от покупки printData
 *@param delegate делегат
 */
- (id) initSaveWithPrintData:(PrintData *)printData andCurrentPrintImage:(PrintImage *)printImage andDelegate:(id<UploadOperationDelegate>)delegate;


/// Загружаем на сервер
- (void) upload;
@end


@protocol UploadOperationDelegate <NSObject>
@required
- (void) uploadOperation:(UploadOperation *)operation didUploadComplete:(PrintImage *)printImage andPrintData:(PrintData *)printData;
- (void) uploadOperation:(UploadOperation *)operation didUploadProgress:(CGFloat)progress;


/// Костыльный метод при отправке на сервер картинки
/*! Если потзователь редактировал картинку маленькую (640х???), а ОРИГИНАЛЬНАЯ картинка очень большая, то при применении фильтров приложение может закрыться по памяти. Для этого мы отправляем не редактированную картинку и маленькую картинку (640х???) с примененными фильтрами и больщой надписью Preview на картинке. Данный метод добавляем к очереди эти картинку PrintImage с надписью Preview
 *@warning Костыльный метод, сделан для слыбых iPhone4
 *@param operation операция
 *@param printImage картинка PrintImage с надписью Preview и примененными фильтрами
 *@param printData покупка PrintData к которой относится покупка
 */
- (void) uploadOperation:(UploadOperation *)operation didAddToSendPreviewPrintImage:(PrintImage *)printImage andPrintData:(PrintData *)printData;
@end