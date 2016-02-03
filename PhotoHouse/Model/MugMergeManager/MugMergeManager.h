//
//  MugMergeManager.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 06/04/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MugMergeManagerDelegate;

@interface MugMergeManager : NSObject
@property (weak, nonatomic) id<MugMergeManagerDelegate> delegate;

/// Начинаем склеевать Кружку и картинку пользователя
- (void) startMerge;

/// Одна сторона кружки, ручка справа
- (void) addImageFirst:(UIImage *)image;

/// Второе изображение кружки, ручка слева
- (void) addSecondImage:(UIImage *)image andPoint:(CGPoint)point;
@end


@protocol MugMergeManagerDelegate <NSObject>
@required
- (void) mugManager:(MugMergeManager *)manager didMergedImage:(UIImage *)image;
- (void) mugManager:(MugMergeManager *)manager didUpdateProgress:(CGFloat)progress;
@end