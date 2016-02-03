//
//  PrintImage.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/20/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PrintImage.h"
#import "LoadImageManager.h"

#import "UIImage+Utility.h"
#import "UIImage+AssetResize.h"
#import "UIImage+Crop.h"

#import "CoreDataShopCart.h"
#import "CoreDataSocialImages.h"

typedef enum {
    ImageTypeJPG,
    ImageTypePNG
} ImageType;


/// Большая сторона картинки, к которой маштабируем картинку
static NSInteger const SIDE = 640;


@interface PrintImage ()
@property (assign, nonatomic) ImageType imageType;
@property (assign, nonatomic, readonly) BOOL hasChangeOrientation;  ///< Была ли смена ориентации после редактора (Применяется в конструкторе альбомов)

@end



@implementation PrintImage
@synthesize editedImageSetting = _editedImageSetting;
@synthesize previewImage = _previewImage;
@synthesize assetImage = _assetImage;
@synthesize imageLargeData = _imageLargeData;
@synthesize imageLibrary = _imageLibrary;
@synthesize iconPreviewImage = _iconPreviewImage;


- (id) initLargeImageData:(NSData *)imageData andPreviewImage:(UIImage *)previewImage withName:(NSString *)imageUrlName andEditSetting:(EditImageSetting *)editSetting
{
    self = [super init];
    if (self) {
        _imageLargeData     = imageData;
        _previewImage       = [editSetting isDidEditing] ? previewImage : [UIImage imageWithData:imageData];
        _urlLibrary         = imageUrlName;
        _isMergedImage      = NO;
        _originalImageSize  = imageData == nil ? _previewImage.size : [[UIImage imageWithData:imageData] size];
        _editedImageSetting = editSetting;
    }
    return self;
}

-(id)initWithPreviewImage:(UIImage *)image withName:(NSString *)imageUrlName andEditSetting:(EditImageSetting *)editSetting originalSize:(CGSize)originalSize andUploadUrl:(NSString *)uploadUrl
{
    self = [super init];
    if (self) {
        _previewImage = (image.size.width >= SIDE || image.size.height >= SIDE) ? image : nil;
        _photoPrintImage = [_previewImage copy];
        _urlLibrary     = imageUrlName;
        _isMergedImage  = NO;
        _originalImageSize = CGSizeEqualToSize(originalSize, CGSizeZero) ? image.size : originalSize;
        _iconPreviewImage = [image aspectFill:CGSizeMake(50, 50)];
        _editedImageSetting = editSetting ? editSetting : [[EditImageSetting alloc] initSettingWithImage:image];
        _imageLibrary = ImageLibrarySocial;
        _uploadURL = [NSURL URLWithString:uploadUrl];
    }
    return self;
}


- (id) initMergeImage:(UIImage *)image withName:(NSString *)imageUrlName andUploadUrl:(NSString *)uploadUrl
{
    self = [super init];
    if (self) {
        _previewImage   = image;
        _urlLibrary     = imageUrlName;
        _isMergedImage  = YES;
        _originalImageSize = image.size;
        _editedImageSetting = [[EditImageSetting alloc] initSettingWithImage:image];
        _uploadURL = [NSURL URLWithString:uploadUrl];
    }
    return self;
}


-(id)initWithALAsset:(ALAsset *)asset withName:(NSString *)imageUrlName
{
    self = [super init];
    if (self) {
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        NSDictionary *metadata = representation.metadata;
        NSInteger imageWidth = [[metadata objectForKey:@"PixelWidth"] integerValue];
        NSInteger imageHeight = [[metadata objectForKey:@"PixelHeight"] integerValue];
        _originalImageSize = CGSizeMake(imageWidth, imageHeight);
        
        _isMergedImage      = NO;
        _urlLibrary         = [representation.url absoluteString];
        _assetImage         = asset;
        _imageLibrary       = ImageLibraryPhone;
        
        NSLog(@"ALAsset.orientation: %i", (int)representation.orientation);
    }
    
    return self;
}



- (id) initWithHistoryOrderDictionary:(NSDictionary *)imageDictionary
{
    self = [super init];
    if (self) {
        [self parseImageDictionary:imageDictionary];
        _isMergedImage = YES;
    }
    return self;
}



// Парсим историю
- (void) parseImageDictionary:(NSDictionary *)imageDictionary
{
    NSString *path = [imageDictionary objectForKey:@"image"];
    _uploadURL = [NSURL URLWithString:path];
}





- (void) updatePreviewImage:(UIImage *)image
{
    _previewImage = image;
}


- (void) updateOriginalSize:(CGSize)originalSize {
    _originalImageSize = originalSize;
}


-(void)updateUrlLibrary:(NSString *)urlLibrary andImageLibrary:(ImageLibrary)imageLibrary withPrintDataUnique:(NSUInteger)unique {
    _imageLibrary = imageLibrary;
    
    [self.editedImageSetting changeSetupDefault];
    
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop updateURLLibraryWithPrintDataUnique:unique andPrintImage:self andNewUrlLibraryKey:urlLibrary];
    
    _urlLibrary = urlLibrary;
}

-(void)updateUploadUrl:(NSString *)uploadUrl withPrintDataUnique:(NSUInteger)unique {
    _uploadURL = [NSURL URLWithString:uploadUrl];
    
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop updateAfterUploadPrintDataUnique:unique andPrintImage:self];
}


- (void) clearImageLargeData
{
    _imageLargeData = nil;
}


- (CGSize)calculateOriginalSizeWithOrientation:(UIImageOrientation)showedImageOrientation {
    
    UIImageOrientation printImageDefaultOrientation = self.editedImageSetting.imageDefaultOrientation;
    CGSize size = CGSizeZero;
    
    if ((printImageDefaultOrientation == UIImageOrientationDown || printImageDefaultOrientation == UIImageOrientationUp) &&
        (showedImageOrientation == UIImageOrientationLeft || showedImageOrientation == UIImageOrientationRight)) {
        size = CGSizeMake(self.originalImageSize.height, self.originalImageSize.width);
        
    } else if ((printImageDefaultOrientation == UIImageOrientationRight || printImageDefaultOrientation == UIImageOrientationLeft) &&
               (showedImageOrientation == UIImageOrientationUp || showedImageOrientation == UIImageOrientationDown)) {
        size = CGSizeMake(self.originalImageSize.height, self.originalImageSize.width);
        
    } else {
        size = CGSizeMake(self.originalImageSize.width, self.originalImageSize.height);
    }
    
    return size;
}



- (void) addOriginalSocilaImage:(UIImage *)originalSocialImage orOriginalAsset:(ALAsset *)asset
{
//    if (originalSocialImage == nil && asset != nil)
//    {
//        // Картинка из телефона
//        ALAssetRepresentation *representation = asset.defaultRepresentation;
//        NSDictionary *metadata = representation.metadata;
//        NSInteger imageWidth = [[metadata objectForKey:@"PixelWidth"] integerValue];
//        NSInteger imageHeight = [[metadata objectForKey:@"PixelHeight"] integerValue];
//        
//        
//        ALAssetOrientation orientation = representation.orientation;
//        NSLog(@"OriginalSocilaImage.Orientation: %i", (int)orientation);
//        _originalImageSize = /*(orientation == ALAssetOrientationUp || orientation == ALAssetOrientationDown) ? */CGSizeMake(imageWidth, imageHeight)/* : CGSizeMake(imageHeight, imageWidth)*/;
//        
//        UIImage *result = [UIImage imageWithALAssert:asset toLargerSide:ScaledSide];
//        NSLog(@"OriginalSocilaImage.Size: %@", NSStringFromCGSize(result.size));
//        _previewImage = (orientation == ALAssetOrientationUp/* || orientation == ALAssetOrientationDown*/) ? result : [UIImage imageWithCGImage:result.CGImage scale:result.scale orientation:(UIImageOrientation)orientation];
//        NSLog(@"OriginalSocilaImage.Size: %@", NSStringFromCGSize(_previewImage.size));
//        
//        _editedImageSetting = [[EditImageSetting alloc] initSettingWithImage:_previewImage];
//        [self.editedImageSetting changeOrientation:(UIImageOrientation)representation.orientation];
//        [self.editedImageSetting changeOrientationDefault:(UIImageOrientation)representation.orientation];
//    }
//    else if(originalSocialImage != nil && asset == nil)
//    {
//        // Картинка из соц.сетей
//        _originalImageSize  = originalSocialImage.size;
//        
//        _previewImage       = [originalSocialImage resizeImageToBiggerSide:ScaledSide];
//        _editedImageSetting = [[EditImageSetting alloc] initSettingWithImage:_previewImage];
//        [self.editedImageSetting changeOrientation:_previewImage.imageOrientation];
//        [self.editedImageSetting changeOrientationDefault:_previewImage.imageOrientation];
//    }
//    else {
//        return;
//    }
    
    
    
//    _editedImageSetting = [[EditImageSetting alloc] initSettingWithImage:_previewImage];
    _previewImage = originalSocialImage;
    _iconPreviewImage = [_previewImage aspectFill:CGSizeMake(50, 50)];
    _photoPrintImage = [_previewImage copy];
    
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop updateAfterEditorPrintData:nil andPrintImage:self];
    
    NSLog(@"PreviewSize: %@", NSStringFromCGSize(_previewImage.size));
    NSLog(@"IconSize: %@", NSStringFromCGSize(_iconPreviewImage.size));
}




- (void) cropPhotPrintWithGrigImage:(UIImage *)gridImage
{
    CGFloat aspect_ratio = gridImage.size.width / gridImage.size.height;
    CGRect rect = [_previewImage sizeImage:_previewImage withDelitelHeight:aspect_ratio];
    CGFloat aspectScale = self.originalImageSize.width / self.previewImage.size.width;
    
    _previewImage = [[UIImage alloc] cropImageFrom:_previewImage WithRect:rect];
    
    // Финальное обрезание, для оригинальной картинки
    CGRect finalCropRect = CGRectMake(CGRectGetMinX(rect) * aspectScale,
                                      CGRectGetMinY(rect) * aspectScale,
                                      CGRectGetWidth(rect) * aspectScale,
                                      CGRectGetHeight(rect) * aspectScale);
    [_editedImageSetting changeCropRect:finalCropRect];
}



- (UIImage *) cropImageWithCropSize:(CGSize)cropSize
{
    CGFloat aspect_ratio = cropSize.width / cropSize.height;
    UIImage *previewImage = [self.editedImageSetting executeImage:_previewImage];
    CGRect rect = [previewImage sizeImage:_previewImage withDelitelHeight:aspect_ratio];
    CGFloat aspectScale = self.originalImageSize.width / previewImage.size.width;
    
    /// Обрезаем картинку
    UIImage *cropImage = [[UIImage alloc] cropImageFrom:previewImage WithRect:rect];
    
    
    
    if (![self.editedImageSetting isDidEditing]) {
       
        /// оригинальные размеры картинки, большой которая в библиотеке/CoreData
        CGSize imageOriginalSize = self.originalImageSize;//CGSizeMake(775, 771);
        
        /// Размеры увеличенной картинки в редакторе
        CGSize editedImageSize = self.editedImageSetting.editedImageSize;//CGSizeMake(800, 795.87);
        
        /// Значения после редактора, картинку увеличили
        CGRect cropEditor = self.editedImageSetting.cropRect;//CGRectMake(85, 133, 630, 528);
        
        /// Отношение увеличенной картинки к оригинальной, значение должно быть больше 1
        CGFloat scale = editedImageSize.width / imageOriginalSize.width;
        
        CGRect cropOriginal = CGRectMake([self.editedImageSetting isDidEditing] ? CGRectGetMinX(cropEditor) / scale : CGRectGetMinX(rect) * aspectScale,
                                         [self.editedImageSetting isDidEditing] ? CGRectGetMinY(cropEditor) / scale : CGRectGetMinY(rect) * aspectScale,
                                         [self.editedImageSetting isDidEditing] ? CGRectGetWidth(cropEditor) / scale : CGRectGetWidth(rect) * aspectScale,
                                         [self.editedImageSetting isDidEditing] ? CGRectGetHeight(cropEditor) / scale : CGRectGetHeight(rect) * aspectScale);
        
        
        [_editedImageSetting changeCropRect:cropOriginal];
    } else {
        CGFloat zoom = self.originalImageSize.width / _previewImage.size.width;
        CGRect crop = CGRectMake(CGRectGetMinX(self.editedImageSetting.cropRect) / zoom,
                                 CGRectGetMinY(self.editedImageSetting.cropRect) / zoom,
                                 CGRectGetWidth(self.editedImageSetting.cropRect) / zoom,
                                 CGRectGetHeight(self.editedImageSetting.cropRect) / zoom);
        cropImage = [[UIImage alloc] cropImageFrom:previewImage WithRect:crop];
    }

    return cropImage;
}

