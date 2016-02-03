//
//  UIImage+Crop.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/29/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "UIImage+Crop.h"
#import "UIImage+Utility.h"

@implementation UIImage (Crop)

- (UIImage*) cropImage:(UIImageView*)photoImageView withCropImageView:(UIImageView*)cropImageView andRatio:(CGFloat)ratio {
    UIImage *image = photoImageView.image;
    
    // Вырезаем
    CGRect cropSelected = [self cropImageAndRect:photoImageView withCropImageView:cropImageView andRatio:ratio];
    UIImage *imageRect = [self cropImageFrom:image WithRect:cropSelected];
    
    return imageRect;

}


- (CGRect) cropImageAndRect:(UIImageView*)photoImageView withCropImageView:(UIImageView*)cropImageView andRatio:(CGFloat)ratio {
    UIImage *image = photoImageView.image;
    /*NSLog(@"img.size: %@", NSStringFromCGSize(image.size));
    NSLog(@"photoView.rect: %@", NSStringFromCGRect(photoImageView.frame));
    NSLog(@"cropView.rect: %@", NSStringFromCGRect(cropImageView.frame));*/
    
    
    // Отступ в процентах, на разнице по Х, photoImageView и CropView
    CGFloat offsetX = CGRectGetMinX(cropImageView.frame) - CGRectGetMinX(photoImageView.frame);
    CGFloat persentX = (offsetX * 100) / CGRectGetWidth(photoImageView.frame);
    // Вычисляем смещение по Х
    CGFloat offsetImageX = (persentX * image.size.width) / 100;
    
    
    
    // Отступ в процентах, на разнице по Y, photoImageView и CropView
    CGFloat offsetY = CGRectGetMinY(cropImageView.frame) - CGRectGetMinY(photoImageView.frame);
    CGFloat persentY = (offsetY * 100) / CGRectGetHeight(photoImageView.frame);
    // Вычисляем смещение по Y
    CGFloat offsetImageY = (persentY * image.size.height) / 100;
    
    
    
    
    // Ширина
    // Ширина cropView * 100% / photoView
    CGFloat persentWidth = (CGRectGetWidth(cropImageView.frame) * 100) / CGRectGetWidth(photoImageView.frame);
    CGFloat persentHeight = (CGRectGetHeight(cropImageView.frame) * 100) / CGRectGetHeight(photoImageView.frame);
    // Вычисляем ширину
    CGFloat widthRect = 0.f; //= (image.size.width * persentWidth) / 100;
    CGFloat heightRect = 0.f; //= widthRect / ratio; // Т.к Crop 1:ratio (ratio может быть 2; 2.6, 0.5 и др)
    if (ratio >= 1) {
        widthRect = (image.size.width * persentWidth) / 100;
        heightRect = widthRect / ratio;
    } else {
        heightRect = (image.size.height * persentHeight) / 100;
        widthRect = heightRect * ratio;
    }
    
    
    // Создаем область по параметрам
    CGRect cropSelected = CGRectMake(offsetImageX, offsetImageY, widthRect, heightRect);
    NSLog(@"Rect: %@", NSStringFromCGRect(cropSelected));

    return cropSelected;
}



- (UIImage*) cropImageFrom: (UIImage*) img WithRect: (CGRect) rect {
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [img drawInRect:drawRect];
    
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}



- (UIImage*) cropWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}



- (CGRect) insertSizeView:(CGSize)sizeView withAspectRatio:(CGFloat)aspect_ratio
{
    CGSize cropSize;
    
    
    // Формируем все значения размеров и подбервем наиболее подходящий
    NSMutableArray *sizes = [NSMutableArray array];
    
    //
    NSInteger min = MIN(sizeView.width, sizeView.height);
    NSInteger max = MAX(sizeView.width, sizeView.height);
    
    
    // Min
    cropSize = CGSizeMake(min,
                          min / aspect_ratio);
    [sizes addObject:[NSValue valueWithCGSize:cropSize]];
    
    // Min
    cropSize = CGSizeMake(min * aspect_ratio,
                          min);
    [sizes addObject:[NSValue valueWithCGSize:cropSize]];
    
    
    
    // Max
    cropSize = CGSizeMake(max,
                          max / aspect_ratio);
    [sizes addObject:[NSValue valueWithCGSize:cropSize]];
    
    // Max
    cropSize = CGSizeMake(max * aspect_ratio,
                          max);
    [sizes addObject:[NSValue valueWithCGSize:cropSize]];
    
    
    
    
    
    
    
    
    
    
    // Check
    cropSize = [self checkSizesArray:sizes andImageSize:sizeView];
    //NSLog(@"sizeCrop: %@", NSStringFromCGSize(cropSize));
    CGFloat cropX = 0.f;
    CGFloat cropY = 0.f;
    if (sizeView.width > cropSize.width) {              cropX = (sizeView.width - cropSize.width) / 2;
    } else if (sizeView.height > cropSize.height) {     cropY = (sizeView.height - cropSize.height) / 2;}
    
    CGRect cropRect = CGRectMake(cropX, cropY, cropSize.width, cropSize.height);
    //NSLog(@"CropRect: %@", NSStringFromCGRect(cropRect));
    
    //return cropSize;
    return cropRect;

}



