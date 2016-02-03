//
//  AppDelegate.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/5/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ResponseAuth;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


/*! Инициализируем данные об авторизации
 */
- (void) setUserData:(ResponseAuth *)responseAuth;


/// Отправляем лог в CrashLytics
- (void) crashlyticsLog:(NSString *)logText;
@end
