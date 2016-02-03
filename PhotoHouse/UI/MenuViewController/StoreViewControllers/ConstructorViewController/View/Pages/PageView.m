//
//  PageView.m
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/10/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import "PageView.h"

#import "ImageLayerView.h"

#import "Layout.h"
#import "Layer.h"
#import "Image.h"
//#import "Position.h"

#import "UIImage+Crop.h"

#import "PrintImage.h"


NSString *const AddPageNotification     = @"AddPageNotification";
NSString *const RemovePageNotification  = @"RemovePageNotification";

NSString *const RemovePageKey = @"RemovePageKey";



@interface PageView()
@property (strong, nonatomic) NSArray *imagesLayerViews;     // Массив с ImageLayerView
@end



@implementation PageView
{
    UIImageView * _progressImageView;
    NSInteger _pageIndex;
    
    // Потребуется для обрезания скриншота картинки
    CGRect _cropRect;
}
@synthesize layout = _layout;
@synthesize previewLayout = _previewLayout;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id) initWithFrame:(CGRect)frame andLayout:(Layout *)layout andPageIndex:(NSInteger)pageIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat offset = 42.f + 14.f + 7.f; // Ширина кнопки + отступ кнопки + отступ от кнопки на начала разворота(Дизайн)
        CGSize mainViewSize = CGSizeMake(CGRectGetWidth(frame) - (offset * 2),
                                         CGRectGetHeight(frame));
        CGRect mainViewRect = CGRectMake((CGRectGetWidth(frame) - mainViewSize.width) / 2,
                                         0.f,
                                         mainViewSize.width,
                                         mainViewSize.height);
        
        UIImage *backImage = layout.backLayer.image.image;
        NSLog(@"PageView: %@", NSStringFromCGSize(backImage.size));
        CGRect rect = [backImage insertToCenterRect:mainViewRect];
        
        [self initLayout:layout andFrame:rect andPageIndex:pageIndex];
    }
    return self;
}



- (void) initLayout:(Layout *)layout andFrame:(CGRect)frame andPageIndex:(NSInteger)pageIndex
{
    _layout = layout;
    _pageIndex = pageIndex;
    //[self setFrame:frame];
    NSLog(@"PageFrame: %@", NSStringFromCGRect(frame));
    NSLog(@"main: %@", NSStringFromCGRect(self.frame));
    
    
    // Белая подложка на лижнем слое альбома
    CGFloat offset = 6.f;
    _cropRect = CGRectMake(CGRectGetMinX(frame) - offset,
                           CGRectGetMinY(frame) - offset,
                           CGRectGetWidth(frame) + (offset * 2),
                           CGRectGetHeight(frame) + (offset * 2));
    UIImageView *back = [[UIImageView alloc] initWithFrame:_cropRect];
    [back setImage:[UIImage imageNamed:@"albumPageBackground"]];
    [self addSubview:back];
    
    
    // Back Layer
    UIImage *backImage = self.layout.backLayer.image.image;
    [self drawImage:[UIImage imageNamed:@"albumImageBackground"] andRect:frame];
    
    
    // Draw Images (ImageLayerView)
    CGSize backImageSize = backImage.size;
    CGFloat deltaFactor = CGRectGetWidth(frame) / backImageSize.width;
    CGPoint offsetPoint = CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame));
    [self createImagesWithLayer:layout.backLayer.images andDeltaFactor:deltaFactor andOffsetPoint:offsetPoint];
    [self createImagesWithLayer:layout.frontLayer.images andDeltaFactor:deltaFactor andOffsetPoint:offsetPoint];
    
    
    // Front and Clear Layer
    UIImage *frontImage = self.layout.frontLayer.image.image;
    [self drawImage:frontImage andRect:frame];
    UIImage *clearImage = self.layout.clearLayer.image.image;
    [self drawImage:clearImage andRect:frame];
    
    
    // Buttons
    [self createButtons];
    
    
    // Notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationOpenImage:) name:ImagesOpenNotification object:nil];
    [nc addObserver:self selector:@selector(notificationSelectImage:) name:ImageSelectNotification object:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:rect];
    [backImageView setImage:self.layout.backLayer.image.image];
    [self addSubview:backImageView];
}
*/

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Public
- (void) updatePageIndex:(NSInteger)pageIndex
{
    _pageIndex = pageIndex;
}

- (void)importImage:(PrintImage *)image
{
    ImageLayerView *selectLayer = [self getActionLayerImage];
    if (selectLayer) {
        [selectLayer setSelectPrintImage:image];
    }
}



- (BOOL) compaseSyncPrintImage:(PrintImage *)printImage
{
    for (ImageLayerView *imageLayerView in self.imagesLayerViews) {
        if ([imageLayerView.urlLibrary isEqualToString:printImage.urlLibrary]) {
            [imageLayerView setSelectPrintImage:printImage];
            return YES;
        }
    }
    
    return NO;
}



- (NSString *)removeImage
{
    NSString *urllibrary = @"";
    ImageLayerView *selectLayer = [self getActionLayerImage];
    if (selectLayer) {
        urllibrary = [selectLayer removeImage];
    }
    
    return urllibrary;
}



- (NSArray *) removePage
{
    NSMutableArray *urlLibrarys = [NSMutableArray array];
    
    
    for (ImageLayerView *layerImage in self.imagesLayerViews) {
        NSString *urlLibrary = layerImage.urlLibrary;
        [urlLibrarys addObject:urlLibrary];
    }
    
    for (ImageLayerView *layerImage in self.imagesLayerViews) {
        /*NSString *urlLibrary = */[layerImage removeImage];
        //[urlLibrarys addObject:urlLibrary];
    }
    
    _layout = nil;
    
    return [urlLibrarys copy];
}




