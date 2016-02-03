//
//  SaveFinalOperation.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 4/3/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SaveOperationProtocol.h"

@class PrintData;
@class PrintImage;
@protocol SaveFinalOperationDelegate;


/*!
 @brief Очередь для сохранения финальных картинок в CoreDataShopCart.\n
 Вызывается из менеджера SaveImageManager.\n
 Пользователь могу редактировать картинки во время сохранения, чтобы не перегружать CoreData мы сохраняем данные возможно измененные пользователем еще раз перед переходом в корзину.
 
 @author Дмитрий Мартынов
 */
@interface SaveFinalOperation : NSObject <SaveOperationProtocol>
@property (strong, nonatomic) PrintImage *printImage;
@property (strong, nonatomic) id<SaveFinalOperationDelegate> delegate;


/// Иницализируем очередь для SaveImageManager
/*! Иницализируем сохранение большой картинки в CoreDataShoCart
 *@param printData покупка
 *@param printImage картинка одна из printData
 *@param delegate делегат
 */
- (id) initSaveWithPrintData:(PrintData *)printData andCurrentPrintImage:(PrintImage *)printImage andDelegate:(id<SaveFinalOperationDelegate>)delegate;
@end



@protocol SaveFinalOperationDelegate <NSObject>
@required
- (void) saveFinalOperation:(SaveFinalOperation *)saveFinalOperation didSavedImage:(PrintImage *)printImage;
@end
