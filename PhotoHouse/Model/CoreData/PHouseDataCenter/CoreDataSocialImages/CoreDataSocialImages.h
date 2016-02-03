//
//  CoreDataInstagram.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/13/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHDataManager.h"

#import "PhotoRecord.h"



@interface CoreDataSocialImages : PHDataManager
/// Сохраняем картинку
/*! Сохраняем картинку по загруженной картинке, так же по адресу загрузки и типу библиотеки
 *@param image картинка
 *@param url адрес по которому загружено
 *@param libraryType билиотека для которой данная картинка
 *@see method '-savePhotoRecord:'
 */
- (void) saveImage:(UIImage *)image
           withURL:(NSString *)url
    andLibraryType:(ImportLibrary)libraryType __attribute__((deprecated("Use '-savePhotoRecord'")));


/// Сохраняем картинку
/** Сохраняем PhotoRecord, когда загрузили из соц.сетей или истории
 *@param record объект картинка и сети
 */
- (void) savePhotoRecord:(PhotoRecord *)record;



/// Проверяем, есть данные по картинке
/*! Возвращаем картинку по адресу картинки, если есть, иначе nil. Проверяем перед загрузкой очередной картинки из соц.сети или истории загрузок.
 *@warning При условии что в настройках приложения переключатель Кэша включен.
 *@param адрес по которому была загрузка
 *@return либо возвращается UIImage или nil
 */
- (UIImage *) getImageWithURL:(NSString *)url;


/// Возвращаем данные по адресу
/*! Возвращаем данные картинки, если есть, иначе nil
 *@param адрес по которому была загрузка
 *@return либо возвращается UIImage или nil
 */
- (NSData *) getImageDataWithURL:(NSString *)url;


/// Массив картинок по типу библиотеки
/*! Возвращаем все картинки по типу библиотеки
 *@param libraryType выбираем из библиотеки
 *@return возвращается массив PhotoRecord
 */
- (NSArray *) getAllImgesWithLibraryType:(ImportLibrary)libraryType;


/// Массив PhotoRecord по именая картинок
/** Возвращаем массив PhotoRecord по именам картинок
 *@param urlNames массив адресов картинок из соц.сетей
 *@return массив PhotoRecord по имена(адресам)
 */
- (NSArray *) getRecordWithNames:(NSArray *)urlNames;



/// Убираем все сохраненные картинки, переключатель в "Настройки"
- (void) removeAllImages;
@end
