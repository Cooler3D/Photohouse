//
//  PPBaseFilter.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 18/11/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import "PPBaseFilter.h"

@implementation PPBaseFilter
+ (NSDictionary*)defaultFilterInfo
{
    NSDictionary *defaultFilterInfo = nil;
    if(defaultFilterInfo==nil){
        defaultFilterInfo =
        @{
          @"CLDefaultEmptyFilter"     : @{@"name":@"CLDefaultEmptyFilter",     @"title" : @"None",       @"version":@(0.0), @"dockedNum":@(0.0)},
          @"CLDefaultLinearFilter"    : @{@"name":@"CISRGBToneCurveToLinear",  @"title" : @"Linear",     @"version":@(7.0), @"dockedNum":@(1.0)},
          @"CLDefaultVignetteFilter"  : @{@"name":@"CIVignetteEffect",         @"title" : @"Vignette",   @"version":@(7.0), @"dockedNum":@(2.0)},
          @"CLDefaultInstantFilter"   : @{@"name":@"CIPhotoEffectInstant",     @"title" : @"Instant",    @"version":@(7.0), @"dockedNum":@(3.0)},
          @"CLDefaultProcessFilter"   : @{@"name":@"CIPhotoEffectProcess",     @"title" : @"Process",    @"version":@(7.0), @"dockedNum":@(4.0)},
          @"CLDefaultTransferFilter"  : @{@"name":@"CIPhotoEffectTransfer",    @"title" : @"Transfer",   @"version":@(7.0), @"dockedNum":@(5.0)},
          @"CLDefaultSepiaFilter"     : @{@"name":@"CISepiaTone",              @"title" : @"Sepia",      @"version":@(5.0), @"dockedNum":@(6.0)},
          @"CLDefaultChromeFilter"    : @{@"name":@"CIPhotoEffectChrome",      @"title" : @"Chrome",     @"version":@(7.0), @"dockedNum":@(7.0)},
          @"CLDefaultFadeFilter"      : @{@"name":@"CIPhotoEffectFade",        @"title" : @"Fade",       @"version":@(7.0), @"dockedNum":@(8.0)},
          @"CLDefaultCurveFilter"     : @{@"name":@"CILinearToSRGBToneCurve",  @"title" : @"Curve",      @"version":@(7.0), @"dockedNum":@(9.0)},
          @"CLDefaultTonalFilter"     : @{@"name":@"CIPhotoEffectTonal",       @"title" : @"Tonal",      @"version":@(7.0), @"dockedNum":@(10.0)},
          @"CLDefaultNoirFilter"      : @{@"name":@"CIPhotoEffectNoir",        @"title" : @"Noir",       @"version":@(7.0), @"dockedNum":@(11.0)},
          @"CLDefaultMonoFilter"      : @{@"name":@"CIPhotoEffectMono",        @"title" : @"Mono",       @"version":@(7.0), @"dockedNum":@(12.0)},
          @"CLDefaultInvertFilter"    : @{@"name":@"CIColorInvert",            @"title" : @"Invert",     @"version":@(6.0), @"dockedNum":@(13.0)},
          };
    }
    return defaultFilterInfo;
}


+(UIImage *)applyFilter:(UIImage *)image withFilterName:(NSString *)filterName {
    if (!filterName) {
        return image;
    }
    
    NSDictionary *filterProperty = [[self defaultFilterInfo] objectForKey:filterName];
    NSString *fName = [filterProperty objectForKey:@"name"];
    
    
    
    if([fName isEqualToString:@"CLDefaultEmptyFilter"]){
        return image;
    }
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:fName keysAndValues:kCIInputImageKey, ciImage, nil];
    
    //NSLog(@"%@", [filter attributes]);
    
    [filter setDefaults];
    
    if([fName isEqualToString:@"CIVignetteEffect"]){
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


+(NSArray *)allFilters {
    return [[self defaultFilterInfo] allKeys];
}
@end
