//
//  StoreItem.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/23/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PropType;
@class DeliveryCity;

/// Категории товаров, отображается в магазине в запуске. Используется в categoryID
typedef enum {
    StoreTypePhotoPrint = 2,///< Фотопечать
    StoreTypeSovenir    = 3,///< Сувениры
    StoreTypeCoverCase  = 4,///< Чехлы
    StoreTypePhotoAlbum = 1,///< Альбомы
    StoreTypeSpecial    = 5 ///< Спецюпредложения
} StoreType;


/// Идентификатор покупки или категории покупок
typedef enum {
    PhotoHousePrintMug          = 1,    ///< Кружка
    PhotoHousePrintTShirt       = 2,    ///< Фублока
    PhotoHousePrintMouseMag     = 3,    ///< Коврик для мыши
    PhotoHousePrintPuzzle       = 4,    ///< Мозайка
    PhotoHousePrintIPhone4      = 5,    ///< Чехол IPhone4
    PhotoHousePrintIPhone5      = 6,    ///< Чехол IPhone5
    PhotoHousePrintPhoto8_10    = 7,    ///< Фотопечать 8х10
    PhotoHousePrintPhoto10_15   = 8,    ///< Фотопечать 10х15
    PhotoHousePrintPhoto10_13   = 9,    ///< Фотопечать 10х13
    PhotoHousePrintPhoto13_18   = 10,   ///< Фотопечать 13х18
    PhotoHousePrintPhoto15_21   = 11,   ///< Фотопечать 15х21
    PhotoHousePrintPhoto20_30   = 12,   ///< Фотопечать 20х30
    PhotoHousePrintAlbum        = 13,   ///< Альбом
    PhotoHousePrintMagnit       = 14,   ///< Магнит
    PhotoHousePrintBrelok       = 15,   ///< Брелок
    PhotoHousePrintClock        = 16,   ///< Часы
    PhotoHousePrintHolst        = 17,   ///< Холст
    PhotoHousePrintPlate        = 18,   ///< Тарелка
    
    PhotoHousePrintDelivery     = 20,   ///< Доставка
    
    PhotoHousePrintIPhone6      = 21    ///< Чехол IPhone6
} PhotoHousePrint;

@interface StoreItem : NSObject
@property (strong, nonatomic, readonly) NSString *purchaseID;       ///< Идентификатор покупки
@property (strong, nonatomic, readonly) NSString *typeStore;        ///< Тип
@property (strong, nonatomic, readonly) NSString *descriptionStore; ///< Описание покупки
@property (strong, nonatomic, readonly) NSString *namePurchase;     ///< Имя покупки, футболка, кружка и тд
@property (assign, nonatomic, readonly) NSUInteger categoryID;      ///< Идентификатор категории
@property (strong, nonatomic, readonly) NSString *categoryName;     ///< Категория к которой пренадлежит покупка, Сувериры и подврки, Альбомы и тд
@property (assign, nonatomic, readonly, getter = isAvailable) BOOL available;   ///< Отображать ли покупку в магазине
@property (strong, nonatomic, readonly) NSArray *types;             ///< Массив типов PropType для выбора
@property (strong, nonatomic, readonly) PropType *propType;         ///< Выбранный PropType
@property (strong, nonatomic, readonly) DeliveryCity *delivery;     ///< Данные о доставке,

@property (strong, nonatomic, readonly) UIImage *iconStoreImage;    ///< Иконка для магазина, большая
@property (strong, nonatomic, readonly) UIImage *iconShopCart;      ///< Иконка для Корзины, маленькая
@property (strong, nonatomic, readonly) UIImage *gridImage;         ///< Картинка сетки для редактора


/// Получаем цену
/** Получаем цену на основе данных установленных пользователем для текущей покупки
 *@return возвращается цена
 */
- (NSUInteger) price;



/// Иницализируем по ответу от сервера
/** Инициализация, когда читаем данные от сервера, при удачном считывании ответа
 *@param item словарь(Dictionary) содержащий массив типов
 */
- (id) initWithDictionary:(NSDictionary *)item;



/// Инициализируем по данным CoreDataStore
/** Инициализация когда считываем из CoreDataStore, данные в CoreDataStore появляются после учачного считывания ответа от сервера
 *@param purchaseID параметр id для магазина
 *@param typeStore тип, может быть "fixed" или "additional"
 *@param descriptionStore описание, может быть пустым
 *@param namePurchase имя типа отображаемое в названии
 *@param categoryID категория товара
 *@param categoryName название категории к которой отностися товар
 *@param available открыта ли покупка
 *@param types массив PropType
 */
- (id) initStoreWithPurchaseID:(NSString *)purchaseID
                  andTypeStore:(NSString *)typeStore
           andDescriptionStory:(NSString *)descriptionStore
               andNamePurchase:(NSString *)namePurchase
                 andCategoryID:(NSString *)categoryID
               andCategoryName:(NSString *)categoryName
                  andAvailable:(BOOL)available
                      andTypes:(NSArray *)types;


/// Иницализируем по истории заказов
/** Создаем при чтении истории get_all_orders
 *@param order_items словарь order_items
 */
- (id) initWithHistoryOrderItems:(NSDictionary *)order_items;


/// Иницализируем по сведениям о доставке
/** Иницализируем по сведениям о доставке
 *@param delivery данные о доставке
 */
- (id) initDelivetyCity:(DeliveryCity *)delivery;
@end
