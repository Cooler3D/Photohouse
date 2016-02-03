//
//  UIImage+AssertResize.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/5/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAsset;

@interface UIImage (AssetResize)
+ (UIImage *) imageWithALAssert:(ALAsset *)asset toLargerSide:(NSInteger)side;
@end
