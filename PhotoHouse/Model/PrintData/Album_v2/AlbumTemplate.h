//
//  AlbumTemplate.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/2/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JsonTemplateLayout;


/*!
 \brief Конструктор альбомов ОБНОВЛЕННЫЙ.\n
 Из этого формата потом после удачного парсинга коныертируется в страный формат Template
 \warning Требуется провести изменение и сделать взаимодействие в ConstructorViewController именно с этим классом, не старым. Так же потребуется изменение в CoreDataStore, CoreDataShopCart, именно там они и сохраняются.
 \author Дмитрий Мартынов
 */
@interface AlbumTemplate : NSObject
@property (strong, nonatomic, readonly) NSString *styleName;                ///< Имя стияля альбома
@property (strong, nonatomic, readonly) NSString *formaSize;                ///< Размер альбома
@property (strong, nonatomic, readonly) JsonTemplateLayout *jsonTemplate;   ///< Развороты


/// Ответ от сервера
/*! Иницализируем по данным из JSON сервера
 *@param dictionary ответ от сервера
 */
- (id) initTemplateDictionary:(NSDictionary *)dictionary;
@end
