//
//  PropStyle.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/29/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "PropStyle.h"

@implementation PropStyle
- (id) initWithStyleDictionary:(NSDictionary *)styleDictionary
{
    self = [super init];
    if (self) {
        [self parse:styleDictionary];
    }
    return self;
}


- (id) initWithStyleName:(NSString *)name andMaxCount:(NSInteger)maxCount andMinCount:(NSInteger)minCount andImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _styleName = name;
        _minCount = minCount;
        _maxCount = maxCount;
        _imagePreview = image;
    }
    return self;

}

- (void) parse:(NSDictionary *)style
{
    _styleName = [style objectForKey:@"name"];
    _minCount = [[style objectForKey:@"min"] integerValue];
    _maxCount = [[style objectForKey:@"max"] integerValue];
}


-(NSRange)rangeImages
{
    return NSMakeRange(_minCount, _maxCount - _minCount);
}
@end
