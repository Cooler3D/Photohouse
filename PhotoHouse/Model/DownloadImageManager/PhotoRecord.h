//
//  PhotoRecord.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/1/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


/**
 Этот список один в один SelectedPhotoViewController.h
 */
typedef enum {
    ImportLibraryPhone      = 0,
    ImportLibraryInstagram  = 1,
    ImportLibraryVKontkte   = 2
} ImportLibrary;


@interface PhotoRecord : NSObject
@property (nonatomic, strong, readonly) NSString *name;                       // To store the name of image
@property (nonatomic, strong) UIImage *image;                       // Оригинальная картинка
@property (nonatomic, strong, readonly) NSURL *URL;                           // Для покупки, URL адрес загруженной картинки
@property (nonatomic, assign, getter = isSelected) BOOL selected;   // Select image Now
@property (nonatomic, assign, getter = isEdited) BOOL edited;       // Редактировалось ли? YES or NO
@property (nonatomic, assign, readonly) BOOL hasImage;              // Return YES if image is downloaded.
@property (nonatomic, getter = isFailed) BOOL failed;               // Return Yes if image failed to be downloaded/uploaded
@property (nonatomic, strong, readonly) NSDate *dateSave;           ///< Дата создание картинки
@property (nonatomic, assign, readonly) CGSize imageSize;           ///< Оригинальный размер картинки

@property (nonatomic, strong, readonly) ALAsset *asset __attribute__((deprecated("Remove property")));                       // Для загрузки фотографий с телефона

@property (nonatomic, assign, readonly) ImportLibrary importFromLibrary;      // Откуда импортировали Фотку (Телефон, Instagram, VK)



/** Инициализируем по соц.сетям
 *@param socialUrl адрес загрузки картинки
 *@param importLibrary тип библиотеки
 */
- (id) initWithSocialURl:(NSString *)socialUrl withImage:(UIImage *)image andImportLibrary:(ImportLibrary)importLibrary;
//- (id) initWithSocialURl:(NSString *)socialUrl andImaportLibrary:(ImportLibrary)importLibrary __attribute__((deprecated("use 'initAssetThumbal:'")));



/** Иницализация по Данным из устройства
 *@param asset данные фотографии
 */
- (id) initWithAsset:(ALAsset *)asset __attribute__((deprecated("use 'initAssetThumbal:'")));


/// Инициализируем по данным из PhotoLibrary
/*! Инициализируем по данным из PhotoLibrary
 *@param preview данные предпросмотра ALAsset(НЕ обязательный параметр)
 *@param urlLib адрес положения в сети (Обязательный параметр)
 *@param date дата создания (НЕ обязательный параметр)
 */
- (id)initAssetThumbal:(CGImageRef)preview andNameUrlLibary:(NSString *)urlLib andDate:(NSDate *)date andImageSize:(CGSize)imageSize;
@end
