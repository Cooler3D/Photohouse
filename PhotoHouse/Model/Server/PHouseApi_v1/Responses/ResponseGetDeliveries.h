//
//  ResponseGetDeliveries.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHResponse.h"

@class DeliveryCity;



@interface ResponseGetDeliveries : PHResponse



/** Массив для заказа, в нем содержится одно значение
 *@param deliveryCity выбранные пользователь тип доставки и оплаты
 *@return возвращаем один PhotoRecord как массив
 */
//- (NSArray *) getDeliveryForOrderWithDeliveryCity:(DeliveryCity *)deliveryCity;



/** Создаем стандартное значение, если не найдено
 *@return возврацаем конкретный объект DeliveryCity
 */
- (DeliveryCity *) getDefaultDeliveryCity;



/** Получаем название всех городов
  *@return возвращается массив с названиями городов
 */
- (NSArray *) getAllCityUINames;



/** Получаем конкретный DeliveryCity по выбранному городу
 *@param uiname имя города
 *@return возврацаем конкретный объект DeliveryCity
 */
- (DeliveryCity *) getDeliveryCityWithUICityName:(NSString *)uiname;



/** Получаем конкретный DeliveryCity по выбранному городу и коду доставки
 *@param uiname имя города, параметр DeliveryCity
 *@param code код доставки, параметр DeliveryType
 *@return возврацаем конкретный объект DeliveryCity
 */
- (DeliveryCity *) getDeliveryCityWithUICityName:(NSString *)uiname
                                 andCodeDelivery:(NSString *)code;



/** Получаем финальная цепочка, по названию города, типу доставки и типу отплаты
 *@param uiname название города UI
 *@param code код для достаки для города
 *@param typeName тип доставки, pre или post (Предоплата или Постоплата)
 *@return возвращаем DeliveryCity, где содежится по одному вложеннуму объекту в массиве
*/
- (DeliveryCity *) getDeliveryCityWithUICityName:(NSString *)uiname
                                 andCodeDelivery:(NSString *)code
                                andPaymentUIName:(NSString *)paymentUIname;



/** Получаем навания списка оплаты для текущего города и типа доставки
 *@param uiname название города UI
 *@param code код для достаки для города
 *@result возвращаем названия доставок, для отображения в списке
 */
- (NSArray *) getAllPaymentForUICityName:(NSString *)uiname
                         andCodeDelivery:(NSString *)code;

@end
