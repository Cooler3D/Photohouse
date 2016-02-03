//
//  ImageLayerView.m
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/30/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import "ImageLayerView.h"

#import "Image.h"
#import "PrintImage.h"

#import "DrawGridView.h"

typedef enum {
    DrawSelect,
    DrawRectangle
} DrawGridType;

@interface ImageLayerView()
@property (strong, nonatomic) Image *imageLayer;
@property (strong, nonatomic) PrintImage *printImage;
@end



@implementation ImageLayerView
{
    BOOL _isSelected;
    
    UIImageView *_addImageView; // Кртинка с Плюсом
    UIImageView *_mainImageView;// Основная картинка
    
    /// Нарисованный прямоугольник, и смена на выделяющийся
    DrawGridView *_selectDrawView;
}

#pragma mark - Init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id) initWithFrame:(CGRect)frame andImageLayer:(Image *)imageLayer andLayerType:(LayerType)layerType
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _imageLayer = imageLayer;
        _layertype = layerType;
        _isSelected = NO;
        
        //[self setBackgroundColor:[UIColor redColor]];
        [self showImageAdd];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //[self setBackgroundColor:[UIColor redColor]];
}
*/

#pragma mark - Get
- (BOOL) isSelected
{
    return _isSelected;
}


- (BOOL) hasImage
{
    return _mainImageView.image == nil ? NO : YES;
}



- (NSString *) urlLibrary
{
    return _imageLayer.url_image;//_printImage ? _printImage.urlLibrary : @"";
}


#pragma mark - Public
-(void)cancelSelection
{
    _isSelected = NO;
    
    if (_printImage) {
        [self removeDrawView:_selectDrawView];
    } else {
        [self drawGridView:DrawRectangle];
    }
}




- (void) setSelectPrintImage:(PrintImage *)printImage
{
    [_addImageView setHidden:YES];
    [_mainImageView setHidden:NO];
    
//    UIImage *imageCroped = [printImage cropImageWithCropSize:self.bounds.size];
//    NSLog(@"PreviewSize: %@", NSStringFromCGSize(printImage.previewImage.size));
//    NSLog(@"CropedSize: %@", NSStringFromCGSize(imageCroped.size));
//    [_mainImageView setImage:imageCroped];
//    [_imageLayer updateUrlImage:printImage.urlLibrary];
//    [_imageLayer updateCrop:printImage.editedImageSetting.cropRect];
//    [_imageLayer updateOrientation:printImage.editedImageSetting.imageOrientation];
//    
//    self.printImage = printImage;
//    
//    [self removeDrawView:_selectDrawView];
    
    [printImage cropImageWithCropSize:self.bounds.size withCompleteBlock:^(UIImage *image) {
        UIImage *imageCroped = image;
        NSLog(@"PreviewSize: %@", NSStringFromCGSize(printImage.previewImage.size));
        NSLog(@"CropedSize: %@", NSStringFromCGSize(imageCroped.size));
        [_mainImageView setImage:imageCroped];
        [_imageLayer updateUrlImage:printImage.urlLibrary];
        [_imageLayer updateCrop:printImage.editedImageSetting.cropRect];
        [_imageLayer updateOrientation:printImage.editedImageSetting.imageOrientation];
        [_imageLayer updateDefaulOrientation:printImage.editedImageSetting.imageDefaultOrientation];
    
        self.printImage = printImage;
        
        [self removeDrawView:_selectDrawView];
    }];
}



- (NSString *) removeImage
{
    [_addImageView setHidden:NO];
    [_mainImageView setImage:nil];
    [_mainImageView setHidden:YES];
    
    NSString *urlLibrary = self.printImage.urlLibrary;
    [_imageLayer updateUrlImage:nil];
    [self.printImage.editedImageSetting changeSetupDefault];
    self.printImage = nil;
    
//    NSDictionary *userInfo = @{ImageUrlLibraryKey: urlLibrary};
//    NSNotification *notification = [NSNotification notificationWithName:ImageRemoveOnPageNotification object:nil userInfo:userInfo];
    //[[NSNotificationCenter defaultCenter] postNotification:notification];
    
    [self drawGridView:DrawRectangle];
    
    return urlLibrary;
}

- (void) showImageAdd
{
    // Add Image
    UIImage *image = [UIImage imageNamed:@"addAlbumPhoto"];
    CGSize sizeImage = CGSizeMake(image.size.width / 2, image.size.height / 2);//image.size;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - sizeImage.width) / 2,
                                                                           (CGRectGetHeight(self.bounds) - sizeImage.height) / 2,
                                                                           sizeImage.width,
                                                                           sizeImage.height)];
    [imageView setImage:image];
    [imageView setUserInteractionEnabled:NO];
    _addImageView = imageView;
    [self addSubview:imageView];
    
    
    
    // Rectangle
     [self drawGridView:DrawRectangle];
    
    
    
    // Main Image
    UIImageView *mainImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [mainImageView setBackgroundColor:[UIColor grayColor]];
    [mainImageView setHidden:YES];
    [mainImageView setUserInteractionEnabled:NO];
    _mainImageView = mainImageView;
    [self addSubview:mainImageView];
}



#pragma mark - Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self hasImage])
    {
        // картинки нет, открываем выбор картинок
        CGRect bounds = self.bounds;
        NSDictionary *userInfo = @{ImagesSelectKey: [NSValue valueWithCGRect:self.frame],
                                   ImagePrintKey: self.printImage,
                                   ImageRectKey: [NSValue valueWithCGRect:bounds]};
        NSNotification *notification = [NSNotification notificationWithName:ImageSelectNotification object:nil userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    else
    {
        // Открывем картинку
        NSNotification *notification = [NSNotification notificationWithName:ImagesOpenNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        [self drawGridView:DrawSelect];
    }
    
    _isSelected = YES;
}



#pragma mark - Private
- (void) drawGridView:(DrawGridType)drawType
{
    [self removeDrawView:_selectDrawView];
    
    CGSize size = self.bounds.size;
    UIColor *color = [UIColor colorWithRed:49.f/255.f green:162.f/255.f blue:208.f/255.f alpha:1.f];
    CGFloat lineWidth = 5.f;
    
    // Draw
    if (drawType == DrawSelect) {
        DrawGridView *select = [[DrawGridView alloc] initDrawSelectImageWtihSize:size
                                                                    andColorLine:color
                                                              andStrokeLineWidth:lineWidth];
        [self addSubview:select];
        _selectDrawView = select;
    }
    else
    {
        DrawGridView *rectangle = [[DrawGridView alloc] initRectangleWithSize:size
                                                                 andColorLine:color
                                                           andStrokeLineWidth:lineWidth];
        [self addSubview:rectangle];
        _selectDrawView = rectangle;
    }
}


- (void) removeDrawView:(DrawGridView *)drawView
{
    if (drawView) {
        [drawView removeFromSuperview];
    }
}


//#pragma mark - Action
//- (void) actionRemovebutton:(UIButton *)sender
//{
//    NSNotification *notification = [NSNotification notificationWithName:ImagesRemoveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] postNotification:notification];
//}
//
//
//- (void) actionEditButton:(UIButton *)sender
//{
//    CGRect bounds = self.bounds;
//    NSDictionary *userInfo = @{ImagePrintKey: self.printImage, ImageRectKey: [NSValue valueWithCGRect:bounds]};
//    NSNotification *notifiaction = [NSNotification notificationWithName:ImagesEditNotification object:nil userInfo:userInfo];
//    [[NSNotificationCenter defaultCenter] postNotification:notifiaction];
//}

@end