- (CGRect) sizeImage:(UIImage*)image withDelitelHeight:(CGFloat)delitel {
    CGSize size = image.size;
    //NSLog(@"sizeImage: %@", NSStringFromCGSize(size));
    //NSLog(@"delitel: %f", delitel);
    CGRect rect = [self insertSizeView:size withAspectRatio:delitel];
    return rect;
}



- (CGSize) checkSizesArray:(NSArray*)sizes andImageSize:(CGSize)imageSize {
    for (NSValue *value in sizes) {
        CGSize size = [value CGSizeValue];
        if ((size.width == imageSize.width && size.height < imageSize.height) || (size.width < imageSize.width && size.height == imageSize.height)) {
            return size;
        }
        if ((size.width == imageSize.width && size.height == imageSize.height) ) {
            return size;
        }
    }
    
    return CGSizeZero;
}







- (CGRect) insertToCenterRect:(CGRect)mainRect
{
    // Картинка
    UIImage *image = self;
    CGSize imageSize = CGSizeMake(image.size.width, image.size.height);
    
    // Т.к картинка всегда прямоугольная, то значение должно быть > 1
    CGFloat aspect_ratio = imageSize.width / imageSize.height;
    
    
    // Формируем все значения размеров и подбервем наиболее подходящий
    NSMutableArray *sizes = [NSMutableArray array];
    
    CGSize size;
    // Создаем пропорцию и деля на "соотношение сторон"
    size = CGSizeMake(CGRectGetWidth(mainRect),
                      CGRectGetWidth(mainRect) / aspect_ratio);
    [sizes addObject:[NSValue valueWithCGSize:size]];
    //NSLog(@"Size: %@", NSStringFromCGSize(size));
    
    
    // Умножаем высоту
    size = CGSizeMake(CGRectGetHeight(mainRect) * aspect_ratio,
                      CGRectGetHeight(mainRect));
    [sizes addObject:[NSValue valueWithCGSize:size]];
    //NSLog(@"Size: %@", NSStringFromCGSize(size));
    
    
    
    // Block Сравнения
    CGSize (^CompareBlockSize)(NSArray *sizesList, CGSize originalImage) = ^(NSArray *sizesList, CGSize originalImage) {
        CGSize result = CGSizeZero;
        
        for (NSValue *value in sizes) {
            CGSize currentSize = [value CGSizeValue];
            
            if ((currentSize.width < CGRectGetWidth(mainRect) && currentSize.height == CGRectGetHeight(mainRect)) ||
                (currentSize.width == CGRectGetWidth(mainRect) && currentSize.height < CGRectGetHeight(mainRect)))
            {
                result = currentSize;
            }
        }
        
        return CGSizeEqualToSize(result, CGSizeZero) ? originalImage : result;
    };
    

    CGSize finalSize = CompareBlockSize(sizes, imageSize);

    CGRect finalRect = CGRectMake((CGRectGetWidth(mainRect) - finalSize.width) / 2,
                                  (CGRectGetHeight(mainRect) - finalSize.height) / 2,
                                  finalSize.width,
                                  finalSize.height);
    
    // НЕ забываем прибавить значения от mianRect, чтобы спозиционировать по центру экрана
    CGRect resultRect = CGRectMake(CGRectGetMinX(finalRect) + CGRectGetMinX(mainRect),
                                   CGRectGetMinY(finalRect) + CGRectGetMinY(mainRect),
                                   CGRectGetWidth(finalRect),
                                   CGRectGetHeight(finalRect));
    
    return resultRect;
}






#pragma mark - Orientation
- (UIImage*)rotateImage:(UIImage*)image andRadian:(CGFloat)angle
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    //NSLog(@"%@", [filter attributes]);
    
    [filter setDefaults];
    CGAffineTransform transform = CATransform3DGetAffineTransform([self rotateTransform:CATransform3DIdentity clockwise:NO andRadian:angle]);
    [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}



