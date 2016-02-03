//
//  PPBaseContrast.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 19/11/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import "PPBaseContrast.h"

@implementation PPBaseContrast
+ (UIImage*)contrastImage:(UIImage*)image withSaturation:(CGFloat)saturation andBrightness:(CGFloat)brightness andContrast:(CGFloat)contrast
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    [filter setValue:[NSNumber numberWithFloat:saturation] forKey:@"inputSaturation"];
    
    filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    CGFloat brightnessR = 2*brightness;
    [filter setValue:[NSNumber numberWithFloat:brightnessR] forKey:@"inputEV"];
    
    filter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    CGFloat contrastR = contrast * contrast;
    [filter setValue:[NSNumber numberWithFloat:contrastR] forKey:@"inputPower"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

@end
