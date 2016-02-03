//
//  DrawGridView.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/7/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 \brief Сетка в редакторе и отрисовка прямоуголиника для конструктора альбомов.\n
 Используется в контрукторе альбомов
 \code
 DrawGridView *gridView = [[DrawGridView alloc] initGridWithFrame:];
 UIImage *gridImage = [gridView gridImage];
 \endcode
 
 \author Дмитрий Мартынов
 */
@interface DrawGridView : UIView

/*! Иницализируем рисовалку прямоугольника
 *@param size размер прямоугольника
 *@param colorLine цвет линии
 *@param lineWidth ширина линии
 */
- (id) initRectangleWithSize:(CGSize)size andColorLine:(UIColor *)colorLine andStrokeLineWidth:(CGFloat)lineWidth;



/*! Иницализируем рисовалку прямоугольника
 *@param size размер сетки ктотрая будет
 */
- (id) initGridWithFrame:(CGSize)size;


/** Инициализируем рисовалку выделения
 *@param size размер прямоугольника
 *@param colorLine цвет линии
 *@param lineWidth ширина линии
 */
- (id) initDrawSelectImageWtihSize:(CGSize)size andColorLine:(UIColor *)colorLine andStrokeLineWidth:(CGFloat)lineWidth;


/*! Возвращаем стетку
 *@return возсвращается картинка с сеткой
 */
- (UIImage *)gridImage;


/*! Возвращаем прямоугольник
 *@return возсвращается картинка с прямоугольником
 */
- (UIImage *)rectangleImage;
@end
