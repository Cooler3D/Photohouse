//
//  FilterImageManager.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 3/31/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "CLImageToolSettings.h"

#import "FilterImageManager.h"

#import "CoreDataSocialImages.h"

#import "PrintImage.h"
#import "MDPhotoLibrary.h"


@interface FilterImageManager ()
@property (strong, nonatomic) PrintImage *printImage;
@property (assign, nonatomic) NSUInteger printDataUnique;
@property (strong, nonatomic) MDPhotoLibrary *library;
@end

@implementation FilterImageManager
- (id) initWithPrintDataUnique:(NSUInteger)unique andPrintImage:(PrintImage *)printImage andDelegate:(id<FilterImageManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.printDataUnique = unique;
        self.printImage = printImage;
        self.delegate = delegate;
    }
    return self;
}


#pragma mark - Public
- (void)apply {
    ///
    MDPhotoLibrary *library = [[MDPhotoLibrary alloc] init];
    self.library = library;
    
    
    /// Блок применения фильтров
    void (^ApplyFiltersBlock)(NSData *imageLargeData, PrintImage *pImage) = ^(NSData *imageLargeData, PrintImage *pImage) {
        // Filter
        UIImage *image = [UIImage imageWithData:imageLargeData];
        
        // Contrast, Saturatuion, Brightness
        EditImageSetting *setting = pImage.editedImageSetting;
        image = [self contrastImage:image andSetting:setting];
        image = [self filteredImage:image withFilterName:setting.filterName];
        NSLog(@"Apply1.size: %@", NSStringFromCGSize(image.size));
        UIImage *result = setting.isDidEditing ? [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:setting.imageOrientation] : [image copy];
        NSLog(@"Apply2.size: %@", NSStringFromCGSize(result.size));
        
        // Сохраняем картинку
        [library saveImageToPhotoLibrary:result andImageOrientation:setting.imageOrientation withSuccessBlock:^(NSString *assetURL) {
            // Обновляем значения
            ImageLibrary changedLibrary = self.printImage.imageLibrary == ImageLibrarySocial ? ImageLibraryPhone : ImageLibraryPhone;
            [self.printImage updateUrlLibrary:assetURL andImageLibrary:changedLibrary withPrintDataUnique:self.printDataUnique];
            
            //
            if ([self.delegate respondsToSelector:@selector(filterImageManager:didApplyImage:)]) {
                [self.delegate filterImageManager:self didApplyImage:self.printImage];
            }
        } failBlock:^(NSError *error) {
            NSLog(@"FilterImageManager.Save.Error: %@", error);
        }];
    };
    
    
    // Читаем из
    if (self.printImage.imageLibrary == ImageLibraryPhone) {
        [library getAssetWithURL:self.printImage.urlLibrary withResultBlock:^(NSData *imageData, UIImageOrientation orientation) {
            ApplyFiltersBlock(imageData, self.printImage);
        } failBlock:^(NSError *error) {
            NSLog(@"FilterImageManager.GetImage.Error: %@", error);
        }];
    } else {
        CoreDataSocialImages *coreSocial = [[CoreDataSocialImages alloc] init];
        NSData *imageData = [coreSocial getImageDataWithURL:self.printImage.urlLibrary];
        ApplyFiltersBlock(imageData, self.printImage);
    }
}


- (UIImage*)applyFilter:(UIImage *)image
{
    EditImageSetting *setting = self.printImage.editedImageSetting;
    return [self filteredImage:image withFilterName:[self filterName:setting.filterName]];
}

