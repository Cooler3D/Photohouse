//
//  EllipseModel.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Ориентация кружки, к какой стороне повернута ручка
typedef enum {
    CupOrientationToRight,
    CupOrientationToLeft
} CupOrientation;


/// Для какой кружки будет считать изображение
typedef enum {
    CupTypeFlexibleStandart = 20, ///< Стандартная кружка
    CupTypeFlexibleLatte    = 5,  ///< Кружка Латте
} CupTypeFlexibleSize;


@protocol EllipseModelDelegate;


/*!
 \brief Класс для формирования изображения изогнутого для кружки
 
 \author Дмитрий Мартынов
 */
@interface EllipseModel : NSObject
@property (weak, nonatomic) id<EllipseModelDelegate> delegate;

/// Иницализируем модель посторения изогнутого изображения для кружек
/*! Иницализируем модель посторения изогнутого изображения для кружек
 *@param image картинка которую требуется изогнуть
 *@param cupOrientation ориентация кружки
 *@param ratio соотношение сторон
 *@param distort для обычной кружки или латте
 */
- (id) initImage:(UIImage*)image withOrientation:(CupOrientation)cupOrientation andAspectRatio:(CGFloat)ratio andEllipseDistort:(CupTypeFlexibleSize)distort;


///  Создаем картинку для кружки
- (void) make;
@end





@protocol EllipseModelDelegate <NSObject>
@required
- (void) ellipseModel:(EllipseModel*)model didCompleteRightImage:(UIImage*)rightImage andLeftImage:(UIImage *)leftImage;
- (void) ellipseModel:(EllipseModel *)model didUpdateProgress:(CGFloat)progress;
@end