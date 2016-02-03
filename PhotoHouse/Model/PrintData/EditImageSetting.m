//
//  EditImageConfigurator.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 11/18/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "EditImageSetting.h"

#import "PPBaseFilter.h"
#import "PPBaseContrast.h"

NSString *const DEFAUL_FILTER = @"CLDefaultEmptyFilter";

CGFloat const DEFAULT_SATURATION = 1.f;
CGFloat const DEFAULT_BRIGHTNESS = 0.f;
CGFloat const DEFAULT_CONSTRAST  = 1.f;

@interface EditImageSetting ()
@property (assign, nonatomic) BOOL isEdited;
@end


@implementation EditImageSetting
@synthesize editedImageSize = _editedImageSize;

// Init
- (id) initFilterName:(NSString*)filterName
        andSaturation:(CGFloat)saturation
        andBrightness:(CGFloat)brightness
          andContrast:(CGFloat)contrast
          andCropRect:(CGRect)cropRect
     andRectToVisible:(CGRect)rectToVisible
andAutoResizingEnabled:(BOOL)autoResizeEnabled
  andImageOrientation:(UIImageOrientation) orientation
andImageDefautlOrientation:(UIImageOrientation)orientationDefault {
    
    //
    self = [super init];
    if (self) {
        //
        _filterName         = filterName;
        _saturationValue    = saturation;
        _brightnessValue    = brightness;
        _contrastValue      = contrast;
        _cropRect           = cropRect;
        _rectToVisibleEditor= rectToVisible;
        _imageOrientation   = orientation;
        _imageDefaultOrientation = orientationDefault;
        _isEdited = NO;
    }
    
    
    return self;
}




- (id) initSettingWithImage:(UIImage *)image;
{
    self = [super init];
    if (self) {
        _cropRect           = CGRectMake(0, 0, image.size.width, image.size.height);
        _rectToVisibleEditor= CGRectZero;
        _imageOrientation   = image.imageOrientation;
        _imageDefaultOrientation = image.imageOrientation;
        _isEdited = NO;
        [self changeSetupDefault];
    }
    return self;
}


-(BOOL)isDidEditing {
    if (_saturationValue == DEFAULT_SATURATION &&
        _brightnessValue == DEFAULT_BRIGHTNESS &&
        _contrastValue == DEFAULT_CONSTRAST &&
        [_filterName isEqualToString:DEFAUL_FILTER] &&
        (_imageOrientation == _imageDefaultOrientation) &&
        (CGRectEqualToRect(self.rectToVisibleEditor, CGRectZero))) {
        return NO;
    } else {
        return YES;
    }
//    return _isEdited;
}



- (void) changeSetupDefault
{
    _filterName         = DEFAUL_FILTER;
    _saturationValue    = DEFAULT_SATURATION;
    _brightnessValue    = DEFAULT_BRIGHTNESS;
    _contrastValue      = DEFAULT_CONSTRAST;
    _imageOrientation   = _imageDefaultOrientation;
    _rectToVisibleEditor = CGRectZero;
}


#pragma mark - Change
- (void) changeFilter:(NSString *)filterName
{
    _filterName = filterName;
}

// Изменяем Saturation
- (void) changeSaturation:(CGFloat)satiration
{
    _saturationValue = satiration;
}

// Изменяем Brightness
- (void) changeBrightness:(CGFloat)brightness
{
    _brightnessValue = brightness;
}

// Изменяем Contrast
- (void) changeContrast:(CGFloat)contrast
{
    _contrastValue = contrast;
}

// Изменяем CropRest
- (void) changeCropRect:(CGRect)cropRect
{
    _cropRect = cropRect;
}

// Изменяем CropVisible
- (void) changeCropVisible:(CGRect)cropVisible
{
    _rectToVisibleEditor = cropVisible;
}

// Изменяем autoResised
- (void) changeAutoResize:(BOOL)resize
{
    _isAutoResizing = resize;
}

// Изменяем Orientation
- (void) changeOrientation:(UIImageOrientation)orintation
{
    _imageOrientation = orintation;
}

-(void)changeOrientationDefault:(UIImageOrientation)orintationDefault {
    _imageDefaultOrientation = orintationDefault;
}

-(void)changeEditedImageSize:(CGSize)size {
    _editedImageSize = size;
}

-(UIImage *)executeImage:(UIImage *)image {
    if (![self isDidEditing]) {
        return image;
    }
    
    // Сначали фильтры
    UIImage *filtredImage = [PPBaseFilter applyFilter:image withFilterName:_filterName];
    
    // Контрасты
    UIImage *contrasted = [PPBaseContrast contrastImage:filtredImage withSaturation:_saturationValue andBrightness:_brightnessValue andContrast:_contrastValue];
    
    // Вращение
    UIImage *result = [UIImage imageWithCGImage:contrasted.CGImage scale:contrasted.scale orientation:_imageOrientation];
    return result;
}

-(void)executeImage:(UIImage *)image withCompleteBlock:(void (^)(UIImage *))completeBlock {
    // Если картинка оригинальная
    if (![self isDidEditing]) {
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(image);
            });
        }
    }
    
    
    // Apply
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Сначали фильтры
        UIImage *filtredImage = [PPBaseFilter applyFilter:image withFilterName:_filterName];
        
        // Контрасты
        UIImage *contrasted = [PPBaseContrast contrastImage:filtredImage withSaturation:_saturationValue andBrightness:_brightnessValue andContrast:_contrastValue];
        
        // Вращение
        UIImage *result = [UIImage imageWithCGImage:contrasted.CGImage scale:contrasted.scale orientation:_imageOrientation];
        
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(result);
            });

        }
    });
}


#pragma mark - Property
-(CGSize)editedImageSize {
    if (CGSizeEqualToSize(_editedImageSize, CGSizeZero)) {
        _editedImageSize = CGSizeMake(CGRectGetMinX(_cropRect) + CGRectGetWidth(_cropRect),
                                      CGRectGetMinY(_cropRect) + CGRectGetHeight(_cropRect));
    }
    
    return _editedImageSize;
}

-(void)imageDidEdided {
    _isEdited = YES;
}

- (void)clearEdited {
    _isEdited = NO;
}


@end
