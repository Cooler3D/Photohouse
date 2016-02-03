//
//  PropStyle.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/29/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <Foundation/Foundation.h>
//http://s01.photohouse.info/serv/public/products/albums/individual_templates/orange_minimalism/store.png
@interface PropStyle : NSObject
@property (strong, nonatomic, readonly) NSString *styleName;
@property (assign, nonatomic, readonly) NSInteger minCount;
@property (assign, nonatomic, readonly) NSInteger maxCount;
@property (strong, nonatomic, readonly) UIImage *imagePreview;
@property (assign, nonatomic, readonly) NSRange rangeImages;


/** Инициализируем при чтении от сервера
 *@param styleDictionary ответ от сервера
 */
- (id) initWithStyleDictionary:(NSDictionary *)styleDictionary;



/** Инициализируем при чтении от CoreDataImageCount
 *@param name имя стиля, пример children
 *@param maxCount максимальное кол-во фоток
 *@param minCount минимальное кол-во фоток для выделения
 *@param image картинка препросмотра стиля, может быть nil, тогда будем искать в xcassetsImages
 */
- (id) initWithStyleName:(NSString *)name andMaxCount:(NSInteger)maxCount andMinCount:(NSInteger)minCount andImage:(UIImage *)image;
@end
