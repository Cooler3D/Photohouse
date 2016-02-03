//
//  CoreDataCacheImage.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/13/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHDataManager.h"

@interface CoreDataCacheImage : PHDataManager
/// Переключаем Кэш
/*! Переключаем кэш в настройках
 *@param isOn статус настроек, Yes включаем, No выключаем
 */
- (void) cacheSwitch:(BOOL)isOn;


///  Открыт ли Кэш для сохранения фотографий @return yes можно записывать, no кэш закрыт
- (BOOL) isCacheOpened;
@end
