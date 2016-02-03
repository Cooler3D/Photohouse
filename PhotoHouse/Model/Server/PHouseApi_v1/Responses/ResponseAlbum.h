//
//  ResponseAlbum.h
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/9/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import "PHResponse.h"



@interface ResponseAlbum : PHResponse
/// Массив со всеми Template
@property (strong, nonatomic) NSArray *templates;

/*! Инициализируем по блоку
 *@param data данные с сервера в json
 *@completeBlock блок для выполнения
 */
-(id)initWitParseData:(NSData *)data andBlock:(void(^)(NSArray *templates))completeBlock;
@end
