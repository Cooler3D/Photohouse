//
//  CoreDataDelivery.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/25/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHDataManager.h"

@class DeliveryCity;

@interface CoreDataDelivery : PHDataManager
/// Сохраняем данные о доставке
/** Сохраням значения в Базе
 *@param deliveries массив DeliveryCity в доставками, загруженный или взяты по умолчанию
 */
- (void) saveAllDelivery:(NSArray *)deliveries;



/// Есть ли сохраненные значения @return значения есть приходит Yes, значений нет, приходит NO
- (BOOL) isSavedDelivery;



/// Получаем все названия городов @return возвращаем названия городов
- (NSArray *) getAllCityUINames;



/// Конкретный DeliveryCity по городу
/** Получаем конкретный DeliveryCity по выбранному городу
 *@param uiname имя города
 *@return возврацаем конкретный объект DeliveryCity
 */
- (DeliveryCity *) getDeliveryCityWithUIName:(NSString *)uiname;



/// Подучаем конкретный DeliveryCity по городу и выбранному коду доставки
/** Подучаем конкретный DeliveryCity по городу и выбранному коду доставки
 @param uiname название города
 @param code код доставки
 @return возвращаем DeliveryCity
 */
- (DeliveryCity *) getDeliveryCityWithUIName:(NSString *)uiname
                             andDeliveryCode:(NSString *)code;  




/// Финальная цепочка, получаем DeliveryCity по названию города, типу доставки и типу отплаты
/** Получаем финальная цепочка, по названию города, типу доставки и типу отплаты
 *@param uiname название города UI
 *@param code код для достаки для города
 *@param typeName тип доставки, pre или post (Предоплата или Постоплата)
 *@return возвращаем DeliveryCity, где содежится по одному вложеннуму объекту в массиве
 */
- (DeliveryCity *) getDeliveryCityWithUICityName:(NSString *)uiname
                                 andCodeDelivery:(NSString *)code
                                andPaymentUIName:(NSString *)paymentUIname;



/// Варианты оплаты
/** Получаем навания списка оплаты для текущего города и типа доставки
 *@param uiname название города UI
 *@param code код для достаки для города
 *@result возвращаем названия доставок, для отображения в списке
 */
- (NSArray *) getAllPaymentForUICityName:(NSString *)uiname
                         andCodeDelivery:(NSString *)code;

@end
