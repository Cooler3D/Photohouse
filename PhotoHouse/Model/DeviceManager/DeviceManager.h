//
//  DeviceManager.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/28/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const IPHONE4;
extern NSString *const IPHONE5;
extern NSString *const IPHONE6;
extern NSString *const IPHONE6P;

extern NSString *const IPAD;
extern NSString *const IPAD_RETINA;


/*!
 \brief Определения имя устройсва для отправки на PhotoHouse в определенном формате.
 
 \author Дмитрий Мартынов
 */
@interface DeviceManager : NSObject
/// Возвращаем модель устройсва
/** Возвращаем название модели устройства. Формата ip4 - iPhone4, ip6p - IPhone6 Plus
 *@return  возвращаем модель устройства
 */
- (NSString *) getDeviceName;


/// Это iPhone4/4s ?
/** Является ли данное устройство iPhone4/4s
 *@return yes вляется, no не является
 */
- (BOOL) isIPhone4Device;


/// Возвращается цифра модели устройства
/** Возвращает модель устройства. Либо 4(iPhone4/s), 5(iPhone5/s), 6(iPhone6/+)
 *@return возвращает модель устройства
 */
- (NSString *) getDeviceModelName;
@end
