//
//  MergeOperation.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 06/04/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "MergeOperation.h"

@implementation MergeOperation
-(void)startMergeFirstImage:(UIImage *)firstImage andSecondImage:(UIImage *)secondImage andPointOffset:(CGPoint)point andDelegate:(id<MergeOperationDelegate>)delegate
{
    self.delegate = delegate;
    [self mergeFirstImage:firstImage andSecondImage:secondImage andPointOffset:point];
}


- (void) mergeFirstImage:(UIImage *)firstImage andSecondImage:(UIImage *)secondImage andPointOffset:(CGPoint)point
{
    
    CGSize newImageSize = CGSizeMake(firstImage.size.width + secondImage.size.width,
                                     MAX(firstImage.size.height, secondImage.size.height + point.y)); //150
    
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(newImageSize);
    }
    
    [firstImage drawAtPoint:CGPointMake(0, 0)];
    [secondImage drawAtPoint:CGPointMake(firstImage.size.width, point.y)];
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate mergeOperation:self didMergeImage:image];
    //});
}
@end
