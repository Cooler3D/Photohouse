//
//  Banner.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StoreItem.h"

@interface Banner : NSObject
@property (strong, nonatomic, readonly) NSString *imageUrl;     ///< Адрес картинки
@property (strong, nonatomic, readonly) NSString *actionUrl;    ///< Событие
@property (strong, nonatomic, readonly) UIImage *image;         ///< Баннер
@property (assign, nonatomic, readonly) BOOL hasImage;          ///< Есть ли картинка

/// Иницализируем по данным сервера
/*! Иницализируем по данным сервера
 *@param dictionary данные сервера
 */
- (id) initWitDictionary:(NSDictionary *)dictionary;


/// Иницализируем из базы
/*! иницализируем из CoreDataBanner
 *@param actionUrl событие по нажатию
 *@param image картинка баннера
 */
- (id) initWithActionUrl:(NSString *)actionUrl andImage:(UIImage *)image;


/// Загружаем картинку
- (void) loadImage;


/// Получаем категорию @warning НЕ используется
- (StoreType) getInternalID;
@end
