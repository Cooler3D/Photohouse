//
//  BundleDefault.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/25/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BundleDefaultTypeDelivery,
    BundleDefaultTypeRangeImages,
    BundleDefaultTypePrice,
    BundleDefaultTypeAllItems,
    /// Содержит ссылки для внутреннего тестирования
//    BundleDefaultTypeAlbum,
    /// Для тестирования, содержит ссылки на внешние ресурсы
//    BundleDefaultTypeAlbumTests,
    BundleDefaultTypeBanners,
    BundleDefaultTypeResponceUploadImageTest,
    BundleDefaultTypeResponceAuthTest,
    BundleDefaultTypeRegistrationTest,
    
    /// Данные от сервера для тестов шаблонов альбома, новая версия
    BundleDefaultTypeAlbumTestVer2,
    
    /// Время обновлений команд с сервера
    BundleDefaultTypeUpdateTimeTest
} BundleDefaultType;




@interface BundleDefault : NSObject
/// Ответ от сервера по умолчанию
/*! Получаем ответ от сервера по умолчанию, если нужные нам данные не пришли
 *@param bundleType тип ответа для получения
 *@return возрашаются данные, в формате JSON
 */
- (NSData *) defaultDataWithBundleName:(BundleDefaultType)bundleType;
@end
