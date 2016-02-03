//
//  PlaceHolder.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/2/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PlaceHolder.h"

#import "PHRequestCommand.h"

@implementation PlaceHolder
- (id) initTemplateDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _psdPath = [dictionary objectForKey:@"psdPath"];
        _layerNum = [dictionary objectForKey:@"layerNum"];
        _pngPath = [dictionary objectForKey:@"pngPath"];
        _scalePngUrl = [NSString stringWithFormat:@"%@%@", SERVER_URL, [dictionary objectForKey:@"scaledPngUrl"]];
        
//        NSDictionary *noscaleCombinedLayerDict = [dictionary objectForKey:@"noscaleCombinedLayer"];
        CGFloat xPos = [[dictionary objectForKey:@"xShift"] floatValue];
        CGFloat yPos = [[dictionary objectForKey:@"yShift"] floatValue];
        CGFloat wPos = [[dictionary objectForKey:@"width"] floatValue];
        CGFloat hPos = [[dictionary objectForKey:@"height"] floatValue];
        _rect = CGRectMake(xPos, yPos, wPos, hPos);
    }
    return self;
}



- (id) initWithPsdPath:(NSString *)psdPath andLayerNum:(NSString *)layerNum andPngPath:(NSString *)pngPath andScalePngUrl:(NSString *)scalePngUrl andRect:(CGRect)rect
{
    self = [super init];
    if (self) {
        _psdPath = psdPath;
        _layerNum = layerNum;
        _pngPath = pngPath;
        _scalePngUrl = scalePngUrl;
        _rect = rect;
    }
    return self;
}


-(NSDictionary *)getDictionary
{
    NSDictionary *dict = @{@"psdPath"   : _psdPath ? _psdPath : @"",
                           @"layerNum"  : _layerNum,
                           @"pngPath"   : _pngPath,
                           @"xShift"    : [NSString stringWithFormat:@"%f", CGRectGetMinX(_rect)],
                           @"yShift"    : [NSString stringWithFormat:@"%f", CGRectGetMinY(_rect)],
                           @"width"     : [NSString stringWithFormat:@"%f", CGRectGetWidth(_rect)],
                           @"height"    : [NSString stringWithFormat:@"%f", CGRectGetHeight(_rect)]};
    return dict;
}
@end
