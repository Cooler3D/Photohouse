//
//  NSDictionary+AssetMetaData.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/4/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

extern CGFloat const kDefaultMinimalSquare;

@interface NSDictionary (AssetMetaData)
/** Проверяем минимальное ли значения высоты и ширины картинки по метаданным
 *@param square общая площадь картинки с которой сравнивать, по умолчания 0.2 магапиксела
 *@return возвращаем YES если картинка очень маленькая, NO картинка впорядке
 */
- (BOOL) isAssetMedaDataMinimalSize:(CGFloat)square;
@end
