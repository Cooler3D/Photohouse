//
//  LayerPage.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/2/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlaceHolder;
/*!
 \brief Разворот, новый класс
 
 \author Дмитрий Мартынов
 */
@interface LayerPage : NSObject
@property (strong, nonatomic, readonly) NSArray *placeHolders;      ///< Массив куда будет вставлять пользователь
@property (strong, nonatomic, readonly) PlaceHolder *combinedLayer;
@property (strong, nonatomic, readonly) PlaceHolder *underLayer;    ///< Низняя картинка
@property (strong, nonatomic, readonly) PlaceHolder *overLayer;     ///< Верхняя картинка
@property (assign, nonatomic, readonly) CGRect noscaleCombinedLayer;
@property (strong, nonatomic, readonly) NSString *layoutSelectPng;  ///< Фоновая картинка заполненная
@property (strong, nonatomic, readonly) NSString *nameKey;          ///< Ключ unwrap_XX
/*! Иницализируем по данным из JSON сервера
 *@param dictionary ответ от сервера
 */
- (id) initTemplateDictionary:(NSDictionary *)dictionary;

- (id) initTemplateDictionary:(NSDictionary *)dictionary andNameKey:(NSString *)nameKey;
@end
