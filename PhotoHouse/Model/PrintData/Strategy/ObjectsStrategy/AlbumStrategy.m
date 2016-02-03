//
//  AlbumStrategy.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/11/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "AlbumStrategy.h"

#import "PropSize.h"
#import "PropUturn.h"
#import "PropCover.h"
#import "PropStyle.h"
#import "PropColor.h"

@implementation AlbumStrategy
-(UIImage *)iconImage
{
    PropType *propType = [self.storeItem.types firstObject];
    UIImage *image;
    if ([propType.name isEqualToString:@"square"])
    {
        image = [UIImage imageNamed:@"book2_128"];
    }
    else if ([propType.name isEqualToString:@"rectangle"])
    {
        image = [UIImage imageNamed:@"book1_128"];
    }
    
    return image;
}


-(NSDictionary *)props
{
    PropType *propType = [self.storeItem.types firstObject];
    
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:  propType.selectPropSize.sizeName,            @"size",
                                                                             propType.selectPropUturn.uturn,          @"uturn",
                                                                             propType.selectPropCover.cover,          @"cover",
                                                                             propType.selectPropStyle.styleName,      @"style",
                                                                             propType.name,                           @"type",    nil];
    return dictionary;
}

/*-(NSArray *)createAndAddMergedImage:(UIImage *)previewImage
{
    PrintImage *merged = [[PrintImage alloc] initMergeImage:previewImage withName:@"merge_album"];
    return [NSArray arrayWithObject:merged];
}*/
@end
