//
//  EditPhotoConstructorViewController.m
//  PhotoHouse
//
//  Created by Мартынов Дмитрий on 27/10/15.
//  Copyright © 2015 Мартынов Дмитрий. All rights reserved.
//

#import "EditPhotoConstructorViewController.h"

#import "ContrastToolBarView.h"

#import "PrintImage.h"
#import "EditImageSetting.h"

#import "UIImage+Crop.h"
#import "UIImage+Grid.h"

#import "DrawGridView.h"

#import "SkinModel.h"


/// Блок обрезки фотографии
typedef void (^CompleteBlock)(PrintImage *printImage, EditImageSetting *imageSetting);


@interface EditPhotoConstructorViewController () <UIScrollViewDelegate, ContrastFiltersDelegate>
@property (strong, nonatomic) ContrastToolBarView *contrastToolView;
@property (strong, nonatomic) PrintImage *printImage;
@property (assign, nonatomic) CGFloat aspect_ratio;
@property (copy, nonatomic) CompleteBlock completeBlock;

@property (weak, nonatomic) UIScrollView *scroll;

@property (strong, nonatomic) NSArray *constraitMenuH;
@property (strong, nonatomic) NSArray *constraitMenuV;

@property (strong, nonatomic) UIImage *editedImage;
@property (assign, nonatomic) UIImageOrientation editedImageOrientation;
@end



@implementation EditPhotoConstructorViewController

#pragma mark - Init

- (id)initPrintImage:(PrintImage *)printImage andAspect_ratio:(CGFloat)aspect_ratio andCompleteBlock:(void(^)(PrintImage *printImage, EditImageSetting *imageSetting))completeBlock {
    self = [super init];
    if (self) {
        self.completeBlock = completeBlock;
        self.printImage = printImage;
        self.aspect_ratio = aspect_ratio;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[[SkinModel sharedManager] headerColorWithViewController]];
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    //[self.navigationController.navigationBar setTranslucent:NO];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(@"Редактор", nil)];
    
    // Crop
//    CGFloat const toolBarHeight = 114.f;
    CGFloat const headerHeight = 64.f;
    
    CGSize sizeScreen = CGSizeMake(MAX(CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame)), MIN(CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame)));
    CGSize sizeView = CGSizeMake(sizeScreen.width - 20.f,
                                 sizeScreen.height - headerHeight);
    
    CGRect insertRect = [[UIImage alloc] insertSizeView:sizeView withAspectRatio:self.aspect_ratio];
    CGFloat width = CGRectGetWidth(insertRect);
    CGFloat height = CGRectGetHeight(insertRect);
    
    DrawGridView *gridView = [[DrawGridView alloc] initWithFrame:CGRectMake(0.f, 0.f, width, height)];
    UIImage *gridImage = gridView.gridImage;
//    NSLog(@"GridImage: %@", NSStringFromCGSize(gridImage.size));
//    NSLog(@"Preview: %@", NSStringFromCGSize(self.printImage.previewImage.size));
    CGRect rectContent = CGRectMake((sizeView.width - gridImage.size.width) / 2,
                                     headerHeight,
                                     CGRectGetWidth(insertRect),
                                     CGRectGetHeight(insertRect));
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:rectContent];
//    [scroll setBackgroundColor:[UIColor redColor]];
    [scroll setMaximumZoomScale:2.f];
    [scroll setMinimumZoomScale:1.f];
    [scroll setDelegate:self];
    [scroll setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.view addSubview:scroll];
    self.scroll = scroll;
    
    
