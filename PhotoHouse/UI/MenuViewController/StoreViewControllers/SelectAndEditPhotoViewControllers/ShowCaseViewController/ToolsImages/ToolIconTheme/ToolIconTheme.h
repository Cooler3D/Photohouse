//
//  ToolTheme.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/9/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PrintImage;


@interface ToolIconTheme : UIView
@property (nonatomic, strong, readonly) UIImage *previewImage;



- (id)initWithFrame:(CGRect)frame
             target:(id)target
             action:(SEL)action
         printImage:(PrintImage*)printImage;


/*! Выделяем элемент */
- (void) selectedImage;



/*! Убираем выделение */
- (void) deselectedImage;



/*! Проверяем Выделен ли объект 
 *return возращается Yes объект выделен, возвращается No НЕ выделен
 */
- (BOOL) isSelected;



/*! Получаем тукущую PrintImage
 @return возвращаем PrintImage
 */
- (PrintImage *) printImage;


/// Обновляем иконку в ToolBar после редактора фоток
- (void) updateIcon;
@end
