//
//  SelectAlbumImage.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 5/15/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "SelectAlbumImage.h"

#import "DrawGridView.h"


@interface SelectAlbumImage ()
@property (weak, nonatomic) id<SelectAlbumImageDelegate> delegate;
@end


@implementation SelectAlbumImage
{
    UIImage *_screenImage;
    UIImage *_selectImage;
    CGRect _selectRect; // Прямоугольник для фотографии
    CGSize _mainSize;   // размеры главного окна контроллера
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (id) initWithFrame:(CGRect)frame
   andSelecViewFrame:(CGRect)selectRect
         andMainSize:(CGSize)mainSize
      andScreenImage:(UIImage *)screenImage
      andSelectImage:(UIImage *)selectImage
           andTarget:(id)target
         andSelector:(SEL)selector
         andDelegate:(id<SelectAlbumImageDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
        [self addGestureRecognizer:gesture];
        
        _delegate = delegate;
        _screenImage = screenImage;
        _selectImage = selectImage;
        _selectRect = selectRect;
        _mainSize = mainSize;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    // Blur Screen
//    CIImage *ciimage = [[CIImage alloc] initWithImage:_screenImage];
//    
//    // Blur
//    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
//    [filter setValue:[NSNumber numberWithFloat:4.f] forKey:@"inputRadius"];
//    [filter setValue:ciimage forKey:kCIInputImageKey];
//    CIImage *result = [filter outputImage];
//    
//    // Linear RGB
//    filter = [CIFilter filterWithName:@"CIVignette"];
//    [filter setValue:[NSNumber numberWithFloat:0.9f] forKey:@"inputIntensity"];
//    [filter setValue:[NSNumber numberWithFloat:50.f] forKey:@"inputRadius"];
//    [filter setValue:result forKey:kCIInputImageKey];
//    result = [filter outputImage];
//    UIImage *final = [UIImage imageWithCIImage:result scale:_screenImage.scale orientation:UIImageOrientationRight];
    
    UIImageView *screenImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rect) - 3.f,
                                                                                 CGRectGetMinY(rect) - 3.f,
                                                                                 CGRectGetWidth(rect) + 6.f,
                                                                                 CGRectGetHeight(rect) + 6.f)];
    [screenImageView setImage:_screenImage];
    [screenImageView setAlpha:0.5f];
    [self addSubview:screenImageView];
    
    // Custom CIColorControls :)
    UIView *view = [[UIView alloc] initWithFrame:rect];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.5f];
    //[self addSubview:view];
    
    
    
    // Draw Grid
    CGFloat delta = 7.f;
    CGFloat width = CGRectGetWidth(_selectRect) + delta;
    CGFloat height = CGRectGetHeight(_selectRect) + delta;
    DrawGridView *gridView = [[DrawGridView alloc] initWithFrame:CGRectMake(0.f, 0.f, width, height)];
    UIImage *grid = gridView.gridImage;
    UIImageView *imageBack = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_selectRect) - (delta / 2),
                                                                           CGRectGetMinY(_selectRect) - (delta / 2),
                                                                           width,
                                                                           height)];
    [imageBack setImage:grid];
    [self addSubview:imageBack];
    
    // Image User
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_selectRect];
    [imageView setImage:_selectImage];
    [self addSubview:imageView];
    
    //
    [self createEditButton];
    [self createRemoveButton];
}


- (void) createEditButton
{
    CGFloat widthButton = 60.f;
    CGFloat freeWidthButton = (_mainSize.width - CGRectGetWidth(_selectRect)) / 2; // Кол-во свободного места для кнопки
    CGFloat posX = freeWidthButton > widthButton ? CGRectGetMaxX(_selectRect) + ((freeWidthButton - widthButton) / 2) : _mainSize.width - widthButton;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(posX,
                                CGRectGetMaxY(_selectRect) - widthButton,
                                widthButton,
                                widthButton)];
    [button setBackgroundImage:[UIImage imageNamed:@"editAlbumPhoto"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionEditButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}


- (void) createRemoveButton
{
    CGFloat widthButton = 60.f;
    CGFloat freeWidthButton = (_mainSize.width - CGRectGetWidth(_selectRect)) / 2; // Кол-во свободного места для кнопки
    CGFloat posX = freeWidthButton > widthButton ? ((freeWidthButton - widthButton) / 2) : CGRectGetMinX(_selectRect) - freeWidthButton;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(posX,
                                CGRectGetMaxY(_selectRect) - widthButton,
                                widthButton,
                                widthButton)];
    [button setBackgroundImage:[UIImage imageNamed:@"removeAlbumPhoto"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionRemoveButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}



#pragma mark - Action
- (void) actionEditButton:(UIButton *)sender
{
    [self.delegate selectAlbumUmage:self didEditImage:_selectImage];
}


- (void) actionRemoveButton:(UIButton *)sender
{
    [self.delegate selectAlbumUmage:self didRemoveImage:_selectImage];
}

@end
