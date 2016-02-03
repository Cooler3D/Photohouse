//
//  LayerPage.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/2/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "LayerPage.h"

#import "PlaceHolder.h"

#import "PHRequestCommand.h"

@implementation LayerPage
- (id) initTemplateDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        [self parseDictionary:dictionary];
    }
    return self;
}



- (id) initTemplateDictionary:(NSDictionary *)dictionary andNameKey:(NSString *)nameKey
{
    self = [super init];
    if (self) {
        _nameKey = nameKey;
        [self parseDictionary:dictionary];
    }
    return self;
}

- (void) parseDictionary:(NSDictionary *)dictionary
{
    // PlaceHolders
    NSArray *placeHoldersDicts = [dictionary objectForKey:@"placeholders"];
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *placeHolderObj in placeHoldersDicts) {
        PlaceHolder *pHolder = [[PlaceHolder alloc] initTemplateDictionary:placeHolderObj];
        [result addObject:pHolder];
    }
    _placeHolders = [result copy];
    
    
    // combinedLayer
    NSDictionary *combinedLayerDictionary = [dictionary objectForKey:@"combinedLayer"];
    _combinedLayer = [[PlaceHolder alloc] initTemplateDictionary:combinedLayerDictionary];
    
    
    // underLayer
    NSDictionary *underLayerDictionary = [dictionary objectForKey:@"underLayer"];
    _underLayer = [[PlaceHolder alloc] initTemplateDictionary:underLayerDictionary];
    
    // overLayer
    NSDictionary *overLayerDictionary = [dictionary objectForKey:@"overLayer"];
    _overLayer = [[PlaceHolder alloc] initTemplateDictionary:overLayerDictionary];
    
    // noscaleCombinedLayer
    NSDictionary *noscaleCombinedLayerDict = [dictionary objectForKey:@"noscaleCombinedLayer"];
    CGFloat xPos = [[noscaleCombinedLayerDict objectForKey:@"xShift"] floatValue];
    CGFloat yPos = [[noscaleCombinedLayerDict objectForKey:@"yShift"] floatValue];
    CGFloat wPos = [[noscaleCombinedLayerDict objectForKey:@"width"] floatValue];
    CGFloat hPos = [[noscaleCombinedLayerDict objectForKey:@"height"] floatValue];
    _noscaleCombinedLayer = CGRectMake(xPos, yPos, wPos, hPos);
    
    // layout-selects
    NSDictionary *layoutSelectsDict = [dictionary objectForKey:@"layout_selects"];
    _layoutSelectPng = [NSString stringWithFormat:@"%@%@", SERVER_URL, [layoutSelectsDict objectForKey:@"scaledPngUrl"]];
}

@end
