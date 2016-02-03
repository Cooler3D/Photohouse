//
//  Layout.h
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/9/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Layer;
@class PlaceHolder;

extern NSString *const LayoutCover;
extern NSString *const LayoutPage;


/*!
 \brief Одна страница в альбоме
 
 \warning старый, нужно изменить на v2 получать сохранять и отправлять
 \author Дмитрий Мартынов
 */
@interface Layout : NSObject
@property (strong, nonatomic, readonly) NSString *id_layout;            ///< Идентификатор страницы
@property (strong, nonatomic, readonly) NSString *layoutType;           ///< Тип страницы, обложка или страница
@property (strong, nonatomic, readonly) NSString *template_psd;         ///< Адрес psd
@property (strong, nonatomic, readonly) Layer *backLayer;               ///< Нижний слой
@property (strong, nonatomic, readonly) Layer *frontLayer;              ///< Верхний слой
@property (strong, nonatomic, readonly) Layer *clearLayer;              ///< Не используется @warning не используется
@property (assign, nonatomic, readonly) NSInteger pageIndex;            ///< Страница, требуется при формировании и отправке на Photohouse
@property (strong, nonatomic, readonly) PlaceHolder *combinedLayer;     ///< Из нового парсера альбомов
@property (assign, nonatomic, readonly) CGRect noscaleCombinedLayer;    ///< Из нового парсера альбомов


/*! Иницализиуем по данным из сервера
 *@param dictionary данные из сервера
 */
- (id) initLayoutDictionary:(NSDictionary *)dictionary;



/*! Иницализируем по CoreData
 *@param id_layout идентификатор разворота
 *@param layoutType тип разворота, обложка или страница
 *@param templatePsd строка адреса PSD
 *@param backLayer задний слой
 *@param frontLayer передний слой
 *@param clearLayer слой помарок
 *@param pageIndex номер страницы
 */
- (id) initLayoutWithID:(NSString *)id_layout
          andLayoutType:(NSString *)layoutType
         andtemplatePSD:(NSString *)templatePsd
           andBackLayer:(Layer *)backLayer
          andFlontLayer:(Layer *)frontLayer
          andClearLayer:(Layer *)clearLayer
           andPageIndex:(NSInteger)pageIndex andCombinedLayer:(PlaceHolder*)combinedLayer andNoscaleCombinedLayer:(CGRect)noscaleCombinedLayer;


/*! Обновляем сведения о номере страницы, т.к по ней из CoreData мы будет выстраивать очередность
 *@param pageIndex номер страницы
 */
- (void) updatePageIndex:(NSInteger)pageIndex;



/** Получаем данные для отправки шаблона
 *@return возвращается словарь, для отправки на сервер пользовательского шаблона
 */
- (NSDictionary *) layoutDictionary;
@end
