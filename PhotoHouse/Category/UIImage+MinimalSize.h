//
//  UIImage+MinimalSize.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/4/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDictionary+AssetMetaData.h"

@interface UIImage (MinimalSize)
/** Проверяем минимальное ли значения высоты и ширины картинки по метаданным
 *@param square общая площадь картинки с которой сравнивать, по умолчания 0.2 магапиксела
 *@return возвращаем YES если картинка очень маленькая, NO картинка впорядке
 */
- (BOOL) isMinimalImageSize:(CGFloat)square;
@end
