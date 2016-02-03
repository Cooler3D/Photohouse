//
//  UIImageView+CompareCrop.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/27/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (CompareCrop)

/*! Метод */
- (BOOL) compareSquareHitTestCropView:(UIImageView*)cropView withMaxSquare:(NSInteger)maxSquare;


///*! РАссчитаваем прямоугольник CGRect для вставки в максимально возможные размеры
// */
//- (CGRect) calculateMaxSizeInViewSize:(CGSize)size;
@end
