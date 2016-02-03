//
//  CityDeliveries.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface DeliveryCity : NSObject
@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSString *uiname;
@property (strong, nonatomic, readonly) NSArray *types;



/*! Иницализация по ответу от сервера 
 */
- (id) initWithCityDictionary:(NSDictionary *)cityDictionary andDictionaryPayments:(NSDictionary *)payments;




/*! Иницализация по считываю из CoreData
 */
- (id) initWitName:(NSString *)name andUIname:(NSString *)uiname andSetTypes:(NSArray *)types;



/*! Полусем Props для отправки на сервер
 *@return возвращаем словарь с заполненными значениями
 */
- (NSDictionary *) getDeliveryProps;
@end
