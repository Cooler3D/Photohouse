//
//  PHRequest.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Acts.h"
#import "Fields.h"

#import "DeviceManager.h"

/*!
 \brief Обстрактный класс для формирования запроса на сервер PhotoHouse.\n
 Этот класс является родительским для всех классов в папке Model/Server/PhouseApi_v1/Requests
 
 \author Дмитрий Мартынов
 */
@interface PHRequest : NSMutableURLRequest

/// Получаем имя устройства @return взвращается строка ip4, ip5 и тд
- (NSString *) getDeviceName;



/// Получаем время отправки @return возсращаем время начала
- (NSString *) getTimeStamp;



/** Получаем Токен по id-пользователя, времени и md5-пароль
 *@param user_id идентификатор пользователя
 *@param timaStamp время
 *@param password_md5 пароль
 */
- (NSString *) getTokenWithUserID:(NSString *)user_id
                     andTimeStamp:(NSString *)timeStamp
                andOldPasswordMD5:(NSString *)password_md5;



/// Отправляем данные на сервер PhotoHouse
/** Выполняем запрос и отправляем данные на сервер
 *@param resultBlock блок успешного выполнения запроса, в нем может быть внутрення ошибка
 *@param errorBlock блок ошибки
 */
- (void) executeResultBlock:(void(^)(NSData *responseData))resultBlock
                 errorBlock:(void(^)(NSError *error))errorBlock;



/// Отправляем картинку или данные на сервер PhotoHouse с учетом прогресса
/** Выполняем запрос и отправляем данные на сервер
 *@param resultBlock блок успешного выполнения запроса, в нем может быть внутрення ошибка
 *@param progressBlock блок прогресса загрузки
 *@param errorBlock блок ошибки
 */
- (void) executeResultBlock:(void (^)(NSData *responseData))resultBlock
        progressUploadBlock:(void (^)(CGFloat progress))progressBlock
                 errorBlock:(void (^)(NSError *error))errorBlock;


///** Выполняем запрос на загрузку картинок
// 
// */
//- (void) executeUploadResultBlock:(void(^)(NSData *responseData))resultBlock
//                       errorBlock:(void(^)(NSError *error))errorBlock;
@end
