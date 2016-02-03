//
//  Layer.m
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/9/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import "Image.h"
//#import "Position.h"

#import "AFNetworking.h"

// Notification
NSString *const ImagesOpenNotification          = @"ImagesOpenNotification";  // Открыть список картинок
NSString *const ImageSelectNotification         = @"ImageSelectNotification"; // Выделили картинку на развороте


// Keys
NSString *const ImagesSelectKey = @"ImagesSelectKey";
NSString *const ImagePrintKey = @"ImagePrintKey";
NSString *const ImageRectKey = @"ImageRectKey";


@interface Image ()
@property (strong, nonatomic, readonly) NSString *orientationText;
@end


@implementation Image

- (id) initImageDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        //
        _permanent = [dictionary objectForKey:@"permanent"];
        _url_image = [dictionary objectForKey:@"url"];
        _pixelsMin = [dictionary objectForKey:@"pixelsMin"];
        _pixelsLimit = [dictionary objectForKey:@"pixelsLimit"];
        _z = [dictionary objectForKey:@"z"];
        
        NSDictionary *rect = [dictionary objectForKey:@"rect"];
        CGFloat left    = [[rect objectForKey:@"left"] floatValue];
        CGFloat top     = [[rect objectForKey:@"top"] floatValue];
        CGFloat right   = [[rect objectForKey:@"right"] floatValue];
        CGFloat bottom  = [[rect objectForKey:@"bottom"] floatValue];
        _rect = CGRectMake(left, top, right - left, bottom - top);
        
        NSDictionary *crop = [dictionary objectForKey:@"crop"];
        left    = [[crop objectForKey:@"left"] floatValue];
        top     = [[crop objectForKey:@"top"] floatValue];
        right   = [[crop objectForKey:@"right"] floatValue];
        bottom  = [[crop objectForKey:@"bottom"] floatValue];
        _crop = CGRectMake(left, top, right - left, bottom - top);
    }
    return self;
}




- (id) initWithPixelsMin:(NSString *)pixelsMin
          andPixelsLimit:(NSString *)pixelsLimit
                    andZ:(NSString *)z
             andUrlImage:(NSString *)urlImage
            andUrlUpload:(NSString *)urlUpload
            andPermanent:(NSString *)permanent
                 andRect:(CGRect)rect
                 andCrop:(CGRect)crop
                andImage:(UIImage *)image
     andImageOrientation:(UIImageOrientation)orientation andImageOrientationDefault:(UIImageOrientation)orientationDefault
{
    self = [super init];
    if (self) {
        //
        _permanent = permanent;
        _url_image = urlImage;
        _url_upload = urlUpload;
        _pixelsMin = pixelsMin;
        _pixelsLimit = pixelsLimit;
        _z = z;
        _rect   = rect;
        _crop   = crop;
        _image  = image;
        _orientation = orientation;
        _orientationDefault = orientationDefault;
    }
    return self;
}



- (void) startDownloadImage:(id<ImageDelegate>)delegate
{
    _image = [UIImage imageNamed:_url_image];
//    //NSLog(@"Size: %@", NSStringFromCGSize(_image.size));
//    //
    __weak Image *weakSelf = self;
    weakSelf.delegate = delegate;
    if ([self.delegate respondsToSelector:@selector(image:didDownLoadComplate:)] && _image != nil) {
        [self.delegate image:self didDownLoadComplate:_image];
        return;
    }

    //
//    NSString *path = [NSString stringWithFormat:@"http://www.umbarkanta.ru/kam_imgs/%@", _url_image];
    //NSLog(@"url: %@", path);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_url_image]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
    [imageSerializer setImageScale:1.f];
    [operation setResponseSerializer:imageSerializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Block
       _image = responseObject;
        
        NSLog(@"Complete.Size: %@", NSStringFromCGSize(_image.size));
        //
        weakSelf.delegate = delegate;
        if ([self.delegate respondsToSelector:@selector(image:didDownLoadComplate:)]) {
            [self.delegate image:self didDownLoadComplate:_image];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        weakSelf.delegate = delegate;
        if ([self.delegate respondsToSelector:@selector(image:didFailWithError:)]) {
            [self.delegate image:self didFailWithError:error];
        }

    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        double percentDone = (double)totalBytesRead / (double)totalBytesExpectedToRead;
     
        NSLog(@"Progress: %f", percentDone);
    }];
    
   [operation start];
    
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //[connection start];
}

