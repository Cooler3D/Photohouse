//
//  LayerImage.h
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/9/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Image;

/*!
 \brief Слой с верской и пользовательскими картинками
 
 \warning старый, нужно изменить на v2 получать сохранять и отправлять
 \author Дмитрий Мартынов
 */
@interface Layer : NSObject
@property (strong, nonatomic, readonly) NSArray *images;    ///< Пользовательские картинки Image
@property (strong, nonatomic, readonly) Image *image;       ///< Картинка с верской разворота


/*! Иницализиуем по данным из сервера
 *@param dictionary данные из сервера
 */
- (id) initLayerDictionary:(NSDictionary *)dictionary;


/*! иницализируем из CoreData
 *@param image картинка разворота
 *@param images пользователя внутри разворота
 */
- (id) initWithImage:(Image *)image andImages:(NSArray *)images;



/** Получаем словарь для Layer
 *@return словарь для layer
 */
- (NSDictionary *) layerDictionary;
@end
