//
//  AnaliticsModel.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 10/7/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 @brief Система аналитики GoogleAnalitics.\n
 Отправляет данные о событиях и названиях экранов
 
 @author Дмитрий Мартынов
 */
@interface AnaliticsModel : NSObject
/// Singleton
+(AnaliticsModel*) sharedManager;



/// Название экрана
/*! Отправляем название экрана
 *@param screenName название экрана
 */
- (void) setScreenName:(NSString*)screenName;



/// Отправляем событие
/*! Отправляем в аналитику событие
 *@param category категория события
 *@param action событие
 *@param label значение события
 */
- (void) sendEventCategory:(NSString*)category andAction:(NSString*)action andLabel:(NSString*)label withValue:(NSNumber*)value;
@end
