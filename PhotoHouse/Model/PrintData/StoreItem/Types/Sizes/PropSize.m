//
//  PropSize.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/27/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PropSize.h"

@implementation PropSize
- (id) initSize:(NSString *)size andPrice:(NSInteger)price
{
    self = [super init];
    if (self)
    {
        _sizeName = size;
        _price = price;
    }
    return self;
}
//
//
//- (void) parseDictionary:(NSDictionary *)sizeDictionary
//{
//    for (NSString *key in [sizeDictionary allKeys]) {
//        _size = key;
//        _price = [[sizeDictionary objectForKey:key] integerValue];
//    }
//}
@end
