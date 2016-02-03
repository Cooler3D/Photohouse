//
//  RequestUploadImage.h
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/8/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PHRequest.h"

@class PrintImage;

@interface RequestUploadPrintImage : PHRequest
- (id) initUploadPrintImage:(PrintImage *)printImage;
@end
