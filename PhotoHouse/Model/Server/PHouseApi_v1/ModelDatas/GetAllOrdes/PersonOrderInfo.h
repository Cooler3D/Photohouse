//
//  PersonOrderInfo.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/20/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Статус заказа в истории заказов
typedef enum {
    StatusOrderTypeWait = 1,
    StatusOrderTypeTick,
    StatusOrderTypePrint,
    StatusOrderTypeDelivery,
    StatusOrderTypeComplete,
    StatusOrderTypeCancel,
    StatusOrderTypePayment
} StatusOrderType;

@interface PersonOrderInfo : NSObject
@property (strong, nonatomic, readonly) NSString *user_id;          ///< Идентификатор пользователя
@property (strong, nonatomic, readonly) NSString *order_id;         ///< Идентификатор заказа
@property (strong, nonatomic, readonly) NSString *studio_id;        ///< ???
@property (strong, nonatomic, readonly) NSString *status;           ///< Текст статуса
@property (strong, nonatomic, readonly) NSString *status_id;        ///< Цифра статуса
@property (strong, nonatomic, readonly) NSString *total_cost;       ///< Полная стоимость заказа
@property (strong, nonatomic, readonly) NSString *dateString;       ///< Дата заказа
@property (strong, nonatomic, readonly) NSString *fullName;         ///< Полное имя
@property (strong, nonatomic, readonly) NSString *phone;            ///< Телефон для связи
@property (strong, nonatomic, readonly) NSString *address;          ///< Адресс доставки
@property (strong, nonatomic, readonly) NSString *deliveryComment;  ///< Комментарии о доставке


/// Картинка статуса заказа
- (UIImage *) statusImage;


/// Инициализатор данных о пользователе
/*! Инициализируемся по истории заказа о заказчике
 *@param orderInfo данные о пользователе
 */
- (id) initWithOrderInfo:(NSDictionary *)orderInfo;
@end