-(BOOL)hasImage
{
    return _image == nil ? NO : YES;
}




- (void) updateUrlImage:(NSString *)urlLibrary
{
    _url_image = urlLibrary;
}


-(void)updateImage:(UIImage *)image
{
    _image = image;
}


-(void)updateCrop:(CGRect)crop
{
    _crop = crop;
}

-(void)updateOrientation:(UIImageOrientation)imageOrientation
{
//    _z = [NSString stringWithFormat:@"%li", (long)imageOrientation];
    _orientation = imageOrientation;
}

- (void)updateDefaulOrientation:(UIImageOrientation)orientationDefault {
    _orientationDefault = orientationDefault;
}


-(NSDictionary *)imageDictionary
{
    NSDictionary *cropDictionary = [self getDictionary:_crop];
    NSDictionary *rectDictionary = [self getDictionary:_rect];
    
    NSString *orientation = [self hasUserImage:self.url_upload] ? self.orientationText : @"0";
    
    NSDictionary *dictionary = @{@"pixelsMin"   : self.pixelsMin,
                                 @"pixelsLimit" : self.pixelsLimit,
                                 @"orientation" : orientation,
                                 @"rect"        : rectDictionary,
                                 @"crop"        : cropDictionary,
                                 @"url"         : self.url_upload ? self.url_upload : self.url_image,
                                 @"permanent"   : orientation,
                                 @"z"           : orientation};
    NSLog(@"image.Dict:%@", dictionary);
    return dictionary;
}

- (NSDictionary *) getDictionary:(CGRect)rect
{
    NSDictionary *dict = @{@"x": [NSString stringWithFormat:@"%f", CGRectGetMinX(rect)],
                           @"y":  [NSString stringWithFormat:@"%f", CGRectGetMinY(rect)],
                           @"width":[NSString stringWithFormat:@"%f", CGRectGetWidth(rect)],
                           @"height":[NSString stringWithFormat:@"%f", CGRectGetHeight(rect)]};
    return dict;
}


/// Получаем значения ориентации
/*! Значения ориентации картинки, т.к на сервере заданы значения отличные от UIImageOrientation
 Там идут 0,90,180,-90
 0 - ничего не делаем (нужно отправлять 1)
 90 - по часовой стрелке (нужно отправлять 2)
 180 - на 180 градусов (нужно отправлять 3)
 -90 - против (нужно отправлять 4)
 Цифры для отправки разнятся с цифрами UIImageOrientation, поэтому КОСТЫЛИ!!!
 И картинка переворачивается по когда загружается на сервер, пожтому КОСТЫЛИ 2 !!!
 *@return возвращаем цифру ориентации
 */
