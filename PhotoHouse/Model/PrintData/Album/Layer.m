//
//  LayerImage.m
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/9/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import "Layer.h"
#import "Image.h"

@implementation Layer
- (id) initLayerDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _image = [[Image alloc] initImageDictionary:[dictionary objectForKey:@"image"]];
        
        NSArray *images = [dictionary objectForKey:@"images"];
        [self parseImage:images];
    }
    return self;
}



- (id) initWithImage:(Image *)image andImages:(NSArray *)images
{
    self = [super init];
    if (self) {
        _image = image;
        _images = images;
    }
    return self;
}


- (void) parseImage:(NSArray *)images
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *image in images) {
        Image *imageObj = [[Image alloc] initImageDictionary:image];
        [array addObject:imageObj];
    }
    
    _images = [array copy];
}

-(NSDictionary *)layerDictionary
{
    NSMutableArray *imagesDict = [NSMutableArray array];
    for (Image *image in self.images) {
        [imagesDict addObject:[image imageDictionary]];
    }
    
    NSDictionary *imageDictionary = [self.image imageDictionary];
    
    NSDictionary *dictionary = @{@"image": imageDictionary,
                                 @"images": [imagesDict copy]};
    NSLog(@"Layer.Dict:%@", dictionary);
    return dictionary;
}
@end