//    CGRect rectCrop = [[UIImage alloc] sizeImage:self.printImage.previewImage withDelitelHeight:self.aspect_ratio];
//    CGSize scaledSize = [self getSizeImageRectWithGridSize:rectContent.size andRectCrop:rectCrop andPreviewSize:self.printImage.previewImage.size];
//    CGRect scrollRect = [self getScrollRectWithGridSize:rectContent.size andSizeImage:scaledSize];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
//    [imageView setImage:self.printImage.previewImage];
//    [scroll addSubview:imageView];
    [self addImageViewOnScroll:scroll withImage:self.printImage.previewImage];
    
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [scroll setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
//        [scroll setContentSize:scaledSize];
//        [scroll scrollRectToVisible:[self.printImage.editedImageSetting isDidEditing] ? self.printImage.editedImageSetting.rectToVisibleEditor : scrollRect animated:YES];
//    });


    UIImageView *crop = [[UIImageView alloc] initWithFrame:rectContent];
    [crop setAlpha:0.5f];
    [crop setImage:gridImage];
    [self.view addSubview:crop];
    
    
    
    /// ContrastToolBar
    ContrastToolBarView *contrastToolView = [[[NSBundle mainBundle] loadNibNamed:@"ContrastToolBarView" owner:self options:nil] firstObject];
    [contrastToolView setOriginalImage:self.printImage.previewImage];
    [contrastToolView setDelegate:self];
    [contrastToolView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:contrastToolView];
    self.contrastToolView = contrastToolView;
    
    NSArray *constraitH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contrastView]|" options:0 metrics:@{} views:@{@"contrastView":contrastToolView}];
    NSArray *constraitV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[contrastView]|" options:0 metrics:@{} views:@{@"contrastView":contrastToolView}];
    [self.view addConstraints:constraitH];
    [self.view addConstraints:constraitV];
    
    
    /// MenuButton
    UIButton *menuButton = [UIButton new];
    [menuButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"ic_editor_menu"] forState:UIControlStateNormal];
//    [menuButton setBackgroundColor:[UIColor blackColor]];
    [menuButton addTarget:self action:@selector(actionMenuButton:) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setTag:1];
    [self.view addSubview:menuButton];
    
    NSArray *constraitMenuH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[menu(24)]-10-|" options:0 metrics:@{} views:@{@"menu": menuButton}];
    NSArray *constraitMenuV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[menu(24)]-10-[contrast]|" options:0 metrics:@{} views:@{@"menu": menuButton, @"contrast": contrastToolView}];
    [self.view addConstraints:constraitMenuH];
    [self.view addConstraints:constraitMenuV];
    self.constraitMenuH = constraitMenuH;
    self.constraitMenuV = constraitMenuV;
    
    _editedImage = [self.printImage.previewImage copy];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self actionMenuButton:menuButton];
    });
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self createControllButton];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(BOOL)shouldAutorotate {
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}



#pragma mark - UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    for (UIImageView *imageView in scrollView.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            return imageView;
        }
    }
    
    return nil;
}

#pragma mark - Positions
- (CGSize) getSizeImageRectWithGridSize:(CGSize)gridSize andRectCrop:(CGRect)cropRect andPreviewSize:(CGSize)previewImageSize {
    CGSize size;
    if ((int)previewImageSize.height == (int)CGRectGetHeight(cropRect)) {
        CGFloat zoom = previewImageSize.height / gridSize.height;
        size = CGSizeMake(previewImageSize.width / zoom, gridSize.height);
    } else if ((int)previewImageSize.width == (int)CGRectGetWidth(cropRect)) {
        CGFloat zoom = previewImageSize.width / gridSize.width;
        size = CGSizeMake(gridSize.width, previewImageSize.height / zoom);
    } else {
        NSLog(@"OK");
        CGFloat zoom = previewImageSize.height / previewImageSize.width;
        size = CGSizeMake(gridSize.width, gridSize.width * zoom);
    }
    
//    CGRect rect;
//    if (size.width > gridSize.width) {
//        rect = CGRectMake(size.width - gridSize.width / 2, 0, gridSize.width, gridSize.height);
//    } else {
//        rect = CGRectMake(0, size.width > gridSize.width / 2, gridSize.width, gridSize.height);
//    }
    
    return size;
}


- (CGRect) getScrollRectWithGridSize:(CGSize)gridSize andSizeImage:(CGSize)size {
    CGRect rect;
    if (size.width > gridSize.width) {
        rect = CGRectMake((size.width - gridSize.width) / 2, 0, gridSize.width, gridSize.height);
    } else {
        rect = CGRectMake(0, (size.height - gridSize.height) / 2, gridSize.width, gridSize.height);
    }
    
    return rect;
}


#pragma mark - Methods
- (void) createControllButton {
    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStylePlain target:self action:@selector(actionOkButton:)];
    [self.navigationItem setRightBarButtonItem:okButton];
    
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(actionCancelButton:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}


- (void) addImageViewOnScroll:(UIScrollView*)scroll withImage:(UIImage *)image {
//    NSLog(@"imageSize: %@", NSStringFromCGSize(image.size));
//    NSLog(@"Scroll.Frame: %@", NSStringFromCGRect(scroll.frame));
    NSLog(@"****Editor******");
    NSLog(@"AspectRetio: %f", self.aspect_ratio);
    CGRect rectCrop = [[UIImage alloc] sizeImage:image withDelitelHeight:self.aspect_ratio];
//    NSLog(@"RectCrop: %@", NSStringFromCGRect(rectCrop));
    
    CGSize scaledSize = [self getSizeImageRectWithGridSize:scroll.frame.size andRectCrop:rectCrop andPreviewSize:image.size/*self.printImage.previewImage.size*/];
    NSLog(@"Scroll.contentSize: %@", NSStringFromCGSize(scaledSize));
    CGRect scrollRect = [self getScrollRectWithGridSize:scroll.frame.size andSizeImage:scaledSize];
//    NSLog(@"ScrollRect: %@", NSStringFromCGRect(scrollRect));
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
        [imageView setImage:image];
        [scroll addSubview:imageView];
    });
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [scroll setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        [scroll setContentSize:scaledSize];
        [scroll scrollRectToVisible:[self.printImage.editedImageSetting isDidEditing] ? self.printImage.editedImageSetting.rectToVisibleEditor : scrollRect animated:YES];
    });
}



#pragma mark - ContrastFiltersDelegate
/*-(void)contrastToolDidSlizeOpened:(ContrastToolBarView *)contrastTool andIsOpedContrasts:(BOOL)isOpen {
 //
 self.isMoveImageView = NO;
 
 // Contrast Tool
 if (!isOpen) {
 [self.contrastToolView setOriginalImage:self.editedImage];
 }
 }*/



-(void)contrastToolDidChangeImage:(UIImage *)image {
    //NSLog(@"Edit.didSlizeChange: %@", NSStringFromCGSize(image.size));
//    self.originalImageSize = image.size;
//    
//    CGSize imageSize = image.size;
//    CGFloat oldWidth = CGRectGetWidth(self.photoImageView.frame);
//    [self.photoImageView setFrame:CGRectMake(CGRectGetMinX(self.photoImageView.frame),
//                                             CGRectGetMinY(self.photoImageView.frame),
//                                             oldWidth,
//                                             oldWidth * imageSize.height / imageSize.width)];
//    [self.photoImageView setImage:image];
//    
//    self.editedImage = image;
//    
//    //
//    [self checkImageCoordinate];
    
    _editedImage = nil;
    
    for (UIImageView *imageView in self.scroll.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            [imageView setImage:image];
        }
    }
}

-(void)contractTool:(ContrastToolBarView *)contrastTool didUpdateProgressShow:(BOOL)isShow {
    /*if (isShow) {
     if (!self.hud) {
     self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
     [self.hud setMode:MBProgressHUDModeIndeterminate];
     [self.hud setLabelText:@"Обработка"];
     }
     } else {
     [self.hud hide:YES];
     self.hud = nil;
     }*/
}

-(void)contrastTool:(ContrastToolBarView *)contrastTool didChangeOrientation:(UIImageOrientation)orientation andFinalImage:(UIImage *)image {
    NSLog(@"Orientation");
    
    _editedImage = nil;
    
    for (UIImageView *imageView in self.scroll.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            [imageView removeFromSuperview];
        }
    }
    
    [self addImageViewOnScroll:self.scroll withImage:image];
}




