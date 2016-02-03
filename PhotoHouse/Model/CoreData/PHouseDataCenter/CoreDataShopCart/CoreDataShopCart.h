//
//  CoreDataShopCart.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/16/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHDataManager.h"

@class PrintData;
@class PrintImage;

@interface CoreDataShopCart : PHDataManager
#warning ToDo: Change all search from key = [PrintImage].urlLibrary on [PrintImage].unique_imageID

/// Сохранем в корзине покупку
/*! Сохраняем покупку PrintData в корзине, приходят данные без картинок
 *@warning В начале статус "Не закончена". Чтобы привести к окончательному нужно использовать методы '-finalCompletePrintData', '-savePrepareFinalPrintData'
 *@see method '-finalCompletePrintData'
 *@see method '-savePrepareFinalPrintData'
 *@param printData текущая покупка PrintData может не содержаить изображений
 */
- (void) savePrintData:(PrintData *)printData;



/// Сохранение склеенных изображений
/*! Используется для объектов кружет, футболок, чехлов и тд
 *@param printData активный PrintData, можно передать nil, то будем искать по активным
 *@param printImages массив с PrintImage входящими только скленные фотографии, если нет, будем искать в PrintData
 */
- (void) saveMergedPreviewPrintData:(PrintData *)printData withPrintImages:(NSArray *)printImages;



/// Сохранение большой(оригинальной) картинки
/*! Используется в ShowCaseViewController и ConstructorViewController для сохранения большой картинки
 *@param printData будущий заказ, информация должна содержаться в базе, может быть nil, тогда искать по активным
 *@param printImage редактированная картинка, отсюда возьмем Setting, может быть тоже nil, если картинка если Фотопечать или Альбом
 *@param возращаем уже сформированнй PrintImage, в нем содержится уменьшенные картинки для работы редактора
 */
- (PrintImage *) saveOriginalImagePrintDataUnique:(NSUInteger)print_unique andPrintImage:(PrintImage *)printImage andSocialImageData:(NSData *)imageData;



/// Добавить новые картинки PrintImage к покупке PrintData
/*! Добавить новые картинки в корзину по идентификатору PrintData. В основном вовремя загрузки больщих картинок
 *@param unique иникальный идентификатор PrintData
 *@param printImage добавленная картинка
 */
- (void) addImageWithPrintDataUnique:(NSInteger)unique andImage:(PrintImage *)printImage;



/// Обновляем количество копий из корзины
/*! Обновляем и сохраняем количество копий из корзины, применяется из корзины CartViewController
 *@param printData будущий заказ, информация должна содержаться в базе, может быть nil, тогда искать по активным
 */
- (void) updateCountPrintData:(PrintData *)printData;



/// Обновляем значения Props или Template
/*! Обновляем значения Props при смене цвета и размера футболки или альбома. И обновляем Template из конструктора альбомов.
 *@param printData будущий заказ, информация должна содержаться в базе, может быть nil, тогда искать по активным
 */
- (void) updateTemplateOrPropsPrintData:(PrintData *)printData;



/// После загрузки картинкок на сервер PhotoHouse
/*! Обновляем значение URL(Upload) для картинки PrintImage
 *@param unique уникальный идентификатор для PrintData, по нему будем искать
 *@param printImage картинка, внутри нее должен быть установлен адрес картинки на сервере
 */
- (void) updateAfterUploadPrintDataUnique:(NSInteger)unique andPrintImage:(PrintImage *)printImage;


/// Обновляем данные urlLibrary в PrintImage
/*! Обновляем данные urlLibrary в PrintImage, поиск происходит по старому ключу [PrintImage].urlLibrary, далее присвоим и значение в [PrintImage]
 *@warning Данные метод устанавливает свойства [EditSetting] == Default, т.к начинаем ссылаться на 
 *@param unique уникальный идентификатор PrintData
 *@param printImage картинка со старым значением urlLibrary
 *@param newUrlLibrary новое значение urlLibrary
 */
- (void) updateURLLibraryWithPrintDataUnique:(NSInteger)unique andPrintImage:(PrintImage *)printImage andNewUrlLibraryKey:(NSString *)newUrlLibrary;



/// Обновляем данные после редактора
/*! Обновляем данные по только отредактированной картинке
 *@param printData будущий заказ PrintData, информация должна содержаться в базе, может быть nil, тогда искать по активным
 *@param printImage редактированная картинка PrintImage, отсюда возьмем EditImageSetting, может быть тоже nil, если картинка если Фотопечать или Альбом
 */
