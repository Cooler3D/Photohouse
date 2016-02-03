//
//  ResponseAlbumV2.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/2/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHResponse.h"

@interface ResponseAlbumV2 : PHResponse
/// Массив со всеми AlbumTemplate
@property (strong, nonatomic) NSArray *templates;

/// Массив со старыми Template
@property (strong, nonatomic) NSArray *oldTemplates;

/*! Инициализируем по блоку
 *@param data данные с сервера в json
 *@completeBlock блок для выполнения
 */
//-(id)initWitParseData:(NSData *)data andBlock:(void(^)(NSArray *templates))completeBlock;
@end
