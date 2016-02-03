//
//  ResponseGetItems.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/23/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHResponse.h"

@interface ResponseGetItems : PHResponse
@property (strong, nonatomic, readonly) NSArray *stories;

/*! Иницализируем для объеднинения двух ответов get_items + get_template
 *@param data данные ответа get_items
 *@param templates массив распарсенных данных для шаблонов альбомов(template)
 */
-(id)initWitParseData:(NSData *)data andTemplates:(NSArray *)templates;
@end
