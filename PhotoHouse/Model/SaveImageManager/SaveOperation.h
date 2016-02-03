//
//  SaveOperation.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/10/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SaveOperationProtocol.h"

@class PrintData;
@class PrintImage;
@protocol SaveOperationDelegate;


/*!
 @brief Очередь для сохранения большой картинки в CoreDataShopCart.\n
 Вызывается из менеджера SaveImageManager
 
 @author Дмитрий Мартынов
 */
@interface SaveOperation : NSObject <SaveOperationProtocol>
@property (strong, nonatomic) PrintImage *printImage;               ///< Картинка
@property (strong, nonatomic) id<SaveOperationDelegate> delegate;   ///< Делегат



/// Иницализируем очередь для SaveImageManager
/*! Иницализируем сохранение большой картинки в CoreDataShoCart
 *@param printData покупка
 *@param printImage картинка одна из printData
 *@param delegate делегат
 */
- (id) initSaveWithPrintData:(PrintData *)printData andCurrentPrintImage:(PrintImage *)printImage andDelegate:(id<SaveOperationDelegate>)delegate;
@end



@protocol SaveOperationDelegate <NSObject>
@required
- (void) saveOperation:(SaveOperation *)saveOperation didSavedImage:(PrintImage *)printImage;
@end