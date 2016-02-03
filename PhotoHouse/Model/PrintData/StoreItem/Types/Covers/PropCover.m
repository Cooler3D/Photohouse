//
//  PropCover.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/27/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PropCover.h"

@implementation PropCover
-(id)initCover:(NSString *)cover andPrice:(NSInteger)price
{
    self = [super init];
    if (self)
    {
        _cover = cover;
        _price = price;
    }
    return self;
}

@end
