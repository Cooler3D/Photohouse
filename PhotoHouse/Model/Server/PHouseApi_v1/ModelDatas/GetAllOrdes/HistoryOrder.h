




/*
 *
 *
 *
 Здесь хнанится текущий заказ.
 @prints - Массив с PrintData
 @personalInfo - Иснофрмация о заказывающем и номер заказа
 *
 *
 *
 */

#import <Foundation/Foundation.h>

@class PersonOrderInfo;


@interface HistoryOrder : NSObject
@property (strong, nonatomic, readonly) PersonOrderInfo *personInfo;    ///< Информация о заказчике
@property (strong, nonatomic, readonly) NSMutableArray *prints;         ///< Массив заказов, PrintData


/// Общая цена за заказ @return возвращаем общую цену за заказ
- (NSUInteger) priceOrder;



/// Картинка статуса @return возввращаем картинку статуса
- (UIImage *) statusOrderImage;



/// Картинка иконка для заказа @return возвращаем картинку иконку
- (UIImage *) iconOrderImage;


/// Инициализируем историю заказа
/** Инициализируем историю заказа по информации пользователя и массиву заказов
 *@param orderInfo поле order_info в ответе от сервера
 *@param orderItems поле order_items в ответе от сервера
 */
- (id) initWithOrderInfo:(NSDictionary *)orderInfo andOrderItems:(NSArray *)orderItems;
@end
