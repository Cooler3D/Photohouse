//
//  PrintImage.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/20/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


#import "EditImageSetting.h"

/// Тип библиотек откуда взята картинка
typedef enum {
    ImageLibraryPhone,  ///< Память телефона PhotoLibrary
    ImageLibrarySocial  ///< Соц.сети
} ImageLibrary;

/*!
 @brief Объект-картинка, содержит в себе данные о редактровании EditImageSetting, маленькую иконку(50х50) для отображения в ToolBar.\n
 Свойство класса PrintData
 
 @author Дмитрий Мартынов
 */
@interface PrintImage : NSObject
@property (assign, nonatomic, readonly) CGSize originalImageSize;   ///< Оригинальные размеры картинки, т.к в previewImage маленькая картинка может содержаться
@property (strong, nonatomic, readonly) NSData *imageLargeData;     ///< Данные картинки, можно отправлять
@property (strong, nonatomic, readonly) UIImage *previewImage;      ///< Картинка 640 по большей стороне, с ней будем изменять
@property (strong, nonatomic, readonly) UIImage *photoPrintImage __attribute__((deprecated("Remove property")));   ///< Данная картинка только для "Фотопечати" и "Альбомов", Содержит копию PreviewImage без всего
@property (strong, nonatomic, readonly) UIImage *iconPreviewImage;  ///< Иконка для ToolBar
@property (strong, nonatomic, readonly) NSString *urlLibrary;       ///< Адрес картинки в библиотеке, по этому параметру идет поиск
@property (strong, nonatomic, readonly) EditImageSetting *editedImageSetting;   ///< Настройки редактрованной фотографии
@property (strong, nonatomic, readonly) NSURL *uploadURL;           ///< Адрес картинки на сервере PhotoHouse после отправки пользователем данной картинки
@property (assign, nonatomic) NSUInteger unique_imageID __attribute__((deprecated("Remove property")));            ///< Уникальный идентификатор картинки
@property (assign, nonatomic) NSUInteger index;                     ///< Очередность картинки для дизайнерского альбома, @warning СЕЙЧАС НЕ ИСПОЛЬЗУЕТСЯ
@property (strong, nonatomic, readonly) ALAsset *assetImage __attribute__((deprecated("Remove property")));        ///< Картинка из библиотеки телефона
@property (assign, nonatomic, readonly) BOOL isMergedImage;         ///< Является ли данная картинка скленной, применяется при кружках, футболках, чехлах и др
@property (assign, nonatomic) ImageLibrary imageLibrary;            ///< Тип картинки, память телефона(PhotoLibrary) или соц.сети

/// Обновляем priviewImage кртинку
/*! Обновляем previewImage картинку, после редактора
 *@param image картинка, заменит priviewImage
 */
- (void) updatePreviewImage:(UIImage *)image;

/// Обновляем данные по библиотеке картинки
/*! Обновляем данные по библиотеке картинки, используется при применении фильтра к оригинальной картинке и сохранении
 *@param urlLibrary адрес библиотеки
 *@param unique Уникальный идентификатор PrinData.Unique
 */
- (void) updateUrlLibrary:(NSString *)urlLibrary andImageLibrary:(ImageLibrary)imageLibrary withPrintDataUnique:(NSUInteger)unique;


/// Обновляем данные по загрузке картинки
/*! Обновляем данные по загрузке картинки, дынные обновления CoreData внутри метода
 *@param uploadUrl адрес нахождения в сети
 *@param unique уникальный идентификатор PrinData.Unique
 */
- (void) updateUploadUrl:(NSString *)uploadUrl withPrintDataUnique:(NSUInteger)unique;


/// Очищаем данные картинки
/*! Очищаем данные картнки
 */
- (void) clearImageLargeData;


/// Оригинальная картинка -> Уменьшенная для обработки
/*! Добавляем оригинальную картинку и делаем из нее PreviewImage и IconImage, вызывается после успешного сохранения в CoreDataShopCart
 *@param originalImage картинка оригинальная
 *@param asset из библиотеки телефона
 */
//- (void) addOriginalSocilaImage:(UIImage *)originalSocialImage orOriginalAsset:(ALAsset *)asset;



/// Редактировали ли ?
/*! Редактировалась ли фотография
 *@return YES все редактировалось, NO не редактировалось
 */
- (BOOL) isDidEdited;