- (UIImage*)filteredImage:(UIImage*)image withFilterName:(NSString*)filterName
{
    if([filterName isEqualToString:@"CLDefaultEmptyFilter"] || !filterName){
        return image;
    }
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    NSString *fName = [self filterName:filterName];
    CIFilter *filter = [CIFilter filterWithName:fName keysAndValues:kCIInputImageKey, ciImage, nil];
    
    //NSLog(@"%@", [filter attributes]);
    
    [filter setDefaults];
    
    if([filterName isEqualToString:@"CIVignetteEffect"]){
        // parameters for CIVignetteEffect
        CGFloat R = MIN(image.size.width, image.size.height)/2;
        CIVector *vct = [[CIVector alloc] initWithX:image.size.width/2 Y:image.size.height/2];
        [filter setValue:vct forKey:@"inputCenter"];
        [filter setValue:[NSNumber numberWithFloat:0.9] forKey:@"inputIntensity"];
        [filter setValue:[NSNumber numberWithFloat:R] forKey:@"inputRadius"];
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}



- (UIImage*)contrastImage:(UIImage*)image andSetting:(EditImageSetting *)setting
{
    // Is Default
    if (setting.contrastValue == DEFAULT_CONSTRAST &&
        setting.brightnessValue == DEFAULT_BRIGHTNESS &&
        setting.saturationValue == DEFAULT_SATURATION)
    {
        return image;
    }
    
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    [filter setValue:[NSNumber numberWithFloat:setting.saturationValue] forKey:@"inputSaturation"];
    
    filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    CGFloat brightness = 2*setting.brightnessValue;
    [filter setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputEV"];
    
    filter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    CGFloat contrast   = setting.contrastValue*setting.contrastValue;
    [filter setValue:[NSNumber numberWithFloat:contrast] forKey:@"inputPower"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}




- (NSDictionary*)defaultFilterInfo
{
    NSDictionary *defaultFilterInfo = nil;
    if(defaultFilterInfo==nil){
        defaultFilterInfo =
        @{
          @"CLDefaultEmptyFilter"     : @{@"name":@"CLDefaultEmptyFilter",     @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultEmptyFilter_DefaultTitle",    nil, [CLImageEditorTheme bundle], @"None", @""),       @"version":@(0.0), @"dockedNum":@(0.0)},
          @"CLDefaultLinearFilter"    : @{@"name":@"CISRGBToneCurveToLinear",  @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultLinearFilter_DefaultTitle",   nil, [CLImageEditorTheme bundle], @"Linear", @""),     @"version":@(7.0), @"dockedNum":@(1.0)},
          @"CLDefaultVignetteFilter"  : @{@"name":@"CIVignetteEffect",         @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultVignetteFilter_DefaultTitle", nil, [CLImageEditorTheme bundle], @"Vignette", @""),   @"version":@(7.0), @"dockedNum":@(2.0)},
          @"CLDefaultInstantFilter"   : @{@"name":@"CIPhotoEffectInstant",     @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultInstantFilter_DefaultTitle",  nil, [CLImageEditorTheme bundle], @"Instant", @""),    @"version":@(7.0), @"dockedNum":@(3.0)},
          @"CLDefaultProcessFilter"   : @{@"name":@"CIPhotoEffectProcess",     @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultProcessFilter_DefaultTitle",  nil, [CLImageEditorTheme bundle], @"Process", @""),    @"version":@(7.0), @"dockedNum":@(4.0)},
          @"CLDefaultTransferFilter"  : @{@"name":@"CIPhotoEffectTransfer",    @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultTransferFilter_DefaultTitle", nil, [CLImageEditorTheme bundle], @"Transfer", @""),   @"version":@(7.0), @"dockedNum":@(5.0)},
          @"CLDefaultSepiaFilter"     : @{@"name":@"CISepiaTone",              @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultSepiaFilter_DefaultTitle",    nil, [CLImageEditorTheme bundle], @"Sepia", @""),      @"version":@(5.0), @"dockedNum":@(6.0)},
          @"CLDefaultChromeFilter"    : @{@"name":@"CIPhotoEffectChrome",      @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultChromeFilter_DefaultTitle",   nil, [CLImageEditorTheme bundle], @"Chrome", @""),     @"version":@(7.0), @"dockedNum":@(7.0)},
          @"CLDefaultFadeFilter"      : @{@"name":@"CIPhotoEffectFade",        @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultFadeFilter_DefaultTitle",     nil, [CLImageEditorTheme bundle], @"Fade", @""),       @"version":@(7.0), @"dockedNum":@(8.0)},
          @"CLDefaultCurveFilter"     : @{@"name":@"CILinearToSRGBToneCurve",  @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultCurveFilter_DefaultTitle",    nil, [CLImageEditorTheme bundle], @"Curve", @""),      @"version":@(7.0), @"dockedNum":@(9.0)},
          @"CLDefaultTonalFilter"     : @{@"name":@"CIPhotoEffectTonal",       @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultTonalFilter_DefaultTitle",    nil, [CLImageEditorTheme bundle], @"Tonal", @""),      @"version":@(7.0), @"dockedNum":@(10.0)},
          @"CLDefaultNoirFilter"      : @{@"name":@"CIPhotoEffectNoir",        @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultNoirFilter_DefaultTitle",     nil, [CLImageEditorTheme bundle], @"Noir", @""),       @"version":@(7.0), @"dockedNum":@(11.0)},
          @"CLDefaultMonoFilter"      : @{@"name":@"CIPhotoEffectMono",        @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultMonoFilter_DefaultTitle",     nil, [CLImageEditorTheme bundle], @"Mono", @""),       @"version":@(7.0), @"dockedNum":@(12.0)},
          @"CLDefaultInvertFilter"    : @{@"name":@"CIColorInvert",            @"title":NSLocalizedStringWithDefaultValue(@"CLDefaultInvertFilter_DefaultTitle",   nil, [CLImageEditorTheme bundle], @"Invert", @""),     @"version":@(6.0), @"dockedNum":@(13.0)},
          };
    }
    return defaultFilterInfo;
}



/*! Опредеяем фильтр по имени
 *@paam name сюда приходит CLColorInver или CLVedeta 
 *@retutn нужно вернуть название фильтров для CoreImage
 */
- (NSString*)filterName:(NSString *)name
{
    NSString *final = self.defaultFilterInfo[name][@"name"];
    return final;
}

@end