- (CATransform3D)rotateTransform:(CATransform3D)initialTransform clockwise:(BOOL)clockwise andRadian:(CGFloat)angle
{
    //CGFloat angle = -M_PI_2;
    CGFloat arg = angle;
    if(!clockwise){
        arg *= -1;
    }
    
    CATransform3D transform = initialTransform;
    transform = CATransform3DRotate(transform, arg, 0, 0, 1);
    
    // Костыль
    NSLog(@"%@ - %@", [NSString stringWithFormat:@"%f", angle], [NSString stringWithFormat:@"%f", M_PI]);
    if (![[NSString stringWithFormat:@"%f", angle] isEqualToString:[NSString stringWithFormat:@"%f", M_PI]]) {
        transform = CATransform3DRotate(transform, 1*M_PI, 0, 1, 0);
        transform = CATransform3DRotate(transform, 0*M_PI, 1, 0, 0);
    }
    
    return transform;
}


#pragma mark - Scale
/*- (UIImage*)scaledImage:(UIImage*)image
           scaledToSize:(CGSize)newSize*/
- (UIImage*)scaledImageToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}



#pragma mark - Resize To Side

-(UIImage *)resizeImageToBiggerSide:(NSInteger)biggerSide
{
    CGSize size = [self converToBiggerSide:biggerSide andOriginalSize:self.size];
    UIImage *preview = [self resize:size];
    return preview;
}


- (CGSize) converToBiggerSide:(NSInteger)side andOriginalSize:(CGSize)originalSize
{
    CGFloat width = originalSize.width;
    CGFloat height = originalSize.height;
    
    CGSize size;
    
    if (width > height) {
        size = CGSizeMake(side, height * side / width);
    } else if (width < height) {
        size = CGSizeMake(width * side / height ,side);
    } else {
        size = CGSizeMake(side, side);
    }
    
    return size;
}



#pragma mark - MergeImage
- (UIImage*) mergeImage:(UIImage*)secondImage toOrientation:(MergeOrientaion)orientation
{
    UIImage *image = nil;
    
    UIImage *firstImage = self;
    
    //CGSize newImageSize = CGSizeMake(MAX(firstImage.size.width, secondImage.size.width), MAX(firstImage.size.height, secondImage.size.height));
    CGSize newImageSize;
    switch (orientation) {
        case MergeOrientaionToWidth:
            newImageSize = CGSizeMake(firstImage.size.width + secondImage.size.width,
                                     MAX(firstImage.size.height, secondImage.size.height));
            break;
            
        case MergeOrientaionToHeight:
            newImageSize = CGSizeMake(MAX(firstImage.size.width,secondImage.size.width),
                                      firstImage.size.height + secondImage.size.height);
            break;
    }
        
    //CGSize newImageSize = CGSizeMake(1365, 1415);
//    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
//    } else {
//        UIGraphicsBeginImageContext(newImageSize);
//    }
    
    [firstImage drawAtPoint:CGPointMake(0, 0)];
    [secondImage drawAtPoint:CGPointMake(orientation == MergeOrientaionToWidth ? firstImage.size.width : 0,
                                         orientation == MergeOrientaionToWidth ? 0 : firstImage.size.height)];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}



- (UIImage *) mergeImageView:(UIImageView *)imageView withLowerImageView:(UIImageView *)lowerImageView andUpperImageView:(UIImageView *)upperImageView
{
    CGRect rect = imageView.frame;
    
    UIImage *lowerImage     = lowerImageView.image;
    UIImage *middleImage    = [imageView.image scaledImageToSize:rect.size];
    UIImage *upperImage     = upperImageView.image;
    
    /*NSLog(@"upper: %@", NSStringFromCGSize(lowerImage.size));
    NSLog(@"image: %@", NSStringFromCGSize(middleImage.size));
    NSLog(@"bottom: %@", NSStringFromCGSize(upperImage.size));*/
    
    CGSize newImageSize = CGSizeMake(CGRectGetWidth(lowerImageView.frame), CGRectGetHeight(lowerImageView.frame));
//    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
//    } else {
//        UIGraphicsBeginImageContext(newImageSize);
//    }
    
    
    [lowerImage drawInRect:lowerImageView.bounds];
    [middleImage drawInRect:imageView.frame];
    [upperImage drawInRect:lowerImageView.bounds];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



-(UIImage*) drawText:(NSString*) text
{
    UIImage *image = self;
    
    UIFont *font;
    NSDictionary *dict;
    CGSize sizeText;
    
    for (int i=100; i<300; i+=20) {
        
        font = [UIFont boldSystemFontOfSize:i];
        dict = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        sizeText = [text sizeWithAttributes:dict];
        
        if (sizeText.width > image.size.width) {
            font = [UIFont boldSystemFontOfSize:i-20];
            dict = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
            sizeText = [text sizeWithAttributes:dict];
            break;
        }
        
    }
    
    
    CGPoint point = CGPointMake((image.size.width - sizeText.width) / 2,
                                (image.size.height - sizeText.height) / 2);
    
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    [text drawAtPoint:point withAttributes:dict];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