- (void) cropImageWithCropSize:(CGSize)cropSize withCompleteBlock:(void(^)(UIImage *image))completeBlock {
    
    [self.editedImageSetting executeImage:_previewImage withCompleteBlock:^(UIImage *resultImage) {
        UIImage *previewImage = resultImage;
    
        CGFloat aspect_ratio = cropSize.width / cropSize.height;
        CGRect rect = [previewImage sizeImage:_previewImage withDelitelHeight:aspect_ratio];
        CGFloat aspectScale = self.originalImageSize.width / previewImage.size.width;
        
        /// Обрезаем картинку
        UIImage *cropImage = [[UIImage alloc] cropImageFrom:previewImage WithRect:rect];
        
        
        if (![self.editedImageSetting isDidEditing]) {
            
            /// оригинальные размеры картинки, большой которая в библиотеке/CoreData
            CGSize imageOriginalSize = self.originalImageSize;//CGSizeMake(775, 771);
            
            /// Размеры увеличенной картинки в редакторе
            CGSize editedImageSize = self.editedImageSetting.editedImageSize;//CGSizeMake(800, 795.87);
            
            /// Значения после редактора, картинку увеличили
            CGRect cropEditor = self.editedImageSetting.cropRect;//CGRectMake(85, 133, 630, 528);
            
            /// Отношение увеличенной картинки к оригинальной, значение должно быть больше 1
            CGFloat scale = editedImageSize.width / imageOriginalSize.width;
            
            CGRect cropOriginal = CGRectMake([self.editedImageSetting isDidEditing] ? CGRectGetMinX(cropEditor) / scale : CGRectGetMinX(rect) * aspectScale,
                                             [self.editedImageSetting isDidEditing] ? CGRectGetMinY(cropEditor) / scale : CGRectGetMinY(rect) * aspectScale,
                                             [self.editedImageSetting isDidEditing] ? CGRectGetWidth(cropEditor) / scale : CGRectGetWidth(rect) * aspectScale,
                                             [self.editedImageSetting isDidEditing] ? CGRectGetHeight(cropEditor) / scale : CGRectGetHeight(rect) * aspectScale);
            
            
            [_editedImageSetting changeCropRect:cropOriginal];
        } else {
            UIImage *result = self.hasChangeOrientation ? [UIImage imageWithCGImage:previewImage.CGImage scale:previewImage.scale orientation:self.editedImageSetting.imageOrientation] : previewImage;
            CGFloat zoom = self.originalImageSize.width / result.size.width;
            CGRect crop = CGRectMake(CGRectGetMinX(self.editedImageSetting.cropRect) / zoom,
                                     CGRectGetMinY(self.editedImageSetting.cropRect) / zoom,
                                     CGRectGetWidth(self.editedImageSetting.cropRect) / zoom,
                                     CGRectGetHeight(self.editedImageSetting.cropRect) / zoom);
            cropImage = [[UIImage alloc] cropImageFrom:result WithRect:crop];
        }
    

        //
        if (completeBlock) {
            completeBlock(cropImage);
        }
    }];
}



