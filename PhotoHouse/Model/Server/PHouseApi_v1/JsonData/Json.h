//
//  JsonRequestData.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 26/06/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Acts.h"
#import "Fields.h"


extern NSString *const SALT;


/*!
 @brief Абстрактный класс
 Содержит в себе данный для отправки на сервер. Их нужно установить в Request
 @note Данный класс является расширением для всех классов в папке JsonData
 @author Дмитрий Мартынов
 */
@interface Json : NSObject
/// Сформированный JSON для помещения в запрос
@property (strong, nonatomic, readonly) NSDictionary *jsonDictionary;

/// Картинка, может быть nil, используется при загрузке
@property (strong, nonatomic, readonly) NSData *imageData;


/** Обновляем данные картинки */
//- (void) updateImageData:(NSData *)imageDatas;


/// Получить время @return возвращается строка времени
- (NSString*)getTimeStamp;


/// Получаем устройство ip4, ip5, ip6 @return возвращаем данные ip4, ip5 и тд
- (NSString *) getDeviceName;
@end
