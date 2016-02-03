//
//  JsonUploadImage.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 26/06/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "Json.h"

@class PrintImage;

@interface JsonUploadImage : Json
- (id)initWithPrintImage:(PrintImage *)printImage andImageData:(NSData *)imageData;
@end