-(void)cropImageForObjects:(UIImage *)gridImage
{
    CGFloat aspect_ratio = gridImage.size.width / gridImage.size.height;
    CGRect rect = [[UIImage alloc] insertSizeView:_originalImageSize withAspectRatio:aspect_ratio];
    
//    CGFloat aspectScale = self.originalImageSize.width / self.previewImage.size.width;
//    
//    CGRect final = CGRectMake(CGRectGetMinX(rect) * aspectScale,
//                              CGRectGetMinY(rect) * aspectScale,
//                              CGRectGetWidth(rect) * aspectScale,
//                              CGRectGetHeight(rect) * aspectScale);
    [_editedImageSetting changeCropRect:rect];
}


-(void)cropImageForDesingAlbum
{
    CGRect final = CGRectMake(0.f, 0.f, self.originalImageSize.width, self.originalImageSize.height);
    [_editedImageSetting changeCropRect:final];
}


-(void)resizeImageToMaxSide:(NSInteger)side {
    UIImage *originalImage = _imageLargeData ? [UIImage imageWithData:_imageLargeData] : _previewImage;
    NSLog(@"Before.size: %@", NSStringFromCGSize(originalImage.size));
    UIImage *result = [originalImage resizeImageToBiggerSide:side];
    NSLog(@"After: %@", NSStringFromCGSize(result.size));
    _previewImage = result;
    _imageLargeData = UIImagePNGRepresentation(result);
    
    CGSize originalSize = self.originalImageSize;
    CGSize reSize = result.size;
    
    CGFloat zoom = originalSize.width / reSize.width;
    
    CGRect crop = self.editedImageSetting.cropRect;
    [self.editedImageSetting changeCropRect:CGRectMake(CGRectGetMinX(crop) / zoom,
                                                       CGRectGetMinY(crop) / zoom,
                                                       CGRectGetWidth(crop) / zoom,
                                                       CGRectGetHeight(crop) / zoom)];
    _originalImageSize = reSize;
}


#pragma mark - Publuc Getter
-(BOOL)isDidEdited {
    return !_editedImageSetting ? NO : _editedImageSetting.isDidEditing;
}



- (EditImageSetting *)editedImageSetting {
    if (!_editedImageSetting) {
        _editedImageSetting = [[EditImageSetting alloc] initFilterName:DEFAUL_FILTER
                                                         andSaturation:DEFAULT_SATURATION
                                                         andBrightness:DEFAULT_BRIGHTNESS
                                                           andContrast:DEFAULT_CONSTRAST
                                                           andCropRect:CGRectMake(0, 0, _originalImageSize.width, _originalImageSize.height)
                                                      andRectToVisible:CGRectZero
                                                andAutoResizingEnabled:YES
                                                   andImageOrientation:UIImageOrientationUp andImageDefautlOrientation:UIImageOrientationUp];
    }
    return _editedImageSetting;
}

-(ImageLibrary)imageLibrary {
    NSInteger loc = [self.urlLibrary rangeOfString:@"http"].location;
    return loc == NSNotFound ? ImageLibraryPhone : ImageLibrarySocial;
}

-(BOOL)hasChangeOrientation {
    EditImageSetting *setting = self.editedImageSetting;
    return setting.imageOrientation == setting.imageDefaultOrientation ? NO : YES;
}

-(NSData *)imageLargeData
{
//    if (!_imageLargeData) {
        //if (!_editedImageSetting.isDidEditing && _previewImage.imageOrientation == UIImageOrientationUp) {
//            return UIImagePNGRepresentation(_previewImage);
        /*} else {
            UIImage *result = [UIImage imageWithCGImage:_previewImage.CGImage scale:_previewImage.scale orientation:_previewImage.imageOrientation];
            return UIImageJPEGRepresentation(result, 0.7f);
        }*/
//    }
    
    return _imageLargeData == nil ? UIImageJPEGRepresentation(_previewImage, 0.6f) : _imageLargeData;
}

-(UIImage *)iconPreviewImage {
    if ([self.editedImageSetting isDidEditing]) {
        UIImage *preview = /*[self.editedImageSetting executeImage:*/self.previewImage/*]*/;
        UIImage *icon = [preview aspectFill:CGSizeMake(50, 50)];
        UIImage *result = [UIImage imageWithCGImage:icon.CGImage scale:icon.scale orientation:icon.imageOrientation];
        return result;
    }
    
    return _iconPreviewImage;
}

@end
