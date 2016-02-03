//
//  InstagramAccessToken.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/11/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstagramAccessToken : NSObject
@property (strong, nonatomic, readonly) NSString *accessToken;  ///< Токен доступа
@property (strong, nonatomic, readonly) NSString *user_id;      ///< Идентификатор пользователя
@property (strong, nonatomic, readonly) NSString *username;     ///< Имя
@property (strong, nonatomic, readonly) NSString *fullname;     ///< Полное имя


/// Иницализируем по словарю
/*! Иницализируем данные для Instagram по словарю
 *@param dictionary словарь ииализации
 */
+ (InstagramAccessToken*) initWithDictionary:(NSDictionary*)dictionary;
@end
