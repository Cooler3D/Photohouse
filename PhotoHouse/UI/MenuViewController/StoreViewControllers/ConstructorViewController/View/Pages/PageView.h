//
//  PageView.h
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/10/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString *const AddPageNotification;
extern NSString *const RemovePageNotification;

extern NSString *const RemovePageKey;


@class Layout;
@class PrintImage;




@interface PageView : UIView

/// Разворот
@property (strong, nonatomic, readonly) Layout *layout;


/// Картинка предпросмотре Layout
@property (strong, nonatomic, readonly) UIImage *previewLayout;



/*! Инициализируем Страницу
 *@param frame где размещать, указываем CGRect куда будет прямопорпорционально встроенна страница
 *@param layout данные для страницы
 *@param pageIndex страница разворота
 */
- (id) initWithFrame:(CGRect)frame andLayout:(Layout *)layout andPageIndex:(NSInteger)pageIndex;



/*! Устанавливаем выбранный стиль
 *@param выбранный стиль
 *@param frame рамка
 */
//- (void) initLayout:(Layout *)layout andFrame:(CGRect)frame andPageIndex:(NSInteger)pageIndex;


/*! Обновляем номер страницы
 *@param pageIndex номер страницы
 */
- (void) updatePageIndex:(NSInteger)pageIndex;



/*! Сравниваем со всели картинками на странице, во время восстановления синхронизации
 *@param printImage картинка в библиотеке
 *@return если находит, то возвращается Yes и устанавливается внутри
 */
- (BOOL) compaseSyncPrintImage:(PrintImage *)printImage;



/*! Импорт Image
 *@param image картинка которую нужно установить
 */
- (void) importImage:(PrintImage *)image;



/*! Удаляем картинку 
 *@return возвращаем строку urlLibrary для убраниея выделения из ToolView
 */
- (NSString *) removeImage;



/*! Удаляем страничку, возвращаюется массив ссылок на картинки urlLibrary
 *@return возвращаем массив сслылок на картинки, если есть
 */
- (NSArray *) removePage;



/*! Получаем номер страницы 
 *@return возвращаем номер страницы
 */
- (NSInteger)pageIndex;



/*! Получаем прогресс
 *@return возвращается отношение вставленных картинок ко всем картинкам в развороте
 */
- (CGFloat) progress;


/** Возвращаем массив заполненных фотографий
 *@return возвращаем массив заполненных фотографий
 */
- (NSArray *) imagesUrls;
@end
