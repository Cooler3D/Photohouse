//
//  LayoutTool.m
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/28/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import "LayoutToolView.h"

#import "Layout.h"
#import "Layer.h"
#import "Image.h"


@interface LayoutToolView ()
@property (strong, nonatomic) Template *templateAlbum;
@property (strong, nonatomic) Layout *selectLayout;
@end



@implementation LayoutToolView
{
    UIImageView * _imageView;
    UIImageView * _progressImageView;

    NSUInteger _pageIndex;
    UIImage *_previewImage;
}
@synthesize hasSelected = _hasSelected;




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id) initWithFrame:(CGRect)frame andTapSelector:(SEL)tapSelector andtarget:(id)target andTemplate:(Template *)albumTemplate andSelectLayout:(Layout *)selectLayout andPageIndex:(NSUInteger)pageIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _templateAlbum = albumTemplate;
        _pageIndex = pageIndex;
        _selectLayout = selectLayout;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        // Tap
        UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:tapSelector];
        [self addGestureRecognizer:gestureTap];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    // Back
    UIImage *previewImage = _previewImage;
    UIImageView *back = [[UIImageView alloc] initWithFrame:rect];
    [back setFrame:CGRectMake(0.f, 0.f, previewImage.size.width * CGRectGetHeight(self.bounds) / previewImage.size.height, CGRectGetHeight(self.bounds))];
    [back setImage:_previewImage];
    [self addSubview:back];
    _imageView = back;
    
    
    // Progress
    CGSize imageSize = rect.size;//image.size;
    CGFloat squareSide = imageSize.height / 2;
    UIImageView *progressView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rect) - squareSide - 16.f,
                                                                              CGRectGetMinY(rect) + 2.f,
                                                                              squareSide,
                                                                              squareSide)];
    [progressView setImage:[UIImage imageNamed:@"pageToolEmpty"]];
    //[progressView setHidden:YES];
    [self addSubview:progressView];
    _progressImageView = progressView;
}






#pragma mark - Public
- (void) updatePreviewImage:(UIImage *)image
{
    if (image && _imageView) {
        [_imageView setImage:image];
        [_imageView setFrame:CGRectMake(0.f, 0.f, image.size.width * CGRectGetHeight(self.bounds) / image.size.height, CGRectGetHeight(self.bounds))];
    }
    
    if (image) {
        _previewImage = image;
    }
}



-(void)clearLayout
{
    [_imageView setImage:[UIImage imageNamed:@"layout"]];
    self.selectLayout = nil;
    
    [self removeFromSuperview];
}


- (void) updatePageIndex:(NSInteger)pageIndex
{
    _pageIndex = pageIndex;
}



- (void) setProgressImportImages:(CGFloat)progress
{
    // Если выбран стиль и данный разворот не является активным
    if (_selectLayout && !_hasSelected) {
        [_progressImageView setImage:progress > 0.9f ? [UIImage imageNamed:@"pageToolFull"] : [UIImage imageNamed:@"pageToolEmpty"]];
    }
}


#pragma mark - Get
-(Template *)getTepmpate
{
    return self.templateAlbum;
}



- (NSUInteger)pageIndex
{
    return _pageIndex;
}


-(void)setSelected:(BOOL)hasSelected
{
    _hasSelected = hasSelected;
}

-(BOOL)hasSelected
{
    return _hasSelected;
}
@end
