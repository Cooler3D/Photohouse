//
//  CookieModel.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/15/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const INSTAGRAM_COOKIE;
extern NSString *const VKONTAKTE_COOKIE;


/*!
 \brief Выходим из соц.сетей
 \warning НЕ используется
 
 \author Дмитрий Мартынов
 */
@interface CookieModel : NSObject
- (void) clearCookieWithName:(NSString*)nameCookie;
@end
