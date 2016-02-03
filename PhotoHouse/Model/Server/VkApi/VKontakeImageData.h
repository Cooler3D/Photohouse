//
//  VKontakeImageData.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 10/6/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VKontakeImageData : NSObject
@property (strong, nonatomic, readonly) NSString *normalQualityURL;    ///< Сравнивать будем с Normal, т.к существует всегда, в отличие от Best

/// Инициализируем по данным VK
/*! Инициализируем по данным VK
 *@param dictionary ответ
 */
- (id) initWithDataDictionary:(NSDictionary*)dictionary;
@end
