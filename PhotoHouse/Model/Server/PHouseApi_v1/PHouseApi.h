//
//  PH_Api.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PHResponse.h"


@class PrintData;
@class PrintImage;
@protocol PHouseApiDelegate;

/*!
 \brief Класс взаимодействия с Api сервера PhotoHouse. Ответы приходят через PHouseApiDelegate
 \code
 PHouseApi *pApi = [PHouseApi alloc] init];
 \endcode
 \warning Наследование от PHResponse нужно убрать
 \author Дмитрий Мартынов
 */
@interface PHouseApi : PHResponse
@property (weak, nonatomic) id<PHouseApiDelegate> delegate;

/// Баннеры
/** Получаем баннеры. Ждесь же они сохраняются в CoreData
 *@param delegate возвращаем через делегат
 */
- (void) getBannersWithDelegate:(id<PHouseApiDelegate>)delegate;


/// Товары для покупки
/** Получаем все товары для магазина, а так же шаблоны альбомов контруктора
 *@param delegate возвращаем через делегат
 */
- (void) getAllItemsWithDelegate:(id<PHouseApiDelegate>)delegate;



/// Авторизуемся
/** Авторизуемся через данные
 *@param login адрес почты
 *@param passwordMD5 пароль зашифрованный MD5
 *@param delegate возвращаем через делегат
 */
- (void) authLogin:(NSString *)login
   andPasswordHash:(NSString *)passwordHash
       andDelegate:(id<PHouseApiDelegate>)delegate;


/// Авторизуемся
/** Авторизуемся на PhotoHouse
 *@param delegate возвращаем через делегат
 */
- (void) authWithDelegate:(id<PHouseApiDelegate>)delegate;



/// Выходим, стираем данные о пользователе
- (void) logout;


/// Регистрация
/** Регистрируем нового пользователя
 *@param firstname имя пользователя
 *@param lastName фамилия потльзователя
 *@param email адрес почты
 *@param password пароль
 *@param delegate возвращаем через делегат
 */
- (void) registationFirstName:(NSString *)firstname
                  andLastName:(NSString *)lastName
                     andEmail:(NSString *)email
                 withPassword:(NSString *)password
                  andDelegate:(id<PHouseApiDelegate>)delegate;



/** Получаем все типы доставки
 *@param delegate возвращаем через делегат
 */
- (void) getDeliveriesWithDelegate:(id<PHouseApiDelegate>)delegate orBlock:(void(^)(PHResponse *responce, NSError *error))completeBlock;



/** Получаем последний введенный телефон
 *@param delegate возвращаем через делегат
 */
- (void) getPhonesListAndSaveToProfileWithDelegate:(id<PHouseApiDelegate>)delegate;



/** Сравниваем адрес сохраненный с текущим и сохраняем, если старый адрес пустой
 *@param address адрес указанный пользователем или возвращенный с сервера
 */
- (void) getAddressListAndSaveToProfileWithDelegate:(id<PHouseApiDelegate>)delegate;



/** Получаем диапозон картинок и для товаров и сохраняем. This method is deprecated
 *@see 'getAllItemsWithDelegate'
 */
//- (void) getImageCountAndSave __attribute__((deprecated("use '-getAllItemsWithDelegate' instead")));



/*! Получаем список всех шабломов для альбомного конструктора. This method is deprecated
 *@warning данный метод закрыт для поддержки
 *@see 'getAllItemsWithDelegate'
 *@param delegate возвращаем через делегат
 */
//- (void) getAllAlbumTemplates:(id<PHouseApiDelegate>)delegate __attribute__((deprecated("use '-getAllItemsWithDelegate' instead")));



/** Получаем все цены для товаров и сохраняем
 */
//- (void) getPricePurchaseAndSave;



/** Получаем Props по id-товара
 *@param item_id id товара
 *@param delegate возвращаем через делегат
 */
//- (void) getPropByIDAndSave:(NSInteger)item_id
//                andDelegate:(id<PHouseApiDelegate>)delegate;


/// История заказов
/** Получаем всю историю заказов
 *@param delegate возвращаем через делегат
 */
- (void) getHistoryAllOrders:(id<PHouseApiDelegate>)delegate;



/// Оплачиваем заказ
/** Оплачиваем заказ
 *@praram order_id заказ по которому требуется вернуть
 *@param delegate возвращаем через делегат
 */
- (void) payOrderID:(NSString *)order_id andDelegate:(id<PHouseApiDelegate>)delegate;



/// Берем сохраненный Template и сохраняем в CoreData. @warning если по каким либо причинам шаблон для конструктора не доступен, берем и формируем значения по умолчанию
- (void) saveDefaultTemplates;


/** Загружаем картинку
 *@param record возвращаем через делегат
 *@param completeBlock блок, картинка успешно загрузилась
 *@param progressBlock блок, процесс загрузки
 *@param errorBlock блок, ошибка загрузки картинки
 */
