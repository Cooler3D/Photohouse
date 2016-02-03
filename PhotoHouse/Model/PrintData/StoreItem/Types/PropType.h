//
//  PropType.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/27/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PropSize;
@class PropCover;
@class PropColor;
@class PropUturn;
@class PropStyle;
@class Template;

extern NSString *const TypeNameDesign;
extern NSString *const TypeNameConstructor;

extern NSString *const MUG_TYPE_COLOR;
extern NSString *const MUG_TYPE_HEART;
extern NSString *const MUG_TYPE_LATTE;
extern NSString *const MUG_TYPE_GLASS;
extern NSString *const MUG_TYPE_CHAMELEON;

/*!
 @brief Объект типа покупки. Определяем найстроки покупки.
 Все цвета, размеры, стили и др хранятся в этом объекте.
 Использует ТИПЫ:\n
 PropSize - размер\n
 PropStyle - стиль\n
 PropColor - цвет\n
 PropUturn - развороты\n
 PropCover - обложку\n
 */
@interface PropType : NSObject
@property (strong, nonatomic, readonly) NSString *name;         ///< Имя типа (default, design, constructor и др)
@property (assign, nonatomic, readonly) NSInteger price;        ///< Цена в зависимости от типа и параметров

@property (strong, nonatomic, readonly) NSArray *sizes;         ///< Массив размеров
@property (strong, nonatomic, readonly) NSArray *uturns;        ///< Массив разворотов
@property (strong, nonatomic, readonly) NSArray *covers;        ///< Массив обложек
@property (strong, nonatomic, readonly) NSArray *colors;        ///< Массив цветов
@property (strong, nonatomic, readonly) NSArray *styles;        ///< Массив стилей
@property (strong, nonatomic, readonly) NSArray *templates;     ///< Для тестов, в пямыти не держим все шаблоны !!! @warning только для UnitTest(UnitTestOnly)


@property (strong, nonatomic) PropSize *selectPropSize;             ///< Выбранный размер(альбом, футболка)
@property (strong, nonatomic) PropCover *selectPropCover;           ///< Выбранный обложка(альбом)
@property (strong, nonatomic) PropColor *selectPropColor;           ///< Выбранный цвет(кружка)
@property (strong, nonatomic) PropUturn *selectPropUturn;           ///< Выбранный развороты(альбом)
@property (strong, nonatomic) PropStyle *selectPropStyle;           ///< Выбранный стиль(альбом)
@property (strong, nonatomic, readonly) Template *selectTemplate;   ///< Выбранный шаблон
@property (strong, nonatomic, readonly) Template *userTemplate;     ///< Пользовательский альбом, который хранится в корзине, ждесь НЕ все развороты, и установленны картинки пользователя


/// Инициализируем по ответу от сервера
/** Инициализируем после прихода от сервера
 *@param dictionaryType словарь со значениями, требуется передавать такое {"name":"heart","price":590,"size":{"10":"0"}}
 */
- (id) initWithDictionary:(NSDictionary *)dictionaryType;


/// Иницализируем из CoreDataStore, CoreDataShopCart
/** Инициализируем при считывании из CoreData
 *@param name имя типа, по нему будет опредеяться название
 *@param price цена
 *@param sizes массив с размерами PropSize
 *@param uturns массив с разворотами если есть PropUturn
 *@param covers массив с типами обложек PropCover
 *@param colors массив с цветом типа PropColor
 *@param styles массив с стилями PropStyle
 */
- (id) initTypeName:(NSString *)name
           andPrice:(NSInteger)price
           andSizes:(NSArray *)sizes
          andUturns:(NSArray *)uturns
          andCovers:(NSArray *)covers
          andColors:(NSArray *)colors
          andStyles:(NSArray *)styles
       andTemplates:(NSArray *)templates;


/// Иницализируем по истории
/** Инициализируем по истории заказов
 *@param name имя типа, по нему будет опредеяться название
 *@param price цена
 *@param sizeName строка с размером
 *@param uturnName строка с выбранными разворотами
 *@param coverName строка с выбранной обложкой в заказе
 *@param styleName название стиля
 *@param userTemplate альбом пользователя
 */
- (id) initTypeName:(NSString *)name
           andPrice:(NSInteger)price
        andSizeName:(NSString *)sizeName
       andUturnName:(NSString *)uturnName
       andCoverName:(NSString *)coverName
       andColorName:(NSString *)colorName
       andStyleName:(NSString *)styleName
    andUserTemplate:(Template *)userTemplate;


/// Иницализируем из корзины CoreDataShopCart
/** Инициализируем по корзине (CoreDataShopCart), показываем все размеры и выбранны размер. Передаем оба варианта для сравнения
 *@param name имя типа, по нему будет опредеяться название
 *@param price цена
 *@param sizeName строка с размером
 *@param uturnName строка с выбранными разворотами
 *@param coverName строка с выбранной обложкой в заказе
 *@param styleName название стиля
 *@param userTemplate альбом пользователя
 *@param sizes массив с размерами PropSize
 *@param uturns массив с разворотами если есть PropUturn
 *@param covers массив с типами обложек PropCover
 *@param colors массив с цветом типа PropColor
 *@param styles массив с стилями PropStyle
 */
- (id) initTypeName:(NSString *)name
           andPrice:(NSInteger)price
        andSizeName:(NSString *)sizeName
       andUturnName:(NSString *)uturnName
       andCoverName:(NSString *)coverName
       andColorName:(NSString *)colorName
       andStyleName:(NSString *)styleName
    andUserTemplate:(Template *)userTemplate
           andSizes:(NSArray *)sizes
          andUturns:(NSArray *)uturns
          andCovers:(NSArray *)covers
          andColors:(NSArray *)colors
          andStyles:(NSArray *)styles;



/// Обновляем значение пользовательского шаблона
/** Обновляем пользовательский шаблон с фотографиями пользователя
 *@param userTemplate пользовательский шаблон и фотографиями поьзователя
 *@warning Для синхронизации с CoreDataShopCart используйте метод updateTemplateOrPropsPrintData
 *@code
 CoreDataShopCart *coreShop = [CoreDataShopCart alloc] init];
 [coreShop updateTemplateOrPropsPrintData:];
 *@endcode
 */
- (void) updateUserTemplate:(Template *)userTemplate;
@end
