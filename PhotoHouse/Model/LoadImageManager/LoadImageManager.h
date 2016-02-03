//
//  ImageManager.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/13/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

/**
 Внимание, данный клас отвечает просто за загрузку изображения.
 Для того, чтобы проверить наличие изображения в CoreData используйте CoreDataSocialImage.h
 */

#import <Foundation/Foundation.h>



/*!
 @brief Загружаем изображение с адреса.\n
 Внимание, данный клас отвечает просто за загрузку изображения.\n
 Для того, чтобы проверить наличие изображения в CoreData используйте CoreDataSocialImage.\n
 
 В случае успешной загрузки сохраняет изображение в CoreDataSocialImage.

 @author Дмитрий Мартынов
 */
@interface LoadImageManager : NSObject

/// Загружаем картинку по адресу
/*! Загружаем картинку  по адресу и сохраняем в случае успеха в CoreDataSocialImage
 *@param url адрес загрузки
 *@param completeBlock блок успешного окончания
 *@param progressBlock блок прогресса загрузки картинки
 *@param errorBlock блок ошибки
 */
- (void) loadImageWithURL:(NSURL *)url
       usingCompleteBlock:(void(^)(UIImage *image))completeBlock
            progressBlock:(void(^)(CGFloat progress))progressBlock
               errorBlock:(void(^)(NSError *error))errorBlock;
@end
