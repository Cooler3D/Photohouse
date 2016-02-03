//
//  WarningView.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/27/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PrintImage;

@interface WarningView : UIView
- (void) showWarningView;
- (void) hideWarningView;


/*! Проверяем картинку, отправляем текущую картинку
 *@param printImage текущая картинка
 */
- (void) checkImage:(PrintImage *)printImage;
@end