/// Иницализируем из PhotoLibrary(памяти телефона)
/** Инициализируем после загрузки картинкок в магазине от изображений с телефона
 *@param record значение с картинкой после загрузки
 *@param imageUrlName адрес изображения
 */
- (id) initWithALAsset:(ALAsset *)asset withName:(NSString *)imageUrlName __attribute__((deprecated("use 'initWithPreviewImage:'")));


/// Иницализируем из соц.сети
/** Инициализируем по фотографии загруженной из соц.сети или CoreData
 *@warning Внимание!!! Если одна из сторон картинки PreviewImage больше 640, то свойство обновится, иначе [PrintImage].previewImage == nil
 *@param image картинка либо при инициализации из SelectImages, или CoreData
 *@param imageUrlName адрес, для отпределения формата и адреса в библиотке
 *@param editSetting настройки редактора
 *@param originalSize размер оригинальной картинки, можно передать Zero и тогда возьмет размеры картинки PreviewImage
 */
- (id) initWithPreviewImage:(UIImage *)image withName:(NSString *)imageUrlName andEditSetting:(EditImageSetting *)editSetting originalSize:(CGSize)originalSize andUploadUrl:(NSString *)uploadUrl;



/// Иницализируем больщую картинку
/*! Иницализируем большую картинку из CoreData перед отправкой на сервер, т.е данные для картинки представляют оригинал, а не уменьшенную копию
 *@param imageData данные картинки из CoreData
 *@param imageUrlName адрес картинки
 *@param editSetting настройки редактора
 */
- (id) initLargeImageData:(NSData *)imageData andPreviewImage:(UIImage *)previewImage withName:(NSString *)imageUrlName andEditSetting:(EditImageSetting *)editSetting __attribute__((deprecated("Remove'")));


/// Инициализируем скленную картинку
/** Инициализируем скленную фотографию, когда формируем заказ из ShowCaseViewController
 *@param image картинка скленная
 *@param imageUrlName адрес, для отпределения формата
 */
- (id) initMergeImage:(UIImage *)image withName:(NSString *)imageUrlName andUploadUrl:(NSString *)uploadUrl;


/// Иницализируем по истории заказов
/** Иницализируем по истории заказов, когда заходим в историю заказов
 *@param imageDictionary от истории заказов
 */
- (id) initWithHistoryOrderDictionary:(NSDictionary *)imageDictionary;



/// Обрезаем фото для "Фотопечати"
/*! Метод обрезает картинку и обновляет значения EditImageSetting
 *@param gridImage картинка сетки
 */
- (void) cropPhotPrintWithGrigImage:(UIImage *)gridImage;



/// Обрезаем фото для конструктора альбомов
/*! Метод обрезает картинку и обновляет значения EditImageSetting
 *@param cropSize размеры прямоугольника для обрезки
 *@warning значение cropSize для текущей рамки фотографии, метод сам посчитает правильные пропорции
 */
- (UIImage *) cropImageWithCropSize:(CGSize)cropSize;
- (void) cropImageWithCropSize:(CGSize)cropSize withCompleteBlock:(void(^)(UIImage *image))completeBlock;



/// Обрезаем картинку для объекта
/*! Данные метод только обновляет значения EditImageSetting
 *@param gridImage картинка сетка
 */
- (void) cropImageForObjects:(UIImage *)gridImage;



/// Обрезаем для дизайнерсокго альбома
/*! Данные метод только обновляет значения EditImageSetting
 */
- (void) cropImageForDesingAlbum;


/// Обновляем значение OriginalImageSize
- (void) updateOriginalSize:(CGSize)originalSize;


/// Считаем оригинальные разсеры картинки после редактирования
/*! Считаем оригинальные разсеры картинки после редактирования
 *@see -updateOriginalSize: - после того как посчитали, нужно обновить
 *@param orinetation поворот картинки
 *@return возвращается размер картинки
 */
- (CGSize) calculateOriginalSizeWithOrientation:(UIImageOrientation)showedImageOrientationse;


/// Изменяем размер оригинальной фотографии
/*! Изменяем размер оригинальной фотографии, чтобы приложение не упало после применения фильтров и отправки на сервер
 *@param side масксимальную сторону изображения приравнять к этому значению и изменить пропорционально
 */
- (void) resizeImageToMaxSide:(NSInteger)side;
@end
