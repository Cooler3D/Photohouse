//
//  Template.h
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/9/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const TemplateDownloadComplateNotification;
extern NSString *const TemplateDownloadProgressNotification;
extern NSString *const TemplateDownloadErrorNotification;
extern NSString *const TemplateKey;
extern NSString *const TemplateProgressKey;
extern NSString *const TemplateErrorKey;

@class Layout;

/*!
 \brief Класс конструктора альбомов
 
 Данный класс используется для парсинга данных от сервера, а так же манипуляции с разворотами констрктора
 Может содержать пользовательский шаблон, который требуется синхронизировать с CoreDataShopCart.\n
 Сожержатся внутри развороты Layout
 
 \author Дмитрий мартынов
 \warning для отображения на экране используйте класс PageView
 */
@interface Template : NSObject
@property (strong, nonatomic, readonly) NSString *fontName;     ///< Имя шрифта
@property (strong, nonatomic, readonly) NSString *name;         ///< Имя шаблона
@property (strong, nonatomic, readonly) NSString *id_template;  ///< Идентификатор шаблона
@property (strong, nonatomic, readonly) NSString *size;         ///< Размер шаблона 15х20, 20х20
@property (strong, nonatomic, readonly) NSArray *layouts;       ///< Массив разворотов Layout

@property (strong, nonatomic, readonly) Layout *layoutCover;    ///< Layout Обложка
@property (strong, nonatomic, readonly) NSArray *layoutPages;   ///< Массив разворотов, здесь не обложки


/// Иницализация по ответу от сервера
/*! Иницализируем по данным из JSON сервера
 *@param dictionary ответ от сервера
 */
- (id) initTemplateDictionary:(NSDictionary *)dictionary;



/// Иницализируем из CoreDataAlbumConstructor
/*! Иницализируем из CoreDataAlbumConstructor и считываем данные
 *@param name имя шаблона
 *@param fontName название шрифта
 *@param id_template идентификатор шаблона
 *@param size размер шаблона
 *@param layouts массив Layout со значениями
 */
- (id) initTemplateName:(NSString *)name andFontName:(NSString *)fontName andIdTemplate:(NSString *)id_template andSize:(NSString *)size andLayouts:(NSArray *)layouts;


/// Проверяем есть ли картинки верстки
/*! Проверяем Есть ли загруженная верстка картинок
 *@return возращаем Yes если все хорошо, NO картинок нету и требуется загрузка
 */
- (BOOL) hasImageDesign;



/// Получаем массив словерей для заказа
/** Получаем массив словарей(Dictionary) для отправки на сервер
 *@return возвращается массив layouts(Dictionary) для отправки на сервер
 */
- (NSArray *) getUserLayoutsDictionaries;


/// Получаем словарь пользовательского шаблона
/** Получаем Dictionary пользовательского шаблона, со всем ммылками
 *@return возвращаем словарь пользовательского шаблона-альбома
 */
- (NSDictionary *) getUserTemplateDictionary;



/// Начинаем загрузку картинок верстки @note ответ придет по событию NSNotification - TemplateDownloadComplateNotification, TemplateDownloadErrorNotification
- (void) downloadImages;
@end
