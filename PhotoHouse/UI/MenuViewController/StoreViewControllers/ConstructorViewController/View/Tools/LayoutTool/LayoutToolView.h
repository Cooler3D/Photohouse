//
//  LayoutTool.h
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/28/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>

//extern NSString *const RemovePageNotification;
//
//extern NSString *const RemovePageKey;


@class Template;
@class Layout;

@interface LayoutToolView : UIView
@property (assign, nonatomic, setter = setSelected:) BOOL hasSelected;

/*! Инициализируем стиль
 *@param frame размер
 *@param selector вызванный метод
 *@param target объкт для событий
 *@param albumTemplate список всех стилей для выбора
 *@param pageIndex номер страницы
 */
- (id) initWithFrame:(CGRect)frame
      andTapSelector:(SEL)tapSelector
           andtarget:(id)target
         andTemplate:(Template *)albumTemplate
     andSelectLayout:(Layout *)selectLayout
        andPageIndex:(NSUInteger)pageIndex;



/*! Устанавливаем выбранный стиль
 *@param layout устанавливает нужный стиль
 */
//- (void) chooseLayout:(Layout *)layout;


/*! Обновляем предпросмотр layout
 *@param image картинка предпросмотра
 */
- (void) updatePreviewImage:(UIImage *)image;



/*! Обновляем номер страницы
 *@param pageIndex номер страницы
 */
- (void) updatePageIndex:(NSInteger)pageIndex;


/*! Получаем список шаблонов
 *@return возвращаем весь список стилей
 */
- (Template *)getTepmpate;



/*! Возвращаем номер страниы разворота
 *@return номер страницы разворота
 */
- (NSUInteger)pageIndex;



/*! Очщаем Layout */
- (void)clearLayout;



///*! Открываем кнопки удаления разворотов */
//- (void) showRemovePageButton;
//
//
//
///*! Скрываем кнопки удаления разворотов */
//- (void) hideRemovePageButtons;


/*! Устанавливаем прогресс 
 *@param progress устанавливаем прогресс отношения заполненный фотографий к всем фотография в развороте
 */
- (void) setProgressImportImages:(CGFloat)progress;

@end
