//
//  PHResponse.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Acts.h"
#import "PHouseApiErrorCode.h"


/*!
 @brief Абстрактный класс, чтения ответа от сервера PhotoHouse.\n
 Этот класс является родительским для всех классов в папке Model/Server/PhouseApi_v1/Responses
 @author Дмитрий Мартынов
 */
@interface PHResponse : NSObject


/** Инициализируемся абстрактный класс
 *@param data данные от сервера
 */
- (id) initWitParseData:(NSData *)data;


/** Проверяем на наличие ошибок, автомачитески запишет в переменную error. 
 *@warning Вызываем из других классов Response, но не при инициализации PhouseApi
 *@param parseData данные с сервера
 *@return возвращаем словарь с ответом, если ответа нет, значит ошибка и она содержится в переменной error
 */
- (NSDictionary *) hasErrorResponce:(NSData *)parseData;


/// Ошибка в процессе чтения данных от сервера, может быть как ошибка чтения, там и ошибка ответа
@property (strong, nonatomic, readonly) NSError *error;


/// Серверное время выполненной команды, для UnitTest
@property (strong, nonatomic,readonly) NSDate *serverCurrentTimeCommand;
@end
