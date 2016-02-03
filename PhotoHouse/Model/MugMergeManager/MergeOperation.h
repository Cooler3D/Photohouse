//
//  MergeOperation.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 06/04/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MergeOperationDelegate;

@interface MergeOperation : NSObject
@property (weak, nonatomic) id<MergeOperationDelegate> delegate;

/// Стартуем склеевание полосок картинок
/*! Склееваем полоски по 2 пикселя между собой используя сдвиг
 *@param firstImage первое картинка, может содержать множество полосок рядом
 *@param secondImage вторая картинка приклеевается рядом
 *@param point смещение относительно первой картинки
 *@param delegate делегат
 */
- (void) startMergeFirstImage:(UIImage *)firstImage andSecondImage:(UIImage *)secondImage andPointOffset:(CGPoint)point andDelegate:(id<MergeOperationDelegate>)delegate;
@end


@protocol MergeOperationDelegate <NSObject>
@required
- (void) mergeOperation:(MergeOperation *)operation didMergeImage:(UIImage *)image;
@end