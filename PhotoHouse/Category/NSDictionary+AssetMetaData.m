//
//  NSDictionary+AssetMetaData.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/4/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "NSDictionary+AssetMetaData.h"

CGFloat const kDefaultMinimalSquare = 0.2f;

@implementation NSDictionary (AssetMetaData)
- (BOOL) isAssetMedaDataMinimalSize:(CGFloat)square
{
    CGFloat maxSquare = square * 1000000.f;
    
    CGFloat imageWidth = [[self objectForKey:@"PixelWidth"] floatValue];
    CGFloat imageHeight = [[self objectForKey:@"PixelHeight"] integerValue];
    
    CGFloat imageSquare = imageHeight * imageWidth;
    
    
    return imageSquare > maxSquare ? NO : YES;
}
@end
