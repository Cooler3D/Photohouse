//
//  PhotoRecord.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/1/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "PhotoRecord.h"

@implementation PhotoRecord
@synthesize name = _name;
@synthesize image = _image;
@synthesize URL = _URL;
@synthesize hasImage = _hasImage;
@synthesize failed = _failed;
@synthesize importFromLibrary = _importFromLibrary;
@synthesize imageSize = _imageSize;



- (id)initWithAsset:(ALAsset *)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
        _name = [NSString stringWithFormat:@"%@", asset.defaultRepresentation.url];
        _importFromLibrary = ImportLibraryPhone;
        _image = [UIImage imageWithCGImage:[asset thumbnail]];
    }
    return self;
}


//-(id)initWithSocialURl:(NSString *)socialUrl andImaportLibrary:(ImportLibrary)importLibrary
- (id) initWithSocialURl:(NSString *)socialUrl withImage:(UIImage *)image andImportLibrary:(ImportLibrary)importLibrary
{
    self = [super init];
    if (self) {
        _URL = [NSURL URLWithString:socialUrl];
        _name = socialUrl;
        _importFromLibrary = importLibrary;
        _image = image;
        _imageSize = image.size;
    }
    return self;
}

-(id)initAssetThumbal:(CGImageRef)preview andNameUrlLibary:(NSString *)urlLib andDate:(NSDate *)date andImageSize:(CGSize)imageSize {
    self = [super init];
    if (self) {
        _name = urlLib;
        _importFromLibrary = ImportLibraryPhone;
        _dateSave = date;
        _image = [UIImage imageWithCGImage:preview];
        _imageSize = imageSize;
    }
    return self;
}



- (BOOL)hasImage {
    return _image == nil ? NO : YES;
}


- (BOOL)isFailed {
    return _failed;
}


- (BOOL)isSelected {
    return _selected;
}


- (BOOL)isEdited {
    return _edited;
}

-(NSURL *)URL
{
    return [NSURL URLWithString:_name];
}

-(ImportLibrary)importFromLibrary {
    NSInteger loc = [self.name rangeOfString:@"http"].location;
    NSInteger locVk = [self.name rangeOfString:@".vk.me/"].location;
    if (loc == NSNotFound && locVk == NSNotFound) {
        return ImportLibraryPhone;
    } else if (locVk == NSNotFound && loc != NSNotFound) {
        return ImportLibraryInstagram;
    } else {
        return ImportLibraryVKontkte;
    }
}

-(CGSize)imageSize {
    return CGSizeEqualToSize(_imageSize, CGSizeZero) ? ([self hasImage] ? _image.size : CGSizeZero) : _imageSize;
}

@end
