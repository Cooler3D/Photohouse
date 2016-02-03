//
//  PropUturn.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/27/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PropUturn.h"

@implementation PropUturn
-(id)initUturn:(NSString *)uturn andPrice:(NSInteger)price
{
    self = [super init];
    if (self)
    {
        _uturn = uturn;
        _price = price;
    }
    return self;
}
@end
