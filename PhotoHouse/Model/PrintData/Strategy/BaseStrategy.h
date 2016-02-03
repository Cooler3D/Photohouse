//
//  BaseStrategy.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/20/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintData.h"
#import "PrintImage.h"
#import "StoreItem.h"
#import "PropType.h"

#import "UIImage+Crop.h"


/*!
 \brief Класс стратегия(Strategy) используется для отрисовки и формирования данный.\n
 Является родительским классом у всех объектов в папке ObjectsStrategy
 
 \author Дмитрий Мартынов
 */
@interface BaseStrategy : NSObject
@property (assign, nonatomic) PhotoHousePrint print_id;         ///< Идентификатор покупки
@property (strong, nonatomic) NSString *namePurchase;           ///< Имя покупки
@property (assign, nonatomic) NSUInteger count;                 ///< Количество копий при заказе
@property (strong, nonatomic) NSArray *images;                  ///< Картинки PrintImage
@property (strong, nonatomic) NSDictionary *props;              ///< Свойства Props, цвет, размер, обложка и др
@property (strong, nonatomic, readwrite) NSArray *mergedImages; ///< Скленные картинки PrintImage

@property (strong, nonatomic) StoreItem *storeItem;             ///< Объект идентификатор покупки из магазина StoreViewController


/// Массив картинок
/*! Получем массив картинок, здесь не будет merged
 *@return массив PrintImage
 */
- (NSArray *)imagesPreview;


/// Цена покупки
/** Получаем цену, испотльзуем в этом методе, т.к для Фотопечати требуется учитывать кол-во картинок
 *@return возвращаем цену
 */
- (NSUInteger) price;



///** Возвращаем иконку для заказа или истории
// *@return возвращается иконка 128х
// */
//- (UIImage *) iconImage;


/// Витрина магазина иконка
/*! Получаем картинку для стартовой витрины
 *@return возвращаем картинку
 */
- (UIImage *) showcaseImage;


/// Загруженные адреса
/** Возвращаем NSURL для картинок
 *@return  массив NSURL
 */
- (NSArray *) imagesURLs;


/// Меняем значения у покупки
/** Меняем один из параметров в Props
 *@param object может быть как PropStyle, PropsCover, PropColor, PropSize, PropUturn
 */
- (void) changeProp:(NSObject *)object;



/// Кол-во Копий обновляем из корзины
/*! Меняем кол-во копий
 *@param count кол-во копий
 */
- (void) changeCount:(NSInteger)count;



/// Иницализируем по истории заказа
/** Инициализируем по истории заказа
 *@param order_items поле order_items в ответе от сервера, передается одно значение словаря
 */
- (id) initWithHistoryOrderItemsDictionary:(NSDictionary *)order_items;



/// Инициализируем из магазина
/** Инициализируем по магазину
 *@param storeItem выбранный элемент магазина, передвется с заполненными значениями
 */
- (id) initWithStoreItem:(StoreItem *)storeItem;



/// Склееваем картинки
/*! Склееваем картинки с объектом
 *@param previewImage картинка на основе данной будем наносить на объекты
 *@return массив PrintImage, в нем скленные картинки
 */
-(NSArray *)createAndAddMergedImage:(UIImage *)previewImage;


/// Склееваем с объектом
/*! Склееваем картинки на основе исходной
 *@param previewImage исходная картинка, которая будет наноситься на объекты
 *@param completeBlock блок для выполнения
 */
- (void) createMergedImageWithPreview:(UIImage *)previewImage andCompleteBlock:(void(^)(NSArray *images))completeBlock andProgressBlock:(void(^)(CGFloat progress))progressBlock;
@end