#pragma mark - Action
- (void) actionOkButton:(UIBarButtonItem *)sender {
    
    CGSize originalSize = [self.printImage calculateOriginalSizeWithOrientation:self.editedImageOrientation];
    [self.printImage updateOriginalSize:originalSize];
    NSLog(@"\nFinal.Result.Size: %@", NSStringFromCGSize(self.printImage.originalImageSize));
    
    CGFloat imageWidth = originalSize.width;
    CGFloat zoom = imageWidth / self.scroll.contentSize.width;
    CGPoint contentOffset = self.scroll.contentOffset;
    CGSize scrollSize = self.scroll.frame.size;
//    CGRect originalRect = CGRectMake(contentOffset.x * zoom,
//                                     contentOffset.y * zoom,
//                                     CGRectGetWidth(self.scroll.frame) * zoom,
//                                     CGRectGetHeight(self.scroll.frame) * zoom);
//    NSLog(@"Rect: %@", NSStringFromCGRect(originalRect));
//    CGSize standartSize = self.printImage.originalImageSize;
//    CGSize InvertSize = CGSizeMake(self.printImage.originalImageSize.height, self.printImage.originalImageSize.width);
//    CGSize originalSize = OriginalSizeBlock(self.printImage, self.editedImageOrientation);
    CGRect oRect = [[UIImage alloc] insertSizeView:originalSize withAspectRatio:self.aspect_ratio];
    
    NSLog(@"Rect: %@", NSStringFromCGRect(oRect));
    NSLog(@"Scroll.frame: %@", NSStringFromCGSize(self.scroll.frame.size));
    NSLog(@"Scroll.contentOffset: %@", NSStringFromCGPoint(self.scroll.contentOffset));
    NSLog(@"Scroll.contentSize: %@", NSStringFromCGSize(self.scroll.contentSize));
    NSLog(@"ImagePreview.Size: %@", NSStringFromCGSize(self.printImage.previewImage.size));
//    CGFloat scale = self.scroll.zoomScale;
    
    EditImageSetting *editedSetting = self.printImage.editedImageSetting;
    [editedSetting changeFilter:self.contrastToolView.filterName];
    [editedSetting changeSaturation:self.contrastToolView.saturationSetting];
    [editedSetting changeBrightness:self.contrastToolView.brightnessSetting];
    [editedSetting changeContrast:self.contrastToolView.contrastSetting];
    [editedSetting changeOrientation:self.contrastToolView.orientationSetting];
    [editedSetting changeCropVisible:CGRectMake(contentOffset.x,
                                                contentOffset.y,
                                                CGRectGetWidth(self.scroll.frame),
                                                CGRectGetHeight(self.scroll.frame))];
    [editedSetting changeCropRect:CGRectMake(contentOffset.x * zoom,
                                            contentOffset.y * zoom,
                                            scrollSize.width * zoom,
                                            scrollSize.height * zoom)];
    
    
    if (self.completeBlock) {
        self.completeBlock(self.printImage, editedSetting);
    }
}



- (void) actionCancelButton:(UIBarButtonItem *)sender {
    if (self.completeBlock) {
        self.completeBlock(self.printImage, self.printImage.editedImageSetting);
    }
}

-(IBAction)actionMenuButton:(UIButton *)sender {
    // Tag Change
    sender.tag = sender.tag == 0 ? 1 : 0;
    
    
    // Animation
    [UIView animateWithDuration:0.3 animations:^{
        [self.contrastToolView setAlpha:sender.tag];
    }];
    
    
    // Constrait
    [self.view removeConstraints:self.constraitMenuH];
    [self.view removeConstraints:self.constraitMenuV];
    
    NSArray *constraitMenuH;
    NSArray *constraitMenuV;
    
    if (sender.tag == 0) {
        constraitMenuH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[menu(24)]-10-|" options:0 metrics:@{} views:@{@"menu": sender}];
        constraitMenuV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[menu(24)]-10-|" options:0 metrics:@{} views:@{@"menu": sender}];
    } else {
        constraitMenuH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[menu(24)]-10-|" options:0 metrics:@{} views:@{@"menu": sender}];
        constraitMenuV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[menu(24)]-10-[contrast]|" options:0 metrics:@{} views:@{@"menu": sender, @"contrast": self.contrastToolView}];
        
    }
    
    [self.view addConstraints:constraitMenuH];
    [self.view addConstraints:constraitMenuV];
    self.constraitMenuH = constraitMenuH;
    self.constraitMenuV = constraitMenuV;
}


#pragma mark - Property
-(UIImage *)editedImage {
    if (!_editedImage) {
        for (UIImageView *imageView in self.scroll.subviews) {
            if ([imageView isKindOfClass:[UIImageView class]]) {
                _editedImage = imageView.image;
            }
        }
        
        if (!_editedImage) {
            _editedImage = self.printImage.previewImage;
        }
    }
    
    return _editedImage;
}

-(UIImageOrientation)editedImageOrientation {
    return self.editedImage.imageOrientation;
}


@end
