//
//  EditPhotoViewController.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/11/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class PhotoRecord;
@class PrintData;
@class PrintImage;

extern NSString *const EditorDidSaveNotification;
extern NSString *const EditorDidSaveUserInfoKey;

@interface EditPhotoViewController : UIViewController
//@property (strong, nonatomic) PhotoRecord *photoRecord;


/*! Иницализируем редактор из обычной витрины
 *@param printData данные о покупке
 *@param printImage редактируемая картинка
 */
- (void) printData:(PrintData *)printData andEditenImage:(PrintImage *)printImage;



/*! Иницализируем из конструктора альбомов, тут сетку придется отрисовать самим
 *@param printData
 *@param printImage редактируемая картинка
 *@param aspect_ratio соотношение сторон(ширины к высоте). 1 < aspect_ratio < 1
 */
- (void) printData:(PrintData *)printData andEditenImage:(PrintImage *)printImage andGridAspectRatio:(CGFloat)aspect_ratio;
@end
