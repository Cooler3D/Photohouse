//
//  ItemInfoOrder.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/9/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "ItemInfoOrder.h"

@implementation ItemInfoOrder
- (id) initWithItemInfoOrder:(NSDictionary *)item_info
{
    self = [super init];
    if (self) {
        _name = [item_info objectForKey:@"name"];
        _price = [[item_info objectForKey:@"price"] integerValue];
        _descriptionOrder = [item_info objectForKey:@"description"];
        _categoryName = [item_info objectForKey:@"category_name"];
    }
    return self;
}
@end
