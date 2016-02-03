//
//  PHouseApiErrorCode.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ErrorCodeTypeNotLoginAndPassword,   // В памяти приложения нет Логина и Пароля
    ErrorCodeTypeAutorizationFaled,     // Ошибка при авторизация, не верный логин или пароль
    ErrorCodeTypeNotConnectToInternet,  // Нет соединения с интернетом
    
    ErrorCodeTypeRegistrationFaled,     // Регистрация не пройдена
    ErrorCodeTypeMakeOrder,             // Оправка заявки произошла ошибка
    
    ErrorCodeTypeTimeOut,               // Превышен интервал ожидания
    
    ErrorCodeTypeInternalParse          // Произошла обибка чения при парсинге
} ErrorCodeTypes;

@interface PHouseApiErrorCode : NSObject

@end
