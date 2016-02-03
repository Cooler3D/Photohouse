//
//  JsonTemplateLayout.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/2/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LayerPage;

@interface JsonTemplateLayout : NSObject
@property (strong, nonatomic, readonly) LayerPage *cover;

/// Массив LayerPage
@property (strong, nonatomic, readonly) NSArray *layouts;

/// Адрес для картинки стиля
@property (strong, nonatomic, readonly) NSString *styleThumbalUrl;

/// Адрес для картинки-иконки корзины
@property (strong, nonatomic, readonly) NSString *storeThumbalUrl;


/*! Иницализируем по данным из JSON сервера
 *@param dictionary ответ от сервера
 */
- (id) initTemplateDictionary:(NSDictionary *)dictionary;
@end