-(NSString *)orientationText {
    NSString *orientationText;
    
//    CGFloat system = [[[UIDevice currentDevice] systemVersion] floatValue];
    
//    if (system < 8.f) {
        if (self.orientation == self.orientationDefault) {
            // Здесь значения по умолчанию, если нечего не вращали относительно старта
            if (self.orientation == UIImageOrientationDown) {
                orientationText = @"3"; // ++
                
            } else if (self.orientation == UIImageOrientationRight) {
                orientationText = @"2"; // ++
                
            } else if (self.orientation == UIImageOrientationLeft) {
                orientationText = @"4"; // 
                
            } else {
                orientationText = @"1"; // ++
            }
            
        } else {
            // Здесь устанавливаем значения, если вращали картинку в редакторе конструктора альбомов
            switch (self.orientationDefault) {
                case UIImageOrientationUp:
                    if (self.orientation == UIImageOrientationDown) {
                        orientationText = @"2"; // ++
                        
                    } else if (self.orientation == UIImageOrientationLeft) {
                        orientationText = @"3"; // ++
                        
                    } else if (self.orientation == UIImageOrientationRight) {
                        orientationText = @"1"; // ++
                        
                    }
                    break;
                    
                case UIImageOrientationDown:
                    if (self.orientation == UIImageOrientationUp) {
                        orientationText = @"2"; //
                        
                    } else if (self.orientation == UIImageOrientationLeft) {
                        orientationText = @"1"; //
                        
                    } else if (self.orientation == UIImageOrientationRight) {
                        orientationText = @"3"; //
                        
                    }
                    
                    break;
                    
                case UIImageOrientationRight:
                    if (self.orientation == UIImageOrientationUp) {
                        orientationText = @"1"; //
                        
                    } else if (self.orientation == UIImageOrientationDown) {
                        orientationText = @"3"; // ++
                        
                    } else if (self.orientation == UIImageOrientationLeft) {
                        orientationText = @"4"; // ++
                        
                    }
                    
                    break;
                    
                case UIImageOrientationLeft:
                    if (self.orientation == UIImageOrientationUp) {
                        orientationText = @"3"; // ++
                        
                    } else if (self.orientation == UIImageOrientationDown) {
                        orientationText = @"1"; // ++
                        
                    } else if (self.orientation == UIImageOrientationRight) {
                        orientationText = @"4"; // ++
                    }
                    
                    break;
                    
                default:
                    orientationText = [NSString stringWithFormat:@"%i", (int)self.orientation];
                    break;
            }
        }
//    } else {
//    
//        if (self.orientation == self.orientationDefault) {
//            // Здесь значения по умолчанию, если нечего не вращали относительно старта
//            if (self.orientation == UIImageOrientationRight || self.orientation == UIImageOrientationLeft) {
//                orientationText = @"3";
//                
//            } else {
//                orientationText = [NSString stringWithFormat:@"%i", (int)UIImageOrientationUp];
//            }
//            
//        } else {
//            // Здесь устанавливаем значения, если вращали картинку в редакторе конструктора альбомов
//            switch (self.orientationDefault) {
//                case UIImageOrientationUp:
//                    if (self.orientation == UIImageOrientationDown) {
//                        orientationText = @"3";
//                        
//                    } else if (self.orientation == UIImageOrientationLeft) {
//                        orientationText = @"4";
//                        
//                    } else if (self.orientation == UIImageOrientationRight) {
//                        orientationText = @"2";
//                        
//                    }
//                    break;
//                    
//                case UIImageOrientationDown:
//                    if (self.orientation == UIImageOrientationUp) {
//                        orientationText = @"3";
//                        
//                    } else if (self.orientation == UIImageOrientationLeft) {
//                        orientationText = @"4";
//                        
//                    } else if (self.orientation == UIImageOrientationRight) {
//                        orientationText = @"2";
//                        
//                    }
//
//                    break;
//                    
//                case UIImageOrientationRight:
//                    if (self.orientation == UIImageOrientationUp) {
//                        orientationText = @"2";
//                        
//                    } else if (self.orientation == UIImageOrientationDown) {
//                        orientationText = @"4";
//                        
//                    } else if (self.orientation == UIImageOrientationLeft) {
//                        orientationText = @"3";
//                        
//                    }
//
//                    break;
//                    
//                case UIImageOrientationLeft:
//                    if (self.orientation == UIImageOrientationUp) {
//                        orientationText = @"4";
//                        
//                    } else if (self.orientation == UIImageOrientationDown) {
//                        orientationText = @"2";
//                        
//                    } else if (self.orientation == UIImageOrientationRight) {
//                        orientationText = @"3";
//                    }
//                    
//                    break;
//                    
//                default:
//                    orientationText = [NSString stringWithFormat:@"%i", (int)self.orientation];
//                    break;
//            }
//        }
//    }
    
    return orientationText;
}

- (BOOL) hasUserImage:(NSString *)orientationText {
    if (!orientationText) {
        return NO;
    }
    
    NSInteger loc = [orientationText rangeOfString:@"uploads/name_"].location;
    BOOL result = (loc == NSNotFound) ? NO : YES;
    return result;
}

@end
