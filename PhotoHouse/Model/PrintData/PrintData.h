//
//  PrintData.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/14/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "StoreItem.h"


@class Template;
@class PrintImage;


/*!
 @brief Покупка пользователя.\n
 Представляет собой сфорированную покупку для отправки на сервер PhotoHouse
 Вы можете добавлять картинки, удалять, Менять параметры.\n
 Также менять цвет, размер, обложку, и др параметры иесли у них есть выбор.\n
 Вместе с эти объектом используется:\n
 StoreItem - идетификатор покупки, при выборе в магазине StoreViewController, хранятся в CoreDataStore\n
 Template - шаблон для конструктора альбомов\n
 
 @warning Большинство методов в данном объекте работает только с объектом. Т.к сам объект это сформированная покупка хранится в CoreDataShopCart. Вам нужно дополнительно обращаться CoreDataShopCart. Т.к может идти активный процесс сохранения.
 @code
 CoreDataShopCart *coreCart = [[CoreDataShopCart alloc] init];
 @endcode
 @author Дмитрий Мартынов dimast85@inbox.ru
 */
@interface PrintData : NSObject
- (PhotoHousePrint) purchaseID; ///< Тип покупки, приходит от сервера
- (NSString *) namePurchase;    ///< Название покупки, кружка, футболка и тд
- (NSString *) nameType;        ///< Имя типа,
- (NSString *) nameCategory;    ///< Имя категории, Альбомы, Сувениры и подарки и тд
- (NSUInteger) count;           ///< Количество копий, изменяется в корзине
- (NSUInteger) price;           ///< Цена покупки
- (NSArray *) imagesPreview;    ///< Картинки, без скленых
- (NSArray *) images;           ///< Все картинки и скленные и обычные
- (NSArray *) mergedImages;     ///< Массив PrintImage, только скренные картинки
- (NSArray *) uploadURLs;       ///< Массив адресов загрузки
- (NSArray *) imagesNames;      ///< Массив адресов картинок в библиотеке и адреса загрузки

- (UIImage *) iconShopCart;     ///< Картинка для Корзины
- (UIImage *) gridImage;        ///< Картинка с сеткой для редактора
- (UIImage *) showCaseImage;    ///< Картинка для превью в витрине(ShowCase)

- (NSDictionary *)props;        ///< Props для отправки на сервер
- (NSInteger) unique_print;     ///< Уникальный идентификатор, для поиска в CoreDataShopCart
- (StoreItem *) storeItem;      ///< Информация о покупке StoreItem


/// Меняем параметра, цвета, размера, стиля
/** Меняем один из параметров в Props (Стиль, Обложка, Размер, Кол-во разворотов)
 *@param object может быть как PropStyle, PropsCover, PropColor, PropSize, PropUturn
 */
- (void) changeProp:(NSObject *)object;


/// Удаляем все картинки
/** Удалаем изображения из объекта
 *@warning Картинки не удаляются из CoreDataShopCart, нужно обращаться к removeImages
 *@code
 CoreDataShopCart *coreCart = [[CoreDataShopCart alloc] init];
 [coreCart removeImages:];
 *@endcode
 */
- (void) removeAllImages;


/// Удалаяем картинки
/** Удаляем картинки по адресам, удаляется из объекта
 *@warning Картинки удаляются только из объекта PrintData, для удаления из CoreDataShopCart используйте метод removeImages
 *@code 
 CoreDataShopCart *coreCart = [[CoreDataShopCart alloc] init];
 [coreCart removeImages:];
 *@endcode
 *@param urls массив urlLibrary для картинок
 */
- (void) removeImagesWithUrls:(NSArray *)urls;



/// Менаяем кол-во копий из корзины
/*! Меняем кол-во копий, используется в корзине при смене количества
 *@param count кол-во копий
 */
- (void) changeCount:(NSInteger)count;



/// Добавляем новые картинки
/*! Добавляем картинки к текущим, нужно передавть чтобы не повторялись
 *@param array массив PrintImage
 */
- (void) addPrintImagesFromPhotoLibrary:(NSArray *)array;



/// Обновляем пользовательский шаблон Template
/*! Обновляем пользовательский шаблон с фотографиями пользователя Template
 *@param userTemplate пользовательский шаблон и фотографиями поьзователя
 */
- (void) updateUserTemplate:(Template *)userTemplate;


/// Создаем скленные картинки (UnitTestOnly)
/*! Создаем склеенные картинки и сохраняем в CoreDataShopCart (UnitTestOnly)
 *@param printImage текущая PrintImage для которой требуется сохранить
 *@see '-createMergedImageWithPreview:andCompleteBlock:'
 */
- (void) createAndAddMergedImageWithPrintImage:(UIImage *)image;// NS_DEPRECATED_IOS(2_0, 7_0, "Use -createMergedImageWithPreview:. This methos only for UTest");


/// Склееваем пользовательскую картинку с объектом(Кружка,Футболка и тд)
/*! Склееваем картинки(пользовательскую и объекта) на основе исходной и сохраняем в CoreDataShopCart
 *@param previewImage исходная картинка, которая будет наноситься на объекты
 *@param completeBlock блок для выполнения
 */
- (void) createMergedImageWithPreview:(UIImage *)previewImage andCompleteBlock:(void(^)(NSArray *images))completeBlock andProgressBlock:(void(^)(CGFloat progress))progressBlock;


/// Инициализация по истории заказов
/** Инициализируем объект по истории заказов
 *@param order_items передаем данные ответа от сервера order_item
 */
- (id) initWithHistoryOrderItemsDictionary:(NSDictionary *)order_items;


/// Иницализируем из сохраненных из CoreDataShoCart
/** Инициализируем при выборе через магазин или CoreDataShopCart
 *@param storeItem передаем класс уже выбранные компонент
 *@param unique уникальный идентификатор, если 0, то сам сгенерирует сам
 */
- (id) initWithStoreItem:(StoreItem *)storeItem andUniqueNum:(NSInteger)unique;


/// Заменяем оригинальную PrintImage на ту с коротой будем работать в ShowCaseViewController или ConstructorViewController
/*! Заменяем Сохраненную PrintImage в массиве картинкок или добавляем, Заменение происходит после сохранения оригинала в CoreDataShopCart
 *@param printImage текущая printImage
 */
- (void) replacePreviewPrintImage:(PrintImage *)printImage;

@end
