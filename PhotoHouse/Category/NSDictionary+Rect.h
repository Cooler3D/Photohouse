//
//  NSDictionary+Rect.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/3/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Rect)
/** Преобразуем CGRect в NSDictionary
 *@param rect зона обрезк для картинки
 *@return возвращается строка формата Dictionary: x, y, widht, height
 */
+ (NSDictionary*) dictionaryFromCGRect:(CGRect)rect;



/*! Преобразуем NSStrint в CGRect,
 *@param rectString строка формата Dictionary: x, y, widht, height
 *@return возвращаем CGrect заполненный
 */
+ (CGRect) getCGRectWithString:(NSString *)rectScting;
@end
