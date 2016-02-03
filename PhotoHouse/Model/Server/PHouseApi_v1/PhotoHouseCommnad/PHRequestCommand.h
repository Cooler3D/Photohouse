//
//  PHRequestCommand.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 6/26/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const APPLICATION_TOKEN;
extern NSString * const SERVER_URL;
//extern NSString * const SERVER_URL_FOR_IMAGE;

@class Json;


/*!
 \brief Класс выполнения запроса на сервер PhotoHouse.
 \code
 PHRequestCommand *command = [PHRequestCommand alloc] init];
 [command executeCommnadWithJson:andCompleteBlock:progressUploadBlock:errorBlock:];
 \endcode
 
 \author Дмитрий Мартынов
 */
@interface PHRequestCommand : NSObject
/// Выполняем запрос к серверу PhotoHouse
/** Выполняем запрос к серверу PhotoHouse и отправку данных
 *@param jsonData данные для отправки
 *@param resultBlock блок при успешном выполнении запроса
 *@param progressBlock блок при процентной загрузке
 *@param errorBlock блок ошибки
 */
- (void) executeCommnadWithJson:(Json *)jsonData
               andCompleteBlock:(void(^)(NSData *responseData))resultBlock
            progressUploadBlock:(void (^)(CGFloat progress))progressBlock
                     errorBlock:(void(^)(NSError *error))errorBlock;
@end
