//
//  BannerItemView.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Banner.h"


@interface BannerItemView : UIView
@property (strong, nonatomic, readonly) Banner *banner; ///< Баннер

/// Иницализируем Banner View
/*! Иницализируем Баннер для отображения
 *@param frame прямоугольник для баннера
 *@param target ссылка на объект
 *@param action ссылка на метод
 *@param banner объект Banner
 */
- (id) initWithFrame:(CGRect)frame target:(id)target action:(SEL)action setBanner:(Banner *)banner;
@end
