//
//  EditPhotoConstructorViewController.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 27/10/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import "PHBaseViewController.h"

@class PrintData;
@class PrintImage;
@class EditImageSetting;

@interface EditPhotoConstructorViewController : PHBaseViewController
- (id)initPrintImage:(PrintImage *)printImage andAspect_ratio:(CGFloat)aspect_ratio andCompleteBlock:(void(^)(PrintImage *printImage, EditImageSetting *imageSetting))completeBlock;
@end
