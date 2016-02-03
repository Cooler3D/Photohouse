//
//  AssetImage.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 28/10/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import "AssetImage.h"

@implementation AssetImage
-(id)initWithThumbal:(CGImageRef)image {
    self = [super init];
    if (self) {
        _thumbnail = [UIImage imageWithCGImage:image];
    }
    return self;
}
@end
