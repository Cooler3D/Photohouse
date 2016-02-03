//
//  FilterImageManager.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/31/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PrintImage;
@protocol FilterImageManagerDelegate;


/*!
 \brief Применения фильтров перед отправкой картинки ОРИГИНАЛЬНОЙ на сервер PhotHouse
 
 \author Дмитрий Мартынов
 */
@interface FilterImageManager : NSObject
@property (weak, nonatomic) id<FilterImageManagerDelegate> delegate;

/// Иницализируем фильтр
/*! Инициализируем фильтр для большой картинки перед отправкой на сервер PhotoHouse. Данный класс используется вместе с UploadImageManager
 *@param printImage картинка
 *@param delegate делегат
 */
- (id) initWithPrintDataUnique:(NSUInteger)unique andPrintImage:(PrintImage *)printImage andDelegate:(id<FilterImageManagerDelegate>)delegate;



/// Применяем фильтр, на картинку printImage содержащую оригинальное изображения накладываются фильтра если они не default
- (void) apply;
@end


@protocol FilterImageManagerDelegate <NSObject>
@required
- (void) filterImageManager:(FilterImageManager *)manager didApplyImage:(PrintImage *)printImage;
@end