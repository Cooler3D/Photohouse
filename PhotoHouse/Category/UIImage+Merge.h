//
//  UIImage+Merge.h
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 23/11/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Merge)
- (UIImage *) mergeImage:(UIImage *)image withAtPoint:(CGPoint)point;
@end
