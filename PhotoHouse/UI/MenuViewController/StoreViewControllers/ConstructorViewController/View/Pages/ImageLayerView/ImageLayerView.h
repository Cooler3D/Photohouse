//
//  ImageLayerView.h
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/30/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LayerBack,
    LayerFront
} LayerType;

@class Image;
@class PrintImage;

@interface ImageLayerView : UIView
@property (assign, nonatomic, readonly) LayerType layertype;

/*! Инициализируем выбранный фейм для картинки
 *@param frame
 *@param imageLayer
 *@param layerType
 */
- (id) initWithFrame:(CGRect)frame andImageLayer:(Image *)imageLayer andLayerType:(LayerType)layerType;



/*! Выбрана ли картинка
 *@return yes выбранна, no не выбрана
 */
- (BOOL) isSelected;


/*! Получаем urlLibrary адрес картинки
 *@return возвращается urlLibrary загруженной картинки
 */
- (NSString *) urlLibrary;


/*! Отменить выделение */
- (void) cancelSelection;



/*! Устанавливаем картинку
 *@param image картинка
 */
- (void) setSelectPrintImage:(PrintImage *)printImage;



/*! Убираем картинку
 *@return возвращаем urlLibrary для картинки
 */
- (NSString *) removeImage;



/*! Есть ли картинка
 *@return возвращется yes, если есть, no, то нет
 */
- (BOOL) hasImage;
@end