/*- (void) uploadImageFromRecord:(PhotoRecord*)record
                isUploadMerged:(BOOL)isUploadMerged
       andCompleteBlockSuccess:(void(^)(NSData *responseData))completeBlock
             andUpdateProgress:(void(^)(CGFloat progress))progressBlock
             andErrorBlockFail:(void(^)(NSError *error))errorBlock;*/



/// Загружаем картинку
/** Загружаем картинку на сервер Photohouse
 *@param printImage картинка PrintImage пользователя для заказа
 *@param completeBlock блок, картинка успешно загрузилась
 *@param progressBlock блок, процесс загрузки
 *@param errorBlock блок, ошибка загрузки картинки
 */
- (void) uploadImageFromPrintImage:(PrintImage *)printImage
           andCompleteBlockSuccess:(void(^)(NSString *responseURL))completeBlock
                 andUpdateProgress:(void(^)(CGFloat progress))progressBlock
                 andErrorBlockFail:(void(^)(NSError *error))errorBlock;



/// Отправляем заказа
/** Делаем заказ после успешной отправки картинок. 
 *@warning Данный метод вызыватся только когда все картинки для заказа были загружены на PhotoHouse
 *@see method '-uploadImageFromPrintImage:andCompleteBlockSuccess:andUpdateProgress:andErrorBlockFail:'
 *@param firstname имя пользователя
 *@param lastName фамилия потльзователя
 *@param phone телефон
 *@param address адрес достаки или самовывоза
 *@param text комментарии к заказу
 *@param cartArray данные заказа
 *@param delegate возвращаем через делегат
 */
- (void) makeOrderFirstName:(NSString*)firstName
                andLastName:(NSString*)lastName
                   andPhone:(NSString*)phone
                 andAddress:(NSString*)address
                withComment:(NSString*)text
       andPhotoRecordsArray:(NSArray*)cartArray
        andDeliveryPrintDta:(PrintData*)deliveryPrintData
                andDelegate:(id<PHouseApiDelegate>)delegate;



/// Отправляем сообщение FeedBack
/** Отправляем сообщение на сервер Photohouse
 *@param feedtype тип обратной связи
 *@param title тема сообщения
 *@param message сообщение
 *@param email адрес почты
 *@param delegate возвращаем через делегат
 */
- (void) feedbackType:(NSInteger)feedtype
             andTitle:(NSString *)title
           andMessage:(NSString *)message
             andEmail:(NSString *)email
          andDelegate:(id<PHouseApiDelegate>)delegate;


/// Отменяем заказ
/** Отменяем заказ по номеру заказа и пользователю
 *@param order_id номер заказ
 *@param user_id id пользователя
 *@param delegate возвращаем через делегат
 */
- (void) cancelOrderID:(NSString *)order_id
             andUserID:(NSString *)user_id
           andDelegate:(id<PHouseApiDelegate>)delegate;



/// Восстанавливаем пароль
/** Восстанавливаем пароль
 *@param email адрес почты
 *@param delegate возвращаем через делегат
 */
- (void) restorePassWithEmail:(NSString *)email andDelegate:(id<PHouseApiDelegate>)delegate;



/// Получаем список всех команд
- (void) getApiCommands;


/// Возвращаем Salt для генерации пароля @return возвращаем Salt
- (NSString *)salt;


/** Получаем значения времени команд
 *@param delegate возвращаем через делегат
 */
- (void) getUpdateTimeWithDelegate:(id<PHouseApiDelegate>)delegate;
@end




@protocol PHouseApiDelegate <NSObject>
@optional
- (void) pHouseApi:(PHouseApi *)phApi didBannerReceiveData:(NSArray *)banners;
- (void) pHouseApi:(PHouseApi *)phApi didStoreItemsReceiveData:(PHResponse *)response;
- (void) pHouseApi:(PHouseApi *)phApi didAuthReceiveData:(PHResponse *)response;
- (void) pHouseApi:(PHouseApi *)phApi didDeliveriesReceiveData:(PHResponse *)response;
- (void) pHouseApi:(PHouseApi *)phApi didReqistrationReceiveData:(PHResponse *)response;
- (void) pHouseApi:(PHouseApi *)phApi didLastPhone:(NSString *)phone;
- (void) pHouseApi:(PHouseApi *)phApi didLastAddress:(NSString *)address;
- (void) pHouseApi:(PHouseApi *)phApi didFeedBackData:(PHResponse *)response;
- (void) pHouseApi:(PHouseApi *)phApi didMakeOrderCompleteData:(PHResponse *)response;
- (void) pHouseApi:(PHouseApi *)phApi didHistoryOrdersData:(NSArray *)allOrders;
- (void) pHouseApi:(PHouseApi *)phApi didCanceledOrder:(PHResponse *)response;
- (void) pHouseApi:(PHouseApi *)phApi didPayURL:(NSURL *)payURL;
- (void) pHouseApi:(PHouseApi *)phApi didRestorePassData:(PHResponse *)response;
- (void) pHouseApi:(PHouseApi *)phApi didUpdateTime:(PHResponse *)response;

- (void) pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error;
@end