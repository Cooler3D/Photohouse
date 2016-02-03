//
//  EditImageConfigurator.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 11/18/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const DEFAUL_FILTER;

extern CGFloat const DEFAULT_SATURATION;
extern CGFloat const DEFAULT_BRIGHTNESS;
extern CGFloat const DEFAULT_CONSTRAST;


/*!
 @brief Объект настройки редактора фотографии.\n
 Содержит в себе настройки фильтра, поворота, яркости, контраста, освещенности.
 Данный объект не применяет фильтры, контрасты к картинке
 
 @author Дмитрий Мартынов
 */
@interface EditImageSetting : NSObject

@property (nonatomic, strong, readonly) NSString *filterName;           ///< Фильтр примененный к картинке

@property (nonatomic, assign, readonly) CGFloat saturationValue;        ///< Значение saturation
@property (nonatomic, assign, readonly) CGFloat brightnessValue;        ///< Значения brightness
@property (nonatomic, assign, readonly) CGFloat contrastValue;          ///< значение контраста

@property (nonatomic, assign, readonly) CGRect cropRect;                ///< Rect по которому вырезаем оригинальную картинку для отправки на сервер
@property (nonatomic, assign, readonly) CGRect rectToVisibleEditor;     ///< Размеры и позиция imageView в редакторе, для правильной позиционирования

@property (nonatomic, assign, readonly) BOOL isAutoResizing;            ///< Включана ли автозаполнение по сетке

@property (nonatomic, assign, readonly) UIImageOrientation imageOrientation;    ///< Ориентация картинки для редактора и отображения
@property (nonatomic, assign, readonly) UIImageOrientation imageDefaultOrientation; ///< Ориентация картинки, которая была при сохранении, нужно для правильного вращения на сервере

@property (nonatomic, assign, readonly) CGSize editedImageSize;         ///< Размер картинки после увеличения, используется в конструкторе альбомов

/// Редактировалась ли картинка или нет
/*! Редактировалось или нет
 *@return возвращаем Yes от default значений, NO все по умолчанию
 */
- (BOOL) isDidEditing;


/// Изменяем фильтр
- (void) changeFilter:(NSString *)filterName;
/// Изменяем Saturation
- (void) changeSaturation:(CGFloat)satiration;
/// Изменяем Brightness
- (void) changeBrightness:(CGFloat)brightness;
/// Изменяем Contrast
- (void) changeContrast:(CGFloat)contrast;
/// Изменяем CropRest
- (void) changeCropRect:(CGRect)cropRect;
/// Изменяем CropVisible
- (void) changeCropVisible:(CGRect)cropVisible;
/// Изменяем autoResised
- (void) changeAutoResize:(BOOL)resize;
/// Изменяем Orientation
- (void) changeOrientation:(UIImageOrientation)orintation;
/// Изменяем Orientation
- (void) changeOrientationDefault:(UIImageOrientation)orintationDefault;

/// Устанавливаем значения по-умолчанию
- (void) changeSetupDefault;


/// Изменяем в редакторе размеры картинки, до каких значений увеличили
- (void) changeEditedImageSize:(CGSize)size;


/// Иницализируем по сохраненным значениям из CoreDataShopCart
/*! Инициализируемся по параметрам из CoreDataShopCart
 *@param filterName имя фильтра
 *@param saturation параметр
 *@param brightness параметр
 *@param contrast параметр
 *@param cropRect прямоугольник для обрезки фотографии, если пользователь заходил в редактор
 *@param rectToVisible прамоугольник для правильной ориентации при повторном заходе в редактор
 *@param autoResizeEnabled включено ли было автозаполнение
 *@param orientation ориентация картинки
 */
- (id) initFilterName:(NSString*)filterName
        andSaturation:(CGFloat)saturation
        andBrightness:(CGFloat)brightness
          andContrast:(CGFloat)contrast
          andCropRect:(CGRect)cropRect
     andRectToVisible:(CGRect)rectToVisible
andAutoResizingEnabled:(BOOL)autoResizeEnabled
  andImageOrientation:(UIImageOrientation) orientation
andImageDefautlOrientation:(UIImageOrientation)orientationDefault;



/// Иницализируем по картинке
/*! Инициализируемся по умолчанию по картинке
 @param image картинка
 */
- (id) initSettingWithImage:(UIImage *)image;




/// Применяем значения для картинки
/*! Применяем значения контрастов и к картинке
 *@param image картинка к торой применяем
 *@return картинку с уже измененными значениями
 */
- (UIImage *) executeImage:(UIImage *)image;


- (void) executeImage:(UIImage*)image withCompleteBlock:(void(^)(UIImage *resultImage))completeBlock;


- (void) imageDidEdided;
- (void) clearEdited;
@end
