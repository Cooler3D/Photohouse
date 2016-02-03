//
//  AlbumTemplate.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 7/2/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "AlbumTemplate.h"
#import "JsonTemplateLayout.h"

@implementation AlbumTemplate
- (id) initTemplateDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _styleName   = [dictionary objectForKey:@"style"];
        _formaSize   = [dictionary objectForKey:@"format"];
        
        NSDictionary *jsonDictionary = [dictionary objectForKey:@"data"];
        _jsonTemplate = [[JsonTemplateLayout alloc] initTemplateDictionary:jsonDictionary];
    }
    return self;
}

@end
