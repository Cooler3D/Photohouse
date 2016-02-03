//
//  SelectAlbumImage.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/15/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectAlbumImageDelegate;

@interface SelectAlbumImage : UIView

/*! Иницализируем событие выбора фотографии, здесь пользователь решает, что делать с фотографией
 *@param frame рамка всего View
 *@param selectRect рамка, где будет располагаться картинка выранная пользователем
 *@param mainSize размеры главного окна контроллера, для определения кнопок "удалить" и "редактировать"
 *@param screenImage скриншот экрана
 *@param selectImage картинка пользователя
 *@param target ссылка на контроллер
 *@param selector метод
 *@param delegate делегат
 */
- (id) initWithFrame:(CGRect)frame
   andSelecViewFrame:(CGRect)selectRect
         andMainSize:(CGSize)mainSize
      andScreenImage:(UIImage *)screenImage
      andSelectImage:(UIImage *)selectImage
           andTarget:(id)target
         andSelector:(SEL)selector
         andDelegate:(id<SelectAlbumImageDelegate>)delegate;
@end



@protocol SelectAlbumImageDelegate <NSObject>
@required
- (void) selectAlbumUmage:(SelectAlbumImage *)selectAlbumImage didEditImage:(UIImage *)image;
- (void) selectAlbumUmage:(SelectAlbumImage *)selectAlbumImage didRemoveImage:(UIImage *)image;
@end