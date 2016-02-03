//
//  MDPhotoLibrary.h
//  CollectionView
//
//  Created by Мартынов Дмитрий on 01/11/15.
//  Copyright © 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

/// Key Error
extern NSString * const PHOTO_LIBRARY_ERROR_KEY;

/// Название папки для Фотобиблиотеки
extern NSString * const PHOTO_LIBRARY_GROUP_ALBUM_NAME;


@class ALAssetRepresentation;
@class ALAsset;


@interface MDPhotoLibrary : NSObject
/// Авторизован ли пользователь @return YES - авторизован, No - не авторизован
+ (BOOL)isAuthorized;


/// Загрузка галереи
/*! Загрузка галлереи частями, при большом кол-ве фоток, возникает долгая пауза
 *@param callbackBlock блок выполнения
 */
- (void)loadPhotosAsynchronously:(void (^)(NSArray *assets, NSError *error))callbackBlock;



/// Загрзужаем картинку по параметрам
/*! Загружаем картинку по определенным параметрам
 *@warning ТОЛЬКО ДЛЯ UNIT TEST
 *@param size минимальный размер картинки
 *@param assetOrientation ориентация картинки которую хотим получить
 *@param successBlock блок выполнения
 */
- (void) loadPhotoWithSize:(CGSize)size andOrientation:(UIImageOrientation)assetOrientation withSuccessBlock:(void(^)(NSData *imageData, NSError *error))successBlock;


/// Получаем определенное кол-во картинок NSData
/*! Получаем определенное кол-во картинок по ориентации, размерам
 *@warning Только для UnitTest
 *@param photosCount кол-во картинок которое хотим
 *@param size размер картинок
 *@param assetOrientation ориентация картинок, если передается значение -1, то ориентация любая
 *@param successBlock блок выполнения (Массиа NSData, NSError)
 */
- (void) loadPhotoDatasCount:(NSUInteger)photosCount withSize:(CGSize)size andOrientation:(NSInteger)assetOrientation withSuccessBlock:(void(^)(NSArray *imageDatas, NSError *error))successBlock;


/// Получаем определенное кол-во картинок ALAsset
/*! Получаем определенное кол-во картинок по ориентации, размерам
 *@warning ТОЛЬКО ДЛЯ UNIT TEST
 *@param photosCount кол-во картинок которое хотим
 *@param size размер картинок
 *@param assetOrientation ориентация картинок, если передается значение -1, то ориентация любая
 *@param successBlock блок выполнения (Массиа ALAsset, NSError)
 */
- (void) loadPhotoALAssetsCount:(NSUInteger)photosCount withSize:(CGSize)size andOrientation:(NSInteger)assetOrientation withSuccessBlock:(void(^)(NSArray *assets, NSError *error))successBlock;


/// Получаем все картинки
/*! Получаем все картинки, для сравнения, при большом кол-ве фотографий, данный метод будет выполняться очень долго
 *@warning ТОЛЬКО ДЛЯ UNIT TEST
 *@param completeBlock блок выполнения (Массиа ALAsset, NSError)
 *@param errorBlock кол-во картинок которое хотим
 */
- (void)loadAllAssets:(void(^)(NSInteger assetCount))completeBlock andErrorBlock:(void(^)(NSError *error))errorBlock;




/// Получаем картику по адресу
/*! Получаем картинку по адресу в библиотеке
 *@param url адрес в библиотеке телефона
 *@param complateBlock успешное нахождение картинки
 *@param failBlock поиск картинки закончился ошибкой
 */
- (void) getAssetWithURL:(NSString *)url withResultBlock:(void(^)(NSData *imageData, UIImageOrientation orientation))completeBlock failBlock:(void(^)(NSError *error))failBlock;


/// Сохраняем картинку
/*! Сохраняем картинку в библиотеке устройства, картинка сохраняется в определенной папке
 *@param image картинка для сохранения
 *@param successBlock блок успешного сохранения
 *@param failBlock блок ошибки
 */
- (void) saveImageToPhotoLibrary:(UIImage *)image andImageOrientation:(UIImageOrientation)orientation withSuccessBlock:(void(^)(NSString *assetURL))successBlock failBlock:(void(^)(NSError *error))failBlock;

/// Получаем оригинальный размерм картинки
/*! Получаем оригинальный размерм картинки по metaData
 *@param metaData данные с картинки
 *@return возвращаем размер картинки
 */
- (CGSize) imageSizeWithMetaData:(NSDictionary *)metaData;

@end