#pragma mark - Get
-(NSInteger)pageIndex
{
    return _pageIndex;
}



-(CGFloat)progress
{
    // Блок поиска заполненных ImageView
    float (^ImportImagesBlock)(NSArray *imageLayers) = ^(NSArray *imageLayers) {
        NSInteger emptyCount = 0;
        
        for (ImageLayerView *imageLayer in imageLayers) {
            if (imageLayer.hasImage) {
                emptyCount++;
            }
        }
        
        return (float)emptyCount;
    };
    
    
    CGFloat importImages = ImportImagesBlock(self.imagesLayerViews);
    return importImages / self.imagesLayerViews.count;
}


-(Layout *)layout
{
    [_layout updatePageIndex:_pageIndex];
    return _layout;
}


-(UIImage *)previewLayout
{
    return [self makeScreen];
}

-(NSArray *)imagesUrls
{
    NSMutableArray *array = [NSMutableArray array];
    //
    for (ImageLayerView *imageLayer in self.imagesLayerViews) {
        if (imageLayer.hasImage) {
            [array addObject:imageLayer.urlLibrary];
        }
    }

    return [array copy];
}


#pragma mark - Action
- (void) actionAddPage:(UIButton *)sender
{
    NSDictionary *userInfo = @{RemovePageKey: [NSNumber numberWithInteger:_pageIndex]};
    NSNotification *notification = [NSNotification notificationWithName:AddPageNotification object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


- (void) actionRemovePage:(UIButton *)sender
{
    if (_pageIndex == 0) {
        return;
    }
    
    NSDictionary *userInfo = @{RemovePageKey: [NSNumber numberWithInteger:_pageIndex]};
    NSNotification *notification = [NSNotification notificationWithName:RemovePageNotification object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}



#pragma mark - Private
- (void) createButtons
{
    UIButton *remove = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize buttonSize = CGSizeMake(38.f, 38.f);
    [remove setFrame:CGRectMake(14.f,
                                CGRectGetMidY(self.bounds) - (buttonSize.height / 2),
                                buttonSize.width, buttonSize.height)];
    [remove setBackgroundImage:[UIImage imageNamed:@"removeAlbumPage"] forState:UIControlStateNormal];
    [remove addTarget:self action:@selector(actionRemovePage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:remove];
    
    
    
    // Button add
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
    [add setFrame:CGRectMake(CGRectGetWidth(self.bounds) - buttonSize.width - CGRectGetMinX(remove.frame),
                             CGRectGetMidY(self.bounds) - (buttonSize.height / 2),
                             buttonSize.width, buttonSize.height)];
    [add setBackgroundImage:[UIImage imageNamed:@"addAlbumPage"] forState:UIControlStateNormal];
    [add addTarget:self action:@selector(actionAddPage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:add];
}



- (void) drawImage:(UIImage *)image andRect:(CGRect)rect
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    [imageView setImage:image];
    [imageView setUserInteractionEnabled:NO];
    [self addSubview:imageView];
}



- (ImageLayerView *) getActionLayerImage
{
    ImageLayerView *selectLayer;
    
    for (ImageLayerView *layer in self.imagesLayerViews) {
        if ([layer isSelected]) {
            selectLayer = layer;
        }
    }
    
    return selectLayer;
}



- (UIImage *) makeScreen
{
    
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *final = [[UIImage alloc] cropImageFrom:img WithRect:_cropRect];
    UIGraphicsEndImageContext();
    
    return final;
}





#pragma mark - Notification
- (void) notificationOpenImage:(NSNotification *)notification
{
    // Deselect
    for (ImageLayerView *layer in self.imagesLayerViews) {
        [layer cancelSelection];
    }
}


- (void) notificationSelectImage:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    PrintImage *printImage = [userInfo objectForKey:ImagePrintKey];
    
    for (ImageLayerView *layer in self.imagesLayerViews) {
        // Если картинка выбранна и именя адресов библиотек не соответствуют, убираем выделение
        if (layer.isSelected && ![layer.urlLibrary isEqualToString:printImage.urlLibrary]) {
            [layer cancelSelection];
        }
    }
}




#pragma mark - Images
- (void) createImagesWithLayer:(NSArray *)images andDeltaFactor:(CGFloat)deltafactor andOffsetPoint:(CGPoint)offsetPoint
{
    NSMutableArray *imageViews = [NSMutableArray array];
    
    for (Image *image in images) {
        CGRect rect = [self getRectWithPosition:image.rect andDeltaFactor:deltafactor andOffsetPoint:offsetPoint];
        ImageLayerView *view = [[ImageLayerView alloc] initWithFrame:rect andImageLayer:image andLayerType:LayerBack];
        [self addSubview:view];
        [imageViews addObject:view];
    }
    
    if (self.imagesLayerViews) {
        [imageViews addObjectsFromArray:self.imagesLayerViews];
    }
    
    self.imagesLayerViews = [NSArray arrayWithArray:[imageViews copy]];
}



- (CGRect) getRectWithPosition:(CGRect)position andDeltaFactor:(CGFloat)deltaFactor andOffsetPoint:(CGPoint)offsetPoint
{
    CGRect rect = CGRectMake(CGRectGetMinX(position) * deltaFactor + offsetPoint.x,
                             CGRectGetMinY(position) * deltaFactor + offsetPoint.y,
                             CGRectGetWidth(position) * deltaFactor,
                             CGRectGetHeight(position) * deltaFactor);
    return rect;
}

@end
