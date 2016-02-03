//
//  JsonUploadImage.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 26/06/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "JsonUploadImage.h"

#import "PrintImage.h"
#import "CoreDataSocialImages.h"


@implementation JsonUploadImage
@synthesize imageData = _imageData;
@synthesize jsonDictionary = _jsonDictionary;


-(id)initWithPrintImage:(PrintImage *)printImage andImageData:(NSData *)imageData
{
    self = [super init];
    if (self) {
        [self createJson:printImage andImageData:imageData];
    }
    return self;
}

- (void) createJson:(PrintImage *)printImage  andImageData:(NSData *)imageLargeData
{
    if (printImage.isMergedImage) {
        NSData *imageData = UIImageJPEGRepresentation(printImage.previewImage, 0.6f);
        _imageData = imageData;
    } else if(printImage.imageLibrary == ImageLibrarySocial) {
        CoreDataSocialImages *coreSocial = [[CoreDataSocialImages alloc] init];
        NSData *socialImageData = [coreSocial getImageDataWithURL:printImage.urlLibrary];
        _imageData = socialImageData;
    } else {
        _imageData = imageLargeData;
    }
    
//    UIImage *senImage = [UIImage imageWithData:imageData];
    
    NSString *timeStamp = [self getTimeStamp];
    
    NSDictionary *uploadDict = @{@"act": @"upload_files",
                                 @"time": timeStamp};
    
    _jsonDictionary = uploadDict;
}
@end
