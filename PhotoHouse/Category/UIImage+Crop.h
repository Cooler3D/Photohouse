//
//  UIImage+Crop.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/29/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

// Для Магнита-Коллажа
typedef enum {
    MergeOrientaionToWidth,     // Склеиваем в длину (width)
    MergeOrientaionToHeight     // Склеиваем в высоту(height)
} MergeOrientaion;


@interface UIImage (Crop)
/*! Образаем картинку по картинке и сетке находящиеся друг над другом
 *@param photoImageView UIImageView с картинкой
 *@param cropImageView UIImageView с серткой вырезания картинки
 *@param ratio соотношение сторон ширины(width) / высоты(height)
 *@return возвращаем образенную картинку
 */
- (UIImage*) cropImage:(UIImageView*)photoImageView withCropImageView:(UIImageView*)cropImageView andRatio:(CGFloat)ratio;



/*! Расчитать размеры картинки и сетки для образки
 *@param photoImageView UIImageView с картинкой
 *@param cropImageView UIImageView с серткой вырезания картинки
 *@param ratio соотношение сторон ширины(width) / высоты(height)
 *@return возвращаем прямоугольник для обрезки
 */
- (CGRect) cropImageAndRect:(UIImageView*)photoImageView withCropImageView:(UIImageView*)cropImageView andRatio:(CGFloat)ratio;



/*! Образаем картинку по прямоугольнику
 *@param img картинка для обрезки
 *@param rect прямоугольник для образки
 *@return возвращаем картинку
 */
- (UIImage*) cropImageFrom:(UIImage*)img WithRect:(CGRect) rect;



/*! Образаем картинку под размеры
 *@param image картинка для обрезки
 *@param newSize новый размер
 *@return возвращаем обрезанную картинку
 */
- (UIImage*) cropWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;



/*! Рассчитать прямоугольник для обрезки
 *@param image картинка для анализирования
 *@param delitel соотношение сторон для обрезки 1<delitel<=1
 *@param возвращаем прямоугольник
 */
- (CGRect) sizeImage:(UIImage*)image withDelitelHeight:(CGFloat)delitel;



/*! Рассчитать размеры для вставки картинки по размерам и соотношению сторон, применяется в конструкторе альбомов. Чтобы точно пометилась внутрь
 */
- (CGRect) insertSizeView:(CGSize)sizeView withAspectRatio:(CGFloat)aspect_ratio;



/*! Рассчитать пространство для картинки, чтобы вставить по размеру
 */
- (CGRect) insertToCenterRect:(CGRect)mainRect;




/*! Поворачитаем картинку на угол
 *@param image картинка для вращения
 *@param angle угол поворота, относительно текущего положения
 *@return возвращаек повернутую картинку
 */
- (UIImage*)rotateImage:(UIImage*)image andRadian:(CGFloat)angle;



/*! Изменяем размеры картинки по заданным размерам
 *@param newSize новый размер картинки
 *@return возвращаем картинку с измененными размерами
 */
- (UIImage*)scaledImageToSize:(CGSize)newSize;



/*! Изменяем размер картинки под новый размер по большей стороне
 *@param biggerSide устанавливаем большую сторону
 *@return возвращаем картинку
 */
-(UIImage *)resizeImageToBiggerSide:(NSInteger)biggerSide;



/*! Склеииваем картинки друг рядом с другом, для коллажа
 *@param secondImage вторая картинка
 *@param orientation с какой стороны клеить картинку
 *@return возвращаем скреленную картинку
 */
- (UIImage*) mergeImage:(UIImage*)secondImage toOrientation:(MergeOrientaion)orientation;


/*! Склееиваем картинки одна на другую
 *@param imageView картинка пользовательская, средний слой. Внимание, картинка внутри должна быть с правильными пропорциональными размерами, иначе она будет растянута
 *@param lowerImageView нижняя картинка, картинка подложка
 *@param upperImageView верхняя картинка с вырезанной областью
 *@return возвращаем картинку скленную вместе
 */
- (UIImage *) mergeImageView:(UIImageView *)imageView withLowerImageView:(UIImageView *)lowerImageView andUpperImageView:(UIImageView *)upperImageView;



/*! Рисуем на картинке текст. Текст будет располагаться по всей картинке пропорционально
 *@param text надпись
 */
-(UIImage*) drawText:(NSString*) text;
@end
