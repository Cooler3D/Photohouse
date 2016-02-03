//
//  MugStrategy.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 1/21/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "MugStrategy.h"

#import "Fields.h"

#import "PropSize.h"
#import "PropUturn.h"
#import "PropCover.h"
#import "PropStyle.h"
#import "PropColor.h"

#import "EllipseModel.h"


typedef void(^MugImageBlock)(NSArray *images);
typedef void(^MugProgressBlock)(CGFloat progress);

//NSString *const MUG_TYPE_COLOR = @"colored";
//NSString *const MUG_TYPE_HEART = @"heart";
//NSString *const MUG_TYPE_LATTE = @"latte";
//NSString *const MUG_TYPE_GLASS = @"glass";
//NSString *const MUG_TYPE_CHAMELEON = @"chameleon";


NSString *const UI_NAME_COLOR = @"Кружка Цветная";
NSString *const UI_NAME_HEART = @"Кружка Love";
NSString *const UI_NAME_LATTE = @"Кружка Латте";
NSString *const UI_NAME_GLASS = @"Кружка Стекло";
NSString *const UI_NAME_CHAMELEON = @"Кружка Хамелеон";


#define CATransform3DPerspective(t, x, y) (CATransform3DConcat(t, CATransform3DMake(1, 0, 0, x, 0, 1, 0, y, 0, 0, 1, 0, 0, 0, 0, 1)))
#define CATransform3DMakePerspective(x, y) (CATransform3DPerspective(CATransform3DIdentity, x, y))

CG_INLINE CATransform3D
CATransform3DMake(CGFloat m11, CGFloat m12, CGFloat m13, CGFloat m14,
				  CGFloat m21, CGFloat m22, CGFloat m23, CGFloat m24,
				  CGFloat m31, CGFloat m32, CGFloat m33, CGFloat m34,
				  CGFloat m41, CGFloat m42, CGFloat m43, CGFloat m44)
{
	CATransform3D t;
	t.m11 = m11; t.m12 = m12; t.m13 = m13; t.m14 = m14;
	t.m21 = m21; t.m22 = m22; t.m23 = m23; t.m24 = m24;
	t.m31 = m31; t.m32 = m32; t.m33 = m33; t.m34 = m34;
	t.m41 = m41; t.m42 = m42; t.m43 = m43; t.m44 = m44;
	return t;
}




@interface MugStrategy () <EllipseModelDelegate>
@property (copy, nonatomic) MugImageBlock mugImageBlock;
@property (copy, nonatomic) MugProgressBlock mugProgressBlock;
@property (strong, nonatomic) NSMutableArray *resultImages;
@end


@implementation MugStrategy
/*-(UIImage *)iconImage
{
    PropType *propType = [self.storeItem.types firstObject];
    UIImage *image;
    if ([propType.name isEqualToString:@"heart"])
    {
        image = [UIImage imageNamed:@"Mug2_128"];
    }
    else if ([propType.name isEqualToString:@"latte"])
    {
        image = [UIImage imageNamed:@"Mug1_128"];
    }
    else if ([propType.name isEqualToString:@"glass"])
    {
        image = [UIImage imageNamed:@"Mug4_128"];
    }
    else if ([propType.name isEqualToString:@"chameleon"])
    {
        image = [UIImage imageNamed:@"Mug3_128"];
    }
    else if ([propType.name isEqualToString:MUG_TYPE_COLOR])
    {
        image = [UIImage imageNamed:@"Mug_128"];
    }
    
    return image;
}*/


-(UIImage *)showcaseImage
{
    PropType *propType = [self.storeItem.types firstObject];
    NSString *path = propType.colors.count > 0 ? [NSString stringWithFormat:@"mug_%@_%@", propType.name, propType.selectPropColor.color] : [NSString stringWithFormat:@"mug_%@", propType.name];
    
    UIImage *image = [UIImage imageNamed:path];
    return image;
}


-(NSDictionary *)props
{
    PropType *propType = [self.storeItem.types firstObject];
    
    NSDictionary * dictionary;
    
    if ([propType.name isEqualToString:MUG_TYPE_GLASS] || [propType.name isEqualToString:MUG_TYPE_LATTE] || [propType.name isEqualToString:MUG_TYPE_CHAMELEON]) {
        dictionary = [NSDictionary dictionaryWithObject:propType.name forKey:@"type"];
    }
    else if ([propType.name isEqualToString:MUG_TYPE_HEART] || [propType.name isEqualToString:MUG_TYPE_COLOR]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:    propType.selectPropColor.color,          @"color",
                                                                    propType.name,                           @"type",    nil];
    }

    return dictionary;
}


-(void)createMergedImageWithPreview:(UIImage *)previewImage andCompleteBlock:(void (^)(NSArray *))completeBlock andProgressBlock:(void (^)(CGFloat))progressBlock
{
    self.mugImageBlock = completeBlock;
    self.mugProgressBlock = progressBlock;
    self.resultImages = [NSMutableArray array];
    
    PropType *propType = [self.storeItem.types firstObject];
    CupTypeFlexibleSize flex = [propType.name isEqualToString:MUG_TYPE_LATTE] ? CupTypeFlexibleLatte : CupTypeFlexibleStandart;
    
    CGFloat ratio = flex == CupTypeFlexibleStandart ? 1.76f : 1.26f;
    EllipseModel *ellipseModel = [[EllipseModel alloc] initImage:previewImage
                                                 withOrientation:CupOrientationToRight
                                                  andAspectRatio:ratio
                                               andEllipseDistort:flex];
    [ellipseModel setDelegate:self];
    [ellipseModel make];
}


#pragma mark - EllipseModelDelegate
-(void)ellipseModel:(EllipseModel *)model didCompleteRightImage:(UIImage *)rightImage andLeftImage:(UIImage *)leftImage
{
    PropType *propType = [self.storeItem.types firstObject];
    UIImage *mug = [self showcaseImage];
    
    if ([propType.name isEqualToString:MUG_TYPE_LATTE]) {
        [self makeRightLatteImage:rightImage andMugImage:mug];
        [self makeLeftLatteImage:leftImage andMugImage:mug];
    } else {
        [self makeRightImage:rightImage andMugImage:mug];
        [self makeLeftImage:leftImage andMugImage:mug];
    }
}

-(void)ellipseModel:(EllipseModel *)model didUpdateProgress:(CGFloat)progress {
    if (self.mugProgressBlock) {
        self.mugProgressBlock(progress);
    }
}



#pragma mark - Mug
- (void) makeRightImage:(UIImage *)rightImage andMugImage:(UIImage *)mugImage
{
    PropType *propType = [self.storeItem.types firstObject];
    BOOL isHeartMug = [propType.name isEqualToString:MUG_TYPE_HEART];
    
    // Кружка
    UIImage *imageMugGlass = mugImage;
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:nil];
    
    
    
    
    
    // Размеры фона
    CGSize const mugSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const mugRectForImage = CGRectMake(204 + (isHeartMug ? 28.f : 0),
                                              63,
                                              377,
                                              428 + 20.f);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(mugRectForImage) / mugSize.width,
                                          CGRectGetMinY(mugRectForImage) / mugSize.height,
                                          CGRectGetWidth(mugRectForImage)/ mugSize.width,
                                          CGRectGetHeight(mugRectForImage) / mugSize.height);
    
    
    CGRect const rectMug = CGRectMake(imageMugGlass.size.width * CGRectGetMinX(persentRect),
                                         imageMugGlass.size.height * CGRectGetMinY(persentRect),
                                         imageMugGlass.size.width * CGRectGetWidth(persentRect),
                                         imageMugGlass.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectMug) / CGRectGetHeight(rectMug);
    CGRect cropRect = [[UIImage alloc] sizeImage:rightImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:rightImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectMug];
    
    
    
    // Задний слой
    // Обычная белая футболка
    //UIImage *imageBack = [UIImage imageNamed:@"T-shirt_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageMugGlass];
    
    
    
    //
    __block UIImage *merge;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    });
    
    PrintImage *merged = [[PrintImage alloc] initMergeImage:merge withName:@"merge_mug_right" andUploadUrl:nil];
    [self addImagesToArray:self.resultImages andMergePrintImage:merged];
}


- (void) makeLeftImage:(UIImage *)leftImage andMugImage:(UIImage *)mugImage
{
    PropType *propType = [self.storeItem.types firstObject];
    BOOL isHeartMug = [propType.name isEqualToString:MUG_TYPE_HEART];
    
    // Футболка с вырезанной областью
    UIImage* imageMugGlass = [UIImage imageWithCGImage:mugImage.CGImage
                                                 scale:mugImage.scale
                                           orientation:UIImageOrientationUpMirrored];
    
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:nil];
    
    
    
    
    
    // Размеры фона
    CGSize const mugSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const mugRectForImage = CGRectMake(59 - (isHeartMug ? 27 : 0),
                                              63,
                                              377,
                                              428 + 20.f);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(mugRectForImage) / mugSize.width,
                                          CGRectGetMinY(mugRectForImage) / mugSize.height,
                                          CGRectGetWidth(mugRectForImage)/ mugSize.width,
                                          CGRectGetHeight(mugRectForImage) / mugSize.height);
    
    
    CGRect const rectMug = CGRectMake(imageMugGlass.size.width * CGRectGetMinX(persentRect),
                                         imageMugGlass.size.height * CGRectGetMinY(persentRect),
                                         imageMugGlass.size.width * CGRectGetWidth(persentRect),
                                         imageMugGlass.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectMug) / CGRectGetHeight(rectMug);
    CGRect cropRect = [[UIImage alloc] sizeImage:leftImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:leftImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectMug];
    
    
    
    // Задний слой
    // Обычная белая футболка
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageMugGlass];
    
    
    
    //
    __block UIImage *merge;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    });
    
    PrintImage *merged = [[PrintImage alloc] initMergeImage:merge withName:@"merge_mug_left" andUploadUrl:nil];
    [self addImagesToArray:self.resultImages andMergePrintImage:merged];
}



#pragma mark - Latte
- (void) makeRightLatteImage:(UIImage *)rightImage andMugImage:(UIImage *)mugImage
{
    // Кружка
    UIImage *imageMugGlass = mugImage;
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImage *top = [UIImage imageNamed:@"mug_latte_top"];
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:top];
    
    
    
    
    
    // Размеры фона
    CGSize const mugSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const mugRectForImage = CGRectMake(218 - 15.f,
                                              43 + 49.f,
                                              288 - 50.f,
                                              457);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(mugRectForImage) / mugSize.width,
                                          CGRectGetMinY(mugRectForImage) / mugSize.height,
                                          CGRectGetWidth(mugRectForImage)/ mugSize.width,
                                          CGRectGetHeight(mugRectForImage) / mugSize.height);
    
    
    CGRect const rectMug = CGRectMake(imageMugGlass.size.width * CGRectGetMinX(persentRect),
                                      imageMugGlass.size.height * CGRectGetMinY(persentRect),
                                      imageMugGlass.size.width * CGRectGetWidth(persentRect),
                                      imageMugGlass.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectMug) / CGRectGetHeight(rectMug);
    CGRect cropRect = [[UIImage alloc] sizeImage:rightImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:rightImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectMug];
    imageView.layer.transform = CATransform3DMakePerspective(0, 0.0015);
    [imageView setContentMode:UIViewContentModeScaleToFill];
    
    
    
    // Задний слой
    // Обычная белая футболка
    //UIImage *imageBack = [UIImage imageNamed:@"T-shirt_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageMugGlass];
    
    
    
    //
    __block UIImage *merge;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    });
    
    PrintImage *merged = [[PrintImage alloc] initMergeImage:merge withName:@"merge_mug_right" andUploadUrl:nil];
    [self addImagesToArray:self.resultImages andMergePrintImage:merged];
}

- (void) makeLeftLatteImage:(UIImage *)rightImage andMugImage:(UIImage *)mugImage
{
    // Кружка
    UIImage* imageMugGlass = [UIImage imageWithCGImage:mugImage.CGImage
                                                 scale:mugImage.scale
                                           orientation:UIImageOrientationUpMirrored];
    //NSLog(@"sizeTShirt: %@", NSStringFromCGSize(imageTShirtTop.size));
    UIImage *imag = [UIImage imageNamed:@"mug_latte_top"];
    UIImage *top = [UIImage imageWithCGImage:imag.CGImage
                                       scale:imag.scale
                                 orientation:UIImageOrientationUpMirrored];
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:top];
    
    
    
    
    
    // Размеры фона
    CGSize const mugSize = CGSizeMake(640, 586);
    
    // Позиция вырезенная в футболке
    CGRect const mugRectForImage = CGRectMake(218 - 15.f,
                                              43 + 49.f,
                                              288 - 50.f,
                                              457);
    
    // Процентные отношения для объкта
    CGRect const persentRect = CGRectMake(CGRectGetMinX(mugRectForImage) / mugSize.width,
                                          CGRectGetMinY(mugRectForImage) / mugSize.height,
                                          CGRectGetWidth(mugRectForImage)/ mugSize.width,
                                          CGRectGetHeight(mugRectForImage) / mugSize.height);
    
    
    CGRect const rectMug = CGRectMake(imageMugGlass.size.width * CGRectGetMinX(persentRect),
                                      imageMugGlass.size.height * CGRectGetMinY(persentRect),
                                      imageMugGlass.size.width * CGRectGetWidth(persentRect),
                                      imageMugGlass.size.height * CGRectGetHeight(persentRect));
    
    
    CGFloat aspectRatioWfromH = CGRectGetWidth(rectMug) / CGRectGetHeight(rectMug);
    CGRect cropRect = [[UIImage alloc] sizeImage:rightImage withDelitelHeight:aspectRatioWfromH];
    UIImage *cropimage = [[UIImage alloc] cropImageFrom:rightImage WithRect:cropRect];
    
    // Редактированная картинка
    // Средний слой
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cropimage];
    [imageView setFrame:rectMug];
    imageView.layer.transform = CATransform3DMakePerspective(0, 0.0015);
    [imageView setContentMode:UIViewContentModeScaleToFill];
    
    
    
    // Задний слой
    // Обычная белая футболка
    //UIImage *imageBack = [UIImage imageNamed:@"T-shirt_back"];
    UIImageView *objectImageView = [[UIImageView alloc] initWithImage:imageMugGlass];
    
    
    
    //
    __block UIImage *merge;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        merge = [[UIImage alloc] mergeImageView:imageView withLowerImageView:objectImageView andUpperImageView:shadowImageView];
    });
    
    PrintImage *merged = [[PrintImage alloc] initMergeImage:merge withName:@"merge_mug_left" andUploadUrl:nil];
    [self addImagesToArray:self.resultImages andMergePrintImage:merged];
}



#pragma mark - Result Images
- (void) addImagesToArray:(NSMutableArray *)array andMergePrintImage:(PrintImage *)printImage
{
    [array addObject:printImage];
    
    if (array.count == 2 && self.mugImageBlock) {
        self.mugImageBlock([array copy]);
    }
}

@end
