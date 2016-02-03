//
//  Layer.h
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/9/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString *const ImageRemoveOnPageNotification;
extern NSString *const ImagesOpenNotification;
//extern NSString *const ImagesRemoveNotification;
//extern NSString *const ImagesEditNotification;
extern NSString *const ImageSelectNotification;

extern NSString *const ImagesSelectKey;
extern NSString *const ImagePrintKey;
extern NSString *const ImageRectKey;
//extern NSString *const ImageUrlLibraryKey;


@protocol ImageDelegate;

/*!
 \brief Картинка для отображения одного объекта с фотографией на экране
 \warning старый, нужно изменить на v2 получать сохранять и отправлять
 \author Дмитрий Мартынов
 */
@interface Image : NSObject
@property (strong, nonatomic, readonly) NSString *pixelsMin;
@property (strong, nonatomic, readonly) NSString *pixelsLimit;
@property (strong, nonatomic, readonly) NSString *z;
@property (strong, nonatomic, readonly) NSString *url_image;
@property (strong, nonatomic, readonly) NSString *permanent;
@property (assign, nonatomic, readonly) UIImageOrientation orientation;
@property (assign, nonatomic, readonly) UIImageOrientation orientationDefault;
@property (assign, nonatomic, readonly) CGRect rect;
@property (assign, nonatomic, readonly) CGRect crop;

@property (strong, nonatomic, readonly) UIImage *image;
@property (assign, nonatomic, readonly) BOOL hasImage;
@property (strong, nonatomic, readonly) NSString *url_upload;
@property (weak, nonatomic) id<ImageDelegate> delegate;


/*! Иницализиуем по данным из сервера
 *@param dictionary данные из сервера
 */
- (id) initImageDictionary:(NSDictionary *)dictionary;


/*! Иницализируем из CoreData
 *@param pixelsMin минимальное кол-во пикслов
 *@param pixelsLimit не использую
 *@param z не использую
 *@param urlImage адрес картинки для background или пользовательская картинка в CoreDataShopCart
 *@param permanent не использую
 *@param rect позиция картинки
 *@param crop размеры картинки (не использую)
 *@param image картинка
 */
- (id) initWithPixelsMin:(NSString *)pixelsMin
          andPixelsLimit:(NSString *)pixelsLimit
                    andZ:(NSString *)z
             andUrlImage:(NSString *)urlImage
            andUrlUpload:(NSString *)urlUpload
            andPermanent:(NSString *)permanent
                 andRect:(CGRect)rect
                 andCrop:(CGRect)crop
                andImage:(UIImage *)image
     andImageOrientation:(UIImageOrientation)orientation andImageOrientationDefault:(UIImageOrientation)orientationDefault;



/*! Start DownLoad */
- (void) startDownloadImage:(id<ImageDelegate>)delegate;


/*! Обновляем данные о картинке, для сохранения синхронизации
 *@param urlLibrary ссылка на картинку в CoreDataShopCart(PrintImage)
 */
- (void) updateUrlImage:(NSString *)urlLibrary;


/*! Обновляем значение ориентации картинки
 *@param imageOrientation ориентация картинки
 */
- (void) updateOrientation:(UIImageOrientation)imageOrientation;


/// Обновляем ориентацию картинки по умолчанию
- (void) updateDefaulOrientation:(UIImageOrientation)orientationDefault;


/*! Обновляем Crop
 *@param crop структура CGrect
 */
- (void) updateCrop:(CGRect)crop;


/** Получаем словарь для Image
 *@return словарь для данного объекта
 */
- (NSDictionary *) imageDictionary;



/** Обновляем картинку
 *@param image картинка
 *@warning Используется ТОЛЬКО для UnitTest
 */
- (void) updateImage:(UIImage *)image;
@end


@protocol ImageDelegate <NSObject>
@required
- (void) image:(Image *)imageObj didDownLoadComplate:(UIImage *)image;
- (void) image:(Image *)imageObj didFailWithError:(NSError *)error;
@end