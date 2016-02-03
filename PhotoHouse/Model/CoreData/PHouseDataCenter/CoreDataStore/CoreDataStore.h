//
//  CoreDataStore.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/29/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHDataManager.h"


@class StoreItem;
@class PropCover;
@class PropSize;
@class PropUturn;
@class PropStyle;
@class PropType;

@class Template;
@class Layout;



@interface CoreDataStore : PHDataManager
/** Сохраняем весь ассортимент магазина StoreItem
 *@param storeItems массив элементов StoreItem
 *@param templates массив с шаблонами для конструктора, приходит без картинок
 */
- (void) saveStoreArray:(NSArray *)storeItems andTemplates:(NSArray *)templates;



/** Получить список размеров PropSize по параметру typeName и PurchaseID
 *@param purchaseID название поля id от сервера, покупки
 *@param typeName тип размера
 *@return возвращаем массив PropSize
 */
- (NSArray *) getSizesWithPurchaseID:(NSString *)purchaseID andTypePropName:(NSString *)typeName;



/** Получить список разворотов PropUturn по параметру typeName и PurchaseID
 *@param purchaseID название поля id от сервера, покупки
 *@param typeName тип размера
 *@return возвращаем массив PropUturn
 */
- (NSArray *) getUturnWithPurchaseID:(NSString *)purchaseID andTypePropName:(NSString *)typeName;



/** Получить список разворотов PropCover по параметру typeName и PurchaseID
 *@param purchaseID название поля id от сервера, покупки
 *@param typeName тип размера
 *@return возвращаем массив PropCover
 */
- (NSArray *) getCoversWithPurchaseID:(NSString *)purchaseID andTypePropName:(NSString *)typeName;



/** Получить список стилей PropStyle по параметру typeName и PurchaseID
 *@param purchaseID название поля id от сервера, покупки
 *@param typeName тип размера
 *@return возвращаем массив PropStyle
 */
- (NSArray *) getStylesWithPurchaseID:(NSString *)purchaseID andTypePropName:(NSString *)typeName;



/** Получить список цветов PropColor по параметру typeName и PurchaseID
 *@param purchaseID название поля id от сервера, покупки
 *@param typeName тип размера
 *@return возвращаем массив PropColor
 */
- (NSArray *) getColorsWithPurchaseID:(NSString *)purchaseID andTypePropName:(NSString *)typeName;



/** Получаем список PropType по id покупки
 *@param purchaseID название поля id от сервера, покупки
 *@return возвращаем массив PropType
 */
- (NSArray *) getTypesWithPurchaseID:(NSString *)purchaseID;



/** Получаем сипок значений по умолчанию
 *@param albumID id для альбома, значение берется из магазина
 *@param propTypeName название типа square, rectangle
 *@return возвращается PropType в нем по одному значению PropSize, PropUturn, PropCover, PropStyle
 */
- (PropType *) getDefaultAlbumParamsWithAlbumID:(NSString *)albumID andTypePropName:(NSString *)propTypeName;



/** Получаем названия категорий для магазина. В ответе будет "Фотопечать", "Сувериры и подарки" и др
 *@return возвращаем массив названий категорий для магазина
 */
- (NSArray *) getStoreCategoryes;



/** Получаем список для конкретной названия категории
 *@param categoryName имя категории
 *@return возвращаем массив StoreItem
 */
- (NSArray *) getStoreItemsWithCategoryName:(NSString *)categoryName;


/** Получаем название категории по categoty_id
 *@param categoty_id цифра категории
 *@return возвращает имя категории, иначе "Категория"
 */
- (NSString *) getCategoryTitleWithCategoryID:(NSInteger)categoryID;



/*! Получем список StoreItem для альбомов. ТОЛЬКО ДЛЯ АЛЬБОМОВ. Чтобы можно было показать иконки стилей альбомов в магазине
 *@param categoryID имя категории альбома, если изменилось
 *@return возвращаем список StoreItem, но в нет зависимоть от стиля(StyleName), а не от PropType.name
 */
- (NSArray *) getAlbumStoreItemsWithCategoryName:(NSString *)categoryName andAlbumPurshaseID:(NSInteger)purchaseID;



/// Очищаем все данные из базы
- (void) clearStory;


/** Есть ли данные в магазине
 *@return yes данные есть, no данных нет
 */
- (BOOL) hasStoreData;


#pragma mark - Album Templates
///*! Получаем массив из стилей, для конкретного размера альбома
// *@param albumSize размер альбома, можно узнать из PrintData.StoreItem
// *@return возвращается массив PropStyle
// */
//- (NSArray *) getStylesWithAlbumPropSize:(PropSize *)propSize;



/*! Получаем массив всех сохраненных Template
 *@param purchaseID название поля id от сервера, покупки
 *@param propTypeName имя типа (PropType.name)
 *@return возвращаем массив Template, если передали неправильный propTypeName(PropType.name), товернется пустой массив
 */
- (NSArray *) getAllTemplatesWithPurchaseID:(NSString *)purchaseID andPropTypeName:(NSString *)propTypeName;



/*! Получаем один Layout обложки
 *@param size выбранный размер альбома
 *@param style выбранный стиль альбома
 *@return возвращаемтся Layout содержащий обложку
 */
//- (Layout *) getCoverAlbumLayoutSize:(PropSize *)size andStyle:(PropStyle *)style;




/*! Получаем массив страниц для выбора, разворотов конструктора
 *@param size выбранный размер альбома
 *@param style выбранный стиль альбома
 *@return возвращаемтся массив Layout
 */
//- (NSArray *) getPagesAlbumLayoutSize:(PropSize *)size andStyle:(PropStyle *)style;




/*! Получаем Шаблон(Template) по размеру(PropSize) и стилю(PropStyle)
 *@param purchaseID название поля id от сервера, покупки
 *@param propTypeName имя типа (PropType.name)
 *@param templateSize размер альбома, получаем из восстановлении синхронизации шаблона(Template.size)
 *@param templateName выбранный стиль альбома, получаем из восстановлении синхронизации шаблона(Template.name)
 *@retutn возвращаем найденный шаблон(Template)
 */
- (Template *) getTemplateWithPurchaseID:(NSString *)purchaseID
                         andPropTypeName:(NSString *)propTypeName
                            TemplateSize:(NSString *)templateSize
                         andTemplateName:(NSString *)templateName;



/** Синхронизируем фотографии поле загрузки верстки, чтобы потом можно было не загружать снова
 *@warning Можно передавать с разворотами, не полностью загруженными версткой, сохранятся только те которые с версткой
 *@param albumTemplate шаблов в с загруженными картинками верстки
 *@param purchaseID название поля id от сервера, покупки
 *@param propTypeName имя типа (PropType.name)
 *@param templateSize размер альбома, получаем из восстановлении синхронизации шаблона(Template.size)
 *@param templateName выбранный стиль альбома, получаем из восстановлении синхронизации шаблона(Template.name)
 */
- (void) synchorizeTemplateAfterDowloadImages:(Template *)albumTemplate
                                andPurchaseID:(NSString *)purchaseID
                              andPropTypeName:(NSString *)propTypeName
                                 TemplateSize:(NSString *)templateSize
                              andTemplateName:(NSString *)templateName;
@end
