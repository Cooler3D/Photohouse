//
//  PropColor.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/9/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PropColor.h"

@implementation PropColor
- (id) initColor:(NSString *)color andPrice:(NSInteger)price
{
    self = [super init];
    if (self)
    {
        _color = color;
        _price = price;
    }
    return self;
}
@end