- (void) updateAfterEditorPrintData:(PrintData *)printData andPrintImage:(PrintImage *)printImage;


/// Закончили редактирование
/*! Закончили редактирование коговимся к переходу в корзину
 *@param printData будущий заказ, информация должна содержаться в базе, может быть nil, тогда искать будет по processInsert == Yes
 */
- (void) finalCompletePrintData:(PrintData *)printData;



/// Финальное сохранение, только для PrintData.image.count > 1
/*! Финальное сохранение Preview заказов с картинкаим >1. После сохранеия всех редактированных, нужно выполнить '-finalCompletePrintData'
 *@see method '-finalCompletePrintData'
 *@param printData будущий заказ, информация должна содержаться в базе, может быть nil, тогда искать по активным
 *@param printImage редактированная картинка, отсюда возьмем Setting, и картинку
 */
- (void) savePrepareFinalPrintData:(PrintData *)printData andPrintImage:(PrintImage *)printImage;




/// Массив заказов для отображения в корзине
/*! Массив подготовленных заказов, только PrintData, картинок не будет. Если в параметре передать No, то картинок не будет
 *@param needImages нужно ли добавлять картинки в ответ, Yes то время загрузки будет больше, No массив картинок пустой
 *@return массив PrintData
 */
- (NSArray *)getAllItemsWithNeedAddImages:(BOOL)needImages;



/// Получить картинки для заказа в корзине
/*! Получить картинки для заказа в корзине, PrintData будет с картинками
 *@param printData текущая PrintData, в нее буду добавлены картинки все
 *@return возвращаем printData, но уже с картинками
 */
- (PrintData *) getItemImagesWithPrintData:(PrintData *)printData;



/// Получаем PrintImage с оигинальной картинкой вместо previewImage, для отправки на сервер
/* Получаем PrintImage с оигинальной картинкой вместо previewImage, для отправки на сервер
 *@param printData выбранный PrintData
 *@param printImage картинка
 *@return возвращаем картинку с оригинальной картинкой
 */
//- (PrintImage *) getOriginalImagePrintData:(PrintData *)printData andPrintImage:(PrintImage *)printImage __attribute__((deprecated("Remove")));



/// Не редактированную картинку(Без фильтров) для отображения в редакторе
/*! Получаем только картинку Preview Для захода в редактор ShowCase -> Editor, т.к картинка может быть два раза редактированна
 *@param unique уникальный идентификатор PrintData, может быть nil, то будем искть по НЕ сохраненным
 *@param printImage обект картинки, именно в нее буде вставлена стандартная картинка
 *@return возвращаем PrintImage с уже установленной картинкой
 */
- (PrintImage *) getPreviewImageWithPrintDataUnique:(NSInteger)unique andPrintImage:(PrintImage *)printImage;



/// Проверяем не сохраненные до конца покупки в корзине
/*! Проверяем есть ли не сохраненные PrintData в корзине. Если возвращается НЕ nil, то пользователь в процессе заказа не дошел до конца
 *@return возвращаем PrintData, которую не сохранил пользователь, возвращается с картинками
 */
- (PrintData *) getUnSavedPrintData;



/// Получаем массив urlLibrary сохраненных картинок PrintData
/*! Получаем имена сохраненных картнок в корзине, если покупка не была в нормальном режиме добавлена в корзину
 *@param unique если 0, то возьмем не сохраненную в корзине, если передать цифру в отличие от 0, то будет искать по уникальному номеру
 *@return возвращается массив с именами urlLibrary, если он пустой, то нет картинок и это первый заход
 */
- (NSArray *) getUnsavedURLNamesPrintData:(NSInteger)unique;



/// Удалаяем элемент PrintData по идентификатору unique
/*! Удаляем элемент по уникальному идентификатору в основном из корзины
 *@param unique уникальный идентификатор, можно передать 0(ноль), то будет искать по активному
 *@param completeBlock блок исполнения
 */
- (void) removeFromShopCartUnique:(NSInteger)unique withBlock:(void(^)(void))completeBlock;



/// Удалаяем не используемые картинки из конструктора альбомов
/** Удалаяем неиспользуемые картинки. Вызывать перед методом '-finalCompletePrintData'. Используем в кончтрукторе альбомов, т.к не все картинки могут быть на разворотах.
 *@see method '-finalCompletePrintData'
 *@param urlLiabraryImages массив ссылок на картинки. PrintImage.urlLibrary, передаем массив ссылок, которые нужно удалить
 */
- (void) removeImages:(NSArray *)urlLiabraryImages;



/// Удалаяем все из корзины
- (void) removeAll;
@end
