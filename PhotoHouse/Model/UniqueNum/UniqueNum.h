//
//  UniqueNum.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/5/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UniqueNum : NSObject
/// Получаем уникальный идентификатор  Используется совместо с PrintData
+ (NSUInteger) getUniqueID;
@end
