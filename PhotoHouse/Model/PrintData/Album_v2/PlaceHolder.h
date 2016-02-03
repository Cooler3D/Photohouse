//
//  PlaceHolder.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/2/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 \brief объкет картинки пользователя на развороте
 
 \author Дмитрий Мартынов
 */
@interface PlaceHolder : NSObject
@property (strong, nonatomic, readonly) NSString *psdPath;      ///< адрес psd
@property (strong, nonatomic, readonly) NSString *layerNum;     ///< ???
@property (strong, nonatomic, readonly) NSString *pngPath;      ///< Адрес картинки
@property (strong, nonatomic, readonly) NSString *scalePngUrl;  ///< картинка разворота
@property (assign, nonatomic, readonly) CGRect rect;            ///< позиция на развороте

/** Инициализируем по JSON от сервера
 *@param dictionary данные от сервера
 */
- (id) initTemplateDictionary:(NSDictionary *)dictionary;


/// Иницализируем по CoreData
/*! Иницализируем по данным из бызы CoreData
 */
- (id) initWithPsdPath:(NSString *)psdPath andLayerNum:(NSString *)layerNum andPngPath:(NSString *)pngPath andScalePngUrl:(NSString *)scalePngUrl andRect:(CGRect)rect;


/// Получаем словарь
- (NSDictionary *) getDictionary;
@end
