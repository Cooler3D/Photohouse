//
//  Layout.m
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/9/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import "Layout.h"
#import "Image.h"
#import "Layer.h"

#import "PlaceHolder.h"


NSString *const LayoutCover = @"cover";
NSString *const LayoutPage = @"page";


@implementation Layout
- (id) initLayoutDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _id_layout = [dictionary objectForKey:@"id"];
        _template_psd = [dictionary objectForKey:@"template"];
        _layoutType = [dictionary objectForKey:@"layouttype"];
        
        
        _backLayer = [[Layer alloc] initLayerDictionary:[dictionary objectForKey:@"back"]];
        _frontLayer = [[Layer alloc] initLayerDictionary:[dictionary objectForKey:@"front"]];
        _clearLayer = [[Layer alloc] initLayerDictionary:[dictionary objectForKey:@"clear"]];
    }
    return self;
}


- (id) initLayoutWithID:(NSString *)id_layout
          andLayoutType:(NSString *)layoutType
         andtemplatePSD:(NSString *)templatePsd
           andBackLayer:(Layer *)backLayer
          andFlontLayer:(Layer *)frontLayer
          andClearLayer:(Layer *)clearLayer
           andPageIndex:(NSInteger)pageIndex andCombinedLayer:(PlaceHolder*)combinedLayer andNoscaleCombinedLayer:(CGRect)noscaleCombinedLayer
{
    self = [super init];
    if (self) {
        _id_layout      = id_layout;
        _template_psd   = templatePsd;
        _layoutType     = layoutType;
        _pageIndex      = pageIndex;
        
        
        _backLayer  = backLayer;
        _frontLayer = frontLayer;
        _clearLayer = clearLayer;
        
        _combinedLayer = combinedLayer;
        _noscaleCombinedLayer = noscaleCombinedLayer;
    }
    return self;
}


- (void) updatePageIndex:(NSInteger)pageIndex
{
    _pageIndex = pageIndex;
}



-(NSDictionary *)layoutDictionary
{
    NSDictionary *backLayerDictionary = [self.backLayer layerDictionary];
    NSDictionary *frontLayerDictionary = [self.frontLayer layerDictionary];
    NSDictionary *clearLayerDictionary = [NSDictionary  dictionary];//[self.clearLayer layerDictionary];
    NSDictionary *combinedlayerDictionary = [self.combinedLayer getDictionary];
    NSDictionary *dict = @{@"xShift"    : [NSString stringWithFormat:@"%f", CGRectGetMinX(_noscaleCombinedLayer)],
                           @"yShift"    : [NSString stringWithFormat:@"%f", CGRectGetMinY(_noscaleCombinedLayer)],
                           @"width"     : [NSString stringWithFormat:@"%f", CGRectGetWidth(_noscaleCombinedLayer)],
                           @"height"    : [NSString stringWithFormat:@"%f", CGRectGetHeight(_noscaleCombinedLayer)]};

    NSDictionary *dictionary = @{@"id"          : self.id_layout,
                                 @"layouttype"  : self.layoutType,
                                 @"template"    : self.template_psd,
                                 @"pageIndex"   : [NSString stringWithFormat:@"%li", (long)self.pageIndex],
                                 @"back"        : backLayerDictionary,
                                 @"front"       : frontLayerDictionary,
                                 @"clear"       : clearLayerDictionary,
                                 @"combinedLayer"   : combinedlayerDictionary,
                                 @"noscaleCombined" : dict};
    return dictionary;
}
@end
