//
//  ResponseAlbumV2.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/2/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "ResponseAlbumV2.h"

#import "AlbumTemplate.h"
#import "JsonTemplateLayout.h"
#import "LayerPage.h"
#import "PlaceHolder.h"

#import "Template.h"
#import "Layout.h"
#import "Layer.h"
#import "Image.h"
//#import "Position.h"

NSString *const TemplateV2_Key = @"templates";
NSString *const LayoutsV2_Key = @"layouts";

@implementation ResponseAlbumV2
#pragma mark - Init
-(id)initWitParseData:(NSData *)data
{
    self = [super init];
    if (self) {
        [self parse:data];
    }
    return self;
}

- (void) parse:(NSData *)response {
    // Check
    NSDictionary *result = [self hasErrorResponce:response];
    if (self.error || !result) {
        NSLog(@"error: %@", self.error);
        return;
    }
    
    // Read
    NSArray *templatesDictionary = [result objectForKey:TemplateV2_Key];
    
    NSMutableArray *templates = [NSMutableArray array];
    for (NSDictionary *templateDictionary in templatesDictionary) {
        AlbumTemplate *albumTemplate = [[AlbumTemplate alloc] initTemplateDictionary:templateDictionary];
        [templates addObject:albumTemplate];
    }
    //
    self.templates = [templates copy];
//    if (self.templateBlock) {
//        self.templateBlock(self.templates);
//    }
    
    [self convertToOldTemplates:templates];
}


- (void) convertToOldTemplates:(NSArray *)albumTemplates
{
    // **************** Секция блоков (Blocks)
    /// Блок преобразования PlaceHolder -> Image. Второе значение pngBack, если есть, устанавливаем его вместо scalePngUrl. Иначе фоновые картинки в выборе разворотов пустые
    Image* (^GetImage)(PlaceHolder*, NSString*) = ^(PlaceHolder *placeHolder, NSString *pngBack) {
        NSString *url;
        if (pngBack != nil) {
            url = pngBack;
        } else {
            url = placeHolder.scalePngUrl;
        }
        
        Image *image = [[Image alloc] initWithPixelsMin:@"200000"
                                         andPixelsLimit:@"200000"
                                                   andZ:placeHolder.layerNum
                                            andUrlImage:url
                                           andUrlUpload:@""
                                           andPermanent:@"1"
                                                andRect:placeHolder.rect
                                                andCrop:CGRectZero
                                               andImage:nil andImageOrientation:UIImageOrientationUp andImageOrientationDefault:UIImageOrientationUp];
        return image;
    };
    
    
    /// Блок перобразования LayerPage -> Layer(Old)
    Layer* (^GetLayer)(LayerPage*, BOOL) = ^(LayerPage *layerPage, BOOL isBack) {
        
        // PlaceHolders
        NSMutableArray *arrayImages = [NSMutableArray array];
        for (PlaceHolder *pHolder in layerPage.placeHolders) {
            Image *image = GetImage(pHolder, nil);
            if (isBack) {
                [arrayImages addObject:image];
            }
        }
        
        Image *image = GetImage(isBack ? layerPage.underLayer : layerPage.overLayer,
                                isBack && layerPage.nameKey ? layerPage.layoutSelectPng : nil); // Проверяем может быть и обложка
        
        Layer *layer = [[Layer alloc] initWithImage:image andImages:[arrayImages copy]];
        return layer;
    };
    
    
    /// Блок преобразования LayerPage -> Lauyot
    Layout* (^GetLayout)(LayerPage*) = ^(LayerPage *layerPage){
        Layer *backLayer = GetLayer(layerPage, YES);
        Layer *frontLayer = GetLayer(layerPage, NO);
        Layer *clearLayer = nil;
        
        Layout *layout = [[Layout alloc] initLayoutWithID:!layerPage.nameKey ? LayoutCover : layerPage.nameKey
                                            andLayoutType:!layerPage.nameKey ? LayoutCover : LayoutPage
                                           andtemplatePSD:!layerPage.nameKey ? LayoutCover : layerPage.nameKey
                                             andBackLayer:backLayer
                                            andFlontLayer:frontLayer
                                            andClearLayer:clearLayer
                                             andPageIndex:0 andCombinedLayer:layerPage.combinedLayer andNoscaleCombinedLayer:layerPage.noscaleCombinedLayer];
        return layout;
    };
    
    
    
    /// Блок преобразования JsonTemplateLayout -> Layouts(Массив)
    NSArray* (^GetLayouts)(JsonTemplateLayout *) = ^(JsonTemplateLayout *jsontemplate){
        NSMutableArray *layouts = [NSMutableArray array];
        // Cover
        LayerPage *coverLayer = jsontemplate.cover;
        Layout *layout = GetLayout(coverLayer);
        [layouts addObject:layout];
        
        
        // Layouts
        for (LayerPage *pageLayout in jsontemplate.layouts) {
            Layout *layout = GetLayout(pageLayout);
            [layouts addObject:layout];
        }
        return [layouts copy];
    };
    // ****************************************
    //
    // ****************************************
    
    
    
    
    
    NSMutableArray *oldTemplates = [NSMutableArray array];
    
    //
    for (AlbumTemplate *albumTemplate in albumTemplates) {
        // Create Layouts
        JsonTemplateLayout *jsontemplate = albumTemplate.jsonTemplate;
        NSArray *layouts = GetLayouts(jsontemplate);
        
        
        
        //
        Template *template = [[Template alloc] initTemplateName:albumTemplate.styleName
                                                    andFontName:@"undefined"
                                                  andIdTemplate:@"undefined"
                                                        andSize:albumTemplate.formaSize
                                                     andLayouts:layouts];
        [oldTemplates addObject:template];
    }
    
    _oldTemplates = oldTemplates;
}

@end
