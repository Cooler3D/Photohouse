//
//  JsonTemplateLayout.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/2/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "JsonTemplateLayout.h"

#import "LayerPage.h"

@implementation JsonTemplateLayout
- (id) initTemplateDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        [self parse:dictionary];
    }
    return self;
}


- (void) parse:(NSDictionary *)dictionary
{
    // Cover
    NSDictionary *coverDictionary = [dictionary objectForKey:@"cover"];
    _cover = [[LayerPage alloc] initTemplateDictionary:coverDictionary];
    
    // Layout
    NSMutableArray *layouts = [NSMutableArray array];
    NSArray *layoutObjects = [dictionary objectForKey:@"layout"];
    for (NSDictionary *layoutDictionary in layoutObjects) {
//        NSDictionary *layoutDictionary = [layout objectForKey:key];
        NSString *layout_id = [layoutDictionary objectForKey:@"layout_id"];
        LayerPage *layerLayout = [[LayerPage alloc] initTemplateDictionary:layoutDictionary andNameKey:layout_id];
        [layouts addObject:layerLayout];
    }
    _layouts = [layouts copy];
    
    
    // styleThumbal
    NSDictionary *layoutSelect = [dictionary objectForKey:@"style_thumbnail"];
    _styleThumbalUrl = [layoutSelect objectForKey:@"scaledPngUrl"];
    
    
    // storeThumbal
    NSDictionary *storeThumbalDict = [dictionary objectForKey:@"store_thumbnail"];
    _storeThumbalUrl = [storeThumbalDict objectForKey:@"scaledPngUrl"];
}

@end
