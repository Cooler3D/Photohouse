//
//  MugMergeManager.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 06/04/15.
//  Copyright (c) 2015 Мартынов Дмитрий. All rights reserved.
//

#import "MugMergeManager.h"
#import "MergeOperation.h"


@interface MugMergeManager () <MergeOperationDelegate>
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *points;
@property (strong, nonatomic) UIImage *startImage;

@property (assign, nonatomic) NSInteger count;
@end


@implementation MugMergeManager

- (void) addImageFirst:(UIImage *)image
{
    self.startImage = image;
}
- (void) addSecondImage:(UIImage *)image andPoint:(CGPoint)point
{
    if (!self.images) {
        self.images = [NSMutableArray array];
        self.points = [NSMutableArray array];
    }
    
    [self.images addObject:image];
    [self.points addObject:[NSValue valueWithCGPoint:point]];
}


- (void)startMerge
{
    [self startFirstImage:self.startImage];
}

- (void) startFirstImage:(UIImage *)image
{
    UIImage *secondimage = [self.images objectAtIndex:self.count];
    CGPoint point = [[self.points objectAtIndex:self.count] CGPointValue];
    self.count++;
    MergeOperation *operation = [[MergeOperation alloc] init];
    [operation startMergeFirstImage:image andSecondImage:secondimage andPointOffset:point andDelegate:self];
}


#pragma mark - MergeOperationDelegate
-(void)mergeOperation:(MergeOperation *)operation didMergeImage:(UIImage *)image
{
    [operation setDelegate:nil];
    operation = nil;
    
    CGFloat progress = (float)_count / (float)(self.images.count-1);
    [self.delegate mugManager:self didUpdateProgress:progress];
    
//    NSLog(@"count: %i; all: %i", _count, (int)self.images.count-1);
    if (self.count == self.images.count - 1) {
        [self.delegate mugManager:self didMergedImage:image];
    } else {
        [self startFirstImage:image];
    }
    
    
}
@end
