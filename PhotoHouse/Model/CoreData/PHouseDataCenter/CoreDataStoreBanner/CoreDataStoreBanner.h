//
//  CoreDataStoreBanner.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/9/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHDataManager.h"

@interface CoreDataStoreBanner : PHDataManager
/// Сохраняем баннеры
/*! Нужно сохранять баннеры только те где есть картинки и они успешно загруженны
 *@param banners массив баннеров Banner, должны быть с загруженными картинками
 *@param interval интервал переключения между баннерами
 */
- (void) saveBanners:(NSArray *)banners andSwitchTimeInterval:(NSInteger)interval;



/// Если баннеры @return yes есть баннеры, no - нет баннеров
- (BOOL) hasBanners;



/*! Возвращаем сохраненные баннеры Banner.h
 @code
 NSInteger interval = 0;
 CoreDataStoreBanner *coreBanner = [CoreDataStoreBanner alloc] init];
 [coreBanner getBannersSetInterval:&interval];
 @endcode
 *@param interval передвем ссылку на Integer, куда в последствии запишется интервал
 *@return массив Banner.h с картинками
 */
- (NSArray *) getBannersSetInterval:(NSInteger *)interval;



/// Удалаяем сохраненные баннеры
- (void) removeAllSavedBanners;
@end
