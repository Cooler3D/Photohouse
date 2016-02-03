//
//  ResponseGetUpdateTime.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHResponse.h"

@interface ResponseGetUpdateTime : PHResponse
/** Сохраняем время баннера при успешном получении
 *@param bannerTime врема последнего получения команды
 */
- (void) saveBannerTime:(NSInteger)bannerTime;


/** Сохраняем время GetItems
 *@param getItemsTime врема получения команды
 */
- (void) savegetItemsTime:(NSInteger)getItemsTime;


/** Сохраняем время GetTemplates
 *@param getItemsTime врема получения команды
 */
- (void) saveGetTemplatesTime:(NSInteger)getTemplatesTime;


/// Нужно ли обновлять данные Баннера
@property (assign, nonatomic, readonly) BOOL bannersNeedUpdate;



/// Нужно ли обновлять данные GetItems
@property (assign, nonatomic, readonly) BOOL getItemsNeedUpdate;


/// Нужно ли обновлять Template
@property (assign, nonatomic, readonly) BOOL getTemplatesNeedUpdate;

/// Время которое приходит от комманды get_update_time
//@property (strong, nonatomic, readonly) NSDate *updateTimeBanner;
@end
