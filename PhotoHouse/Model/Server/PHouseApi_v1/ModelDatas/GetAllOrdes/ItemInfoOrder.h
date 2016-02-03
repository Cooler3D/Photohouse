//
//  ItemInfoOrder.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/9/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemInfoOrder : NSObject
@property (strong, nonatomic, readonly) NSString *name;             ///< Имя
@property (assign, nonatomic, readonly) NSUInteger price;           ///< Цена
@property (strong, nonatomic, readonly) NSString *descriptionOrder; ///< Описание
@property (strong, nonatomic, readonly) NSString *categoryName;     ///< Имя категории


/// Иницализируем по данным сервера
/*! Иницализируем по истории пришедшей от сервера
 *@param item_info данные от сервера
 */
- (id) initWithItemInfoOrder:(NSDictionary *)item_info;
@end
