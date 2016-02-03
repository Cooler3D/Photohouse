//
//  SaveImageManager.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/10/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>


/// Статус сохранения заказа, в основном идет сохранение картинок
typedef enum {
    SaveProgressWait,               ///< Ожидание, когда зашли и не выбрали не одной картинки
    SaveProgressBackgroundActive,   ///< Загрузка в фоне, картинки сохраняются в фоне
    SaveProgressBackgroundFinish,   ///< Загрузка в фоне закончилась
    SaveProgressActive,             ///< Активная загрузка, картинки сохраняются в активном режиме и показыватся загрузчик
    SaveProgressFinish              ///< Загрузка активная закончена, переходим в корзину
} SaveProgressStatus;


@class PrintData;
@class PrintImage;
@protocol SaveImageManagerDelegate;



/*!
 @brief Менеджер сохранения картинок в CoreDataShopCart.\n
 Вызывается из контроллеров ShowCaseViewController, ConstructorViewController.\n
 
 @author Дмитрий Мартынов
 */
@interface SaveImageManager : NSObject
@property (weak, nonatomic) id<SaveImageManagerDelegate> delegate;

/// Иницализируем менеджера сохранения в CoreDataShopCart
/*! Иницилизируем менеджа для сохранений больших изображений в корзину(CoreDataShopCart).
 *@param printData текущая покупка
 *@param delegate делегат
 *@param printImages объекты PrintImage, которые нужно сохранить, идут отдельно, т.к в PrintData уже есть картинки, эти дополнительные. Может быть nil
 */
- (id) initManagerWithPrintData:(PrintData *)printData andDelegate:(id<SaveImageManagerDelegate>)delegate orPrintImages:(NSArray *)printImages;


/// Иницализируем для финального сохранения перед переходом в Корзину
/*! Иницализируем менеджера для финального сохранения картинок в корзину и настроек, только для заказов с картинками >1
 *@param printData текущая покупка
 *@param delegate делегат
 */
- (id) initFinalSavePrintData:(PrintData *)printData andDelegate:(id<SaveImageManagerDelegate>)delegate;



/// Стартуем сохранение
- (void) startSave;



/// Останавливаем сохранение
- (void) stopSave;



///** Пересохраняем картинки
// *@param printData текущая покупка
// *@param printImages объекты PrintImage, которые нужно сохранить, идут отдельно, т.к в PrintData уже есть картинки, эти дополнительные. Может быть nil
// */
////- (void) resaveImages:(PrintData *)printData andPrintImages:(NSArray *)printImages;
@end



@protocol SaveImageManagerDelegate <NSObject>
@required
/// Сохранили все большие картинки картинки
/*! Сохранили все большие картинки в корзине CoreDataShopCart
 *@param manager манаджер сохранения
 *@param printData текущая покупка картинки которой сохраняли
 */
- (void) saveImageManager:(SaveImageManager *)manager didAllBigImagesSaved:(PrintData *)printData;



/// Сохранили одну картинку
/*! Сохранили одну картинку и показываем ее.
 *@param manager манаджер сохранения
 *@param printImage картинка уже уменьшенная и готовая к редактированию
 *@param printData текущая покупка картинки которой сохраняли
 */
- (void) saveImageManager:(SaveImageManager *)manager didBigImagesSaved:(PrintImage *)printImage withPrintData:(PrintData *)printData;



/// Процесс сохранения
/*! Показывает сохранение картинки от общего количества
 *@param manager манаджер сохранения
 *@param progress прогресс сохранения
 */
- (void) saveImageManager:(SaveImageManager *)manager didSavedToProgress:(CGFloat)progress;



/// Сохранены все фотки
/*! Вызывается, когда все фотографии окончательно сохранены после редактирования. Пользователь мог во время сохранения(обычного) редактировать фотки, чтобы эти данные могли сохраниться.
 *@param manager манаджер сохранения
 *@param printData текущая покупка картинки которой сохраняли
 */
- (void) saveImageManager:(SaveImageManager *)manager didSaveAllToPrepareFinalSave:(PrintData *)printData;



/// Отмена сохранения
/*! Если прошла отмена сохранения, то остановилась очередь
 *@param manager манаджер сохранения
 *@param printData текущая покупка картинки которой сохраняли
 */
- (void) saveImageManager:(SaveImageManager *)manager didCancelSave:(PrintData *)printData;

///** Resave, требуется пересохранение картинок. Метод вызывается когда, сохранение зависло.
// *@param manager объект сохранялки
// *@param printData объект покупки, картинки могу содержаться в нем, содержатся все картинки
// *@param printImages массив с картинками, если ситиуация, когда догружали картинки уже к имеющимся.Может быть nil
// */
//- (void) saveImageManager:(SaveImageManager *)manager didReSave:(PrintData *)printData andRemovedPrintImages:(NSArray *)printImages __attribute__((deprecated("don't use")));
@end