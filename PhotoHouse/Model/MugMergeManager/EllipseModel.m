//
//  EllipseModel.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/24/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "EllipseModel.h"

#import "UIImage+Crop.h"

#import "MugMergeManager.h"

@interface EllipseModel () <MugMergeManagerDelegate>
@property (strong, nonatomic) UIImage *originalImage;
@property (assign, nonatomic) CGFloat aspect_ratio;

@property (strong, nonatomic) NSMutableArray *imagesArray;

@property (assign, nonatomic) NSInteger imageCountInteration;

@property (assign, nonatomic) CupTypeFlexibleSize flexibleCupSize;

@property (assign, nonatomic) CupOrientation cupOrienttation;

@property (strong, nonatomic) UIImage *finalRightImage;
@property (strong, nonatomic) UIImage *finalLeftImage;
@end




@implementation EllipseModel
- (id) initImage:(UIImage*)image withOrientation:(CupOrientation)cupOrientation andAspectRatio:(CGFloat)ratio andEllipseDistort:(CupTypeFlexibleSize)distort {
    self = [super init];
    
    if (self) {
        self.flexibleCupSize = distort;
        //[self makeImage:image withOrientation:cupOrientation andAspectRatio:ratio];
        self.cupOrienttation = cupOrientation;
        self.originalImage = image;
        self.aspect_ratio = ratio;
    }
    
    return self;
}


-(void)make
{
    [self makeImage:self.originalImage withOrientation:self.cupOrienttation andAspectRatio:self.aspect_ratio];
}


#pragma mark - Private
- (void) makeImage:(UIImage*)imageOriginal withOrientation:(CupOrientation)cupOrientation andAspectRatio:(CGFloat)ratio {
    
    self.imagesArray = [NSMutableArray array];
    
    NSUInteger headerSize = self.flexibleCupSize == CupTypeFlexibleLatte ? 576 : 754;
    
    CGFloat delta = 2;
    //UIImage *imageOriginal = self.skewView.image;//[UIImage imageNamed:@"abs.jpg"];
    //NSLog(@"size.Original: %@", NSStringFromCGSize(imageOriginal.size));//
    // Изменяем размеры кружки
    CGSize sizeResized = CGSizeMake(headerSize, (headerSize*imageOriginal.size.height) / imageOriginal.size.width);
    //UIImage *imageResized = [[UIImage alloc] scaledImage:imageOriginal scaledToSize:sizeResized]; //760
    UIImage *imageResized = [imageOriginal scaledImageToSize:sizeResized];
    //NSLog(@"size.Resized: %@", NSStringFromCGSize(imageResized.size));
    //[self.skewView setImage:imageResized];
    
    UIImage *imageRect = [self imageWithImage:imageResized cutToRect:CGRectMake(0, 0, headerSize, (headerSize / ratio))];
    //NSLog(@"imgRect: %@", NSStringFromCGSize(imageRect.size));
    
    self.imageCountInteration = imageResized.size.width / delta;
    
    
    // Откуда считаем
    NSInteger offsetX;
    switch (cupOrientation) {
        case CupOrientationToLeft:
            offsetX = imageRect.size.width / 2;
            break;
            
        case CupOrientationToRight:
            offsetX = 0;
            break;
    }
    
    
    // Add Sub
    for (int i=0; i<self.imageCountInteration / 2; i++) { // 300
        NSInteger width = delta;
        NSInteger height = imageRect.size.height;
        
        CGRect rect = CGRectMake(i*width + offsetX,
                                 0,
                                 width, height);
        //NSLog(@"Rect: %@; i: %i", NSStringFromCGRect(rect), i);
        
        UIImage *image = [self imageWithImage:imageRect cutToRect:rect];//[self getSubImageFrom:imageRect WithRect:rect];
        
        [self.imagesArray addObject:image];
    }
    
    
    
    NSInteger current = 0;
    MugMergeManager *manager = [[MugMergeManager alloc] init];
    [manager setDelegate:self];
    // Преобразуем в одну фотку
    for (int i=0; i<[self.imagesArray count]; i++) {
        UIImage *imageFirst = [self.imagesArray objectAtIndex:i];
        
        NSInteger yPos = [self ellipsePositionWithX:current];
        CGPoint point = CGPointMake(2*i, yPos); // 170
        
        if (i == 159) {
            NSLog(@"");
        }
        
        if (i == 0) {
            //[[EllipseImage sharedManager] setFinalImage:imageFirst];
            [manager addImageFirst:imageFirst];
        } else {
            /*PhotoEllipseRecord *record = [[PhotoEllipseRecord alloc] init];
            [record setSecondImage:imageFirst];
            [self startImageDownloadingForRecord:record atIndexPath:point];*/
            [manager addSecondImage:imageFirst andPoint:point];
        }
        
        current += delta;
    }
    
    [manager startMerge];
}




- (NSInteger) ellipsePositionWithX:(NSInteger)xPos {
    NSInteger a = self.imageCountInteration / 2;//1365;//self.imageCountInteration / 2;
    NSInteger b = self.flexibleCupSize;//30;//50;//273;//51;//self.imageCountInteration / 6;
    
    //NSInteger r = self.imageCountInteration / 2;
    
    //double symma = (r*r) - ((xPos-r)*(xPos-r));
    //CGFloat symma = (b*b) -  ((b*b*(xPos-a)*(xPos-a))/(a*a));
    float minus = (float)((xPos-a)*(xPos-a)) / (float)(a*a);
    CGFloat symma = 1 - minus;//((xPos*xPos)/(a*a));
    //double symma = (b*b) -  ((b*b*xPos*xPos)/(a*a));
    
    
    CGFloat yPos = b * sqrtf(symma);//sqrt(symma);
    
    //NSLog(@"symma: %li; i: %ld; y: %f",(long)symma, (long)xPos, yPos);
    
    return yPos;
}




#pragma mark - Images
// Cut Image with Rect
- (UIImage*) imageWithImage:(UIImage*)img cutToRect:(CGRect)rect {
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [img drawInRect:drawRect];
    
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}



#pragma mark - MugMergeManagerDelegate
-(void)mugManager:(MugMergeManager *)manager didMergedImage:(UIImage *)image
{
    if (!self.finalRightImage) {
        self.imagesArray = nil;
        self.finalRightImage = image;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self makeImage:self.originalImage withOrientation:CupOrientationToLeft andAspectRatio:self.aspect_ratio];
        });
        
    }
    else {
        if ([self.delegate respondsToSelector:@selector(ellipseModel:didCompleteRightImage:andLeftImage:)]) {
            [self.delegate ellipseModel:self didCompleteRightImage:self.finalRightImage andLeftImage:image];
        }
    }
}

-(void)mugManager:(MugMergeManager *)manager didUpdateProgress:(CGFloat)progress {
    if ([self.delegate respondsToSelector:@selector(ellipseModel:didUpdateProgress:)]) {
        CGFloat uProgress = self.finalRightImage ? 0.5f + (progress / 2) : (progress / 2);
//        NSLog(@"All.Progress: %f", uProgress);
        [self.delegate ellipseModel:self didUpdateProgress:uProgress];
    }
}

@end
