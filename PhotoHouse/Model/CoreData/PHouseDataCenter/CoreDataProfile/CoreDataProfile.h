//
//  CoreDataProfile.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/26/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHDataManager.h"

@class ResponseAuth;

@interface CoreDataProfile : PHDataManager

/// Сохраняем данные пользователя
/*! Созраняем данные пользователя в базе
 *@param profile данные авторизации ResponseAuth
 */
- (void) saveProfile:(ResponseAuth *)profile;


/// Сохраняем телефон @param phone номер телефона пользователя
- (void) savePhone:(NSString *)phone;


/// Сохраняем адрес @param addreess адрес пользователя
- (void) saveAddress:(NSString *)address;


/// Сохраняем данные о доставке
/*! Сохраянем данные о доставке, ту что вводит пользователь перед самой отправкой заказа на сервер.
 *@param uiname имя города
 *@param code код доставки
 *@param uiPayment тип оплаты
 */
- (void) saveDeliveryUiCityName:(NSString *)uiname andDeliveryCode:(NSString *)code andUiPaymentName:(NSString *)uiPayment;



/// Получаем ID пользователя @return идентификатор user_id пользователя
- (NSString *) profileID;


/// Получить все поля профиля @return возвращается ResponseAuth с данными авторизации
- (ResponseAuth *) profile;


/// Получить пароль MD5 @return вовзращается пароль строкой в зашифрованном виде
- (NSString *) passowrdMD5;


/// Получаем телефон из профиля
- (NSString *)getPhoneProfile;


/// Получаем адресс из профиля
- (NSString *)getAddressProfile;


/// Получаем данные от доставке
- (void) getDeliveryMemberWithBlock:(void(^)(NSString *uiCityName, NSString *deliveryCode, NSString *uiPaymentName))deliveryBlock;


/// Сравниваем арес в базе с новым введенным пользователем
/** Сравниваем адрес сохраненный с текущим и сохраняем, если старый адрес пустой
 *@param address адрес указанный пользователем или возвращенный с сервера
 */
- (void) addressCompareAndSave:(NSString *)address;



/// Сравниваем телефон в базе с новым пользовательским
/** Сравниваем телефон с текущим и сохраняем новый если требуется
 *@param phone телефон указанный пользователем или возвращенный с сервера
 */
- (void) phoneCompareAndSave:(NSString *)phone;


/// Выход из системы и стирание данных профиля из CoreData
- (void) logount;
@end
