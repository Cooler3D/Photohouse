//
//  EditPhotoViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/11/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "EditPhotoViewController.h"
#import "EditMaskView.h"

#import "ContrastToolBarView.h"
#import "WarningView.h"

#import "UIImage+Crop.h"

#import "AFNetworking.h"
#import "MBProgressHUD.h"

#import "AnaliticsModel.h"

#import "UIImageView+CompareCrop.h"

#import "CLImageEditor.h"
#import "CLClippingTool.h"
#import "CLFilterBase.h"
#import "CLImageToolInfo.h"

#import "EditImageSetting.h"

#import "DeviceManager.h"

#import "PrintData.h"
#import "PrintImage.h"
#import "EditImageSetting.h"
#import "StoreItem.h"
#import "PropType.h"

#import "DrawGridView.h"

#import "CoreDataShopCart.h"


NSString *const EditorDidSaveNotification = @"EditorDidSaveNotification";

NSString *const EditorDidSaveUserInfoKey = @"EditorDidSaveUserInfoKey";


typedef enum {
    ScaleTypeImageFree,      // Свободное трансформирование
    ScaleTypeImageFullAll    // Заполнить все
} ScaleTypeImage;



@interface EditPhotoViewController ()  <UIGestureRecognizerDelegate, ContrastFiltersDelegate, UIScrollViewDelegate, CLClippingToolDelegate>

@property (weak, nonatomic) UIImageView *photoImageView;
@property (weak, nonatomic) UIImageView *cropImageView;


@property (strong, nonatomic) ContrastToolBarView *contrastToolView;
//@property (weak, nonatomic) UIScrollView *scrollFilterView;


@property (assign, nonatomic) BOOL isMoveImageView;

@property (strong, nonatomic) UIImage *editedImage;

@property (assign, nonatomic) CGPoint offsetPoint;
@property (assign, nonatomic) CGPoint offsetImagePoint;

@property (assign, nonatomic) CGFloat imageScale;
@property (assign, nonatomic) CGSize originalImageSize;

//@property (weak, nonatomic) UIButton *scaleButton;
@property (assign, nonatomic) ScaleTypeImage scaleTypeImage;

@property (weak, nonatomic) WarningView *warningView;

@property (nonatomic, strong) CLImageToolBase *clippingTool;

@property (weak, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) PrintData *printData;
@property (strong, nonatomic) PrintImage *printImage;
@property (assign, nonatomic) CGFloat aspect_ratio;
@end



@implementation EditPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // Analitics
    [[AnaliticsModel sharedManager] setScreenName:@"EditImage Screen"];
    
    
    
    NSInteger width = 304;

    //
    self.editedImage = [self.printImage.previewImage copy];
    
    //
    CGSize sizePhoto = self.printImage.previewImage.size;
    CGSize sizeImageView = CGSizeMake(width, (width * sizePhoto.height) / sizePhoto.width);
    self.originalImageSize = sizePhoto;
    
    
    
    // *************
    // Gestures
    // Pan
    UIPanGestureRecognizer *gesturePan;
    if (/*_printData.purchaseID == PhotoHousePrintAlbum && */ ![_printData.storeItem.propType.name isEqualToString:TypeNameDesign]) {
        gesturePan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                             action:@selector(handlePan:)];
        [gesturePan setDelegate:self];
        [self.view addGestureRecognizer:gesturePan];
    
        
        // Pinch
        UIPinchGestureRecognizer *gesturePinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handlePinch:)];
        [self.view addGestureRecognizer:gesturePinch];
    }
    
    
    
    
    
    // ***************
    // Image Photo
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    //[imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setImage:self.editedImage];
    [self.view addSubview:imageView];
    self.photoImageView = imageView;
    
    
    
    
    
    
    
    // *************
    // CROP
    UIImageView *crop;
    UIImage *gridImage = self.printData.gridImage;
    
    if (self.printData.purchaseID == PhotoHousePrintAlbum && [_printData.storeItem.propType.name isEqualToString:TypeNameConstructor]) {
        CGFloat const toolBarHeight = 114.f;
        CGFloat const headerHeight = 64.f;
        
        CGSize sizeView = CGSizeMake(CGRectGetWidth(self.view.frame) - 20.f,
                                     CGRectGetHeight(self.view.frame) - toolBarHeight - headerHeight);
        CGRect insertRect = [[UIImage alloc] insertSizeView:sizeView withAspectRatio:self.aspect_ratio];
        CGFloat width = CGRectGetWidth(insertRect);
        CGFloat height = CGRectGetHeight(insertRect);
        
        DrawGridView *gridView = [[DrawGridView alloc] initWithFrame:CGRectMake(0.f, 0.f, width, height)];
        gridImage = gridView.gridImage;
    }
    
    CGSize gridSize = gridImage != nil ? gridImage.size : self.originalImageSize;
    CGRect rectCrop = [self cropRectWithImageSize:gridSize];
    crop = [[UIImageView alloc] initWithFrame:rectCrop];
    //[crop setAlpha:0.5f];
    [crop setImage:gridImage];
    [self.view addSubview:crop];
    self.cropImageView = crop;

    
    
    // ****************
    // Центрируем изображение относительно Crop
    if (self.printData.purchaseID == PhotoHousePrintAlbum && sizeImageView.height > CGRectGetHeight(self.view.frame) - 60.f - 114.f)
    {
        CGFloat height = CGRectGetHeight(self.view.frame) - 60.f - 114.f - 40.f;
        sizeImageView = CGSizeMake((height * sizePhoto.width) / sizePhoto.height, height);
    }
    CGPoint pointCenter = [self pointCenterImageView:sizeImageView ofCenterCropView:crop];
    [self.photoImageView setFrame:CGRectMake(pointCenter.x,
                                             pointCenter.y,
                                             sizeImageView.width,
                                             sizeImageView.height)];
    
    
    
    
    
    // *************
    // Mask
    EditMaskView *mask = [[EditMaskView alloc] initWithFrame:self.view.frame withCutFrame:crop.frame];
    [self.view addSubview:mask];
    
    
    
    
    
    
    // *************
    // Scale Button
    self.scaleTypeImage = ScaleTypeImageFullAll;
    UIButton *scaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scaleButton setFrame:CGRectMake(CGRectGetMaxX(self.view.frame) - 63, 84, 44, 44)];
    [scaleButton setImage:[UIImage imageNamed:@"scale_off"] forState:UIControlStateNormal];
    [scaleButton setImage:[UIImage imageNamed:@"scale_on"] forState:UIControlStateSelected];
    [scaleButton addTarget:self action:@selector(actionScaleButton:) forControlEvents:UIControlEventTouchUpInside];
    [scaleButton setSelected:(self.scaleTypeImage == ScaleTypeImageFullAll ? YES : NO)];
    [self.view addSubview:scaleButton];
    if (self.printData.purchaseID == PhotoHousePrintAlbum && [self.printData.storeItem.propType.name isEqualToString:TypeNameConstructor]) {
        // если Альбом и Конструкторский, то кнопку не показываем и она всегда включана
        [scaleButton removeFromSuperview];
    }
    //self.scaleButton = scaleButton;
    
    
    
    
    // *******************
    // Resize Clipping
    if (self.printData.purchaseID == PhotoHousePrintAlbum && [_printData.storeItem.propType.name isEqualToString:TypeNameDesign]) {
        // Hide Standart Crop
        [self.cropImageView setHidden:YES];
        [scaleButton setHidden:YES];
        [mask setHidden:YES];
        
        //
//#warning ToDo: Remove Crop
//        CLImageToolInfo *info = [CLImageToolInfo toolInfoForToolClass:[CLClippingTool class]];
//        [self setupToolWithToolInfo:info];
    }

    
    
    // **************
    WarningView *warningView = [[[NSBundle mainBundle] loadNibNamed:@"WarningView" owner:self options:nil] firstObject];
    [warningView setCenter:CGPointMake(125, scaleButton.center.y)];
    //[self.view addSubview:warningView];
    self.warningView = warningView;
    
    
    
    
    
    
    
    
    // Contrast Tool
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        ContrastToolBarView *contrastToolView = [[[NSBundle mainBundle] loadNibNamed:@"ContrastToolBarView" owner:self options:nil] firstObject];
//        CGFloat widthView = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
//        CGFloat heightView = MAX(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
//        contrastToolView.center = CGPointMake(widthView / 2,
//                                              heightView - 57.f);
        [contrastToolView setOriginalImage:self.editedImage];
        [contrastToolView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [contrastToolView setDelegate:self];
        [contrastToolView removeGestureRecognizer:gesturePan];
        [self.view addSubview:contrastToolView];
        self.contrastToolView = contrastToolView;
        
        
        
        NSArray *constraitH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contrastView]|" options:0 metrics:@{} views:@{@"contrastView":contrastToolView}];
        NSArray *constraitV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[contrastView]|" options:0 metrics:@{} views:@{@"contrastView":contrastToolView}];
        [self.view addConstraints:constraitH];
        [self.view addConstraints:constraitV];
        
        
        
        // Если уже редактировали изображение
        //if (self.photoRecord.edited && self.photoRecord.editImageSetting) {
        EditImageSetting *config = self.printImage.editedImageSetting;
        if ([config isDidEditing]) {
            //EditImageSetting *config = self.photoRecord.editImageSetting;
            [self configureForEditedSetting:config andScaleButton:scaleButton];
        }
    });
    
    

    
    
    
    
    
    // Scale and Warning
    [self checkImageScale:YES];
    //[self checkWarningScale:self.photoImageView withHitTestCropView:self.cropImageView andPhotoObject:self.photoRecord.printData.photoObject];
    
    // Если уже редактировали изображение
    //if (self.photoRecord.edited && self.photoRecord.editImageSetting) {
//    EditImageSetting *config = self.printImage.editedImageSetting;
//    if ([config isDidEditing]) {
//        //EditImageSetting *config = self.photoRecord.editImageSetting;
//        [self configureForEditedSetting:config];
//    }
}

- (CGRect) cropRectWithImageSize:(CGSize)sizeImage {
    
    NSInteger const widthWithOutButton = CGRectGetWidth(self.view.frame) - 160;      // Свободная ширина между кнопками
    NSInteger const buttonHeight = 75;                                      // Высота кнопки "Warning", или "FullScale"
    NSInteger const heightCrop = CGRectGetHeight(self.view.frame) - buttonHeight - 60 - 114 - 20;   // Общая высота - шапка сверху - ToolBar снизу - стандартный отступ
    
    CGFloat height = 0;
    CGFloat width = heightCrop * sizeImage.width / sizeImage.height;
    
    CGFloat posY;
    
    
    
    //  Если получившеся ширина > ширины между кнопками
    if (width > widthWithOutButton && width < CGRectGetWidth(self.view.frame)) {
        height = heightCrop;
        
        posY = (heightCrop / 2);
        
        
    } else if (width > widthWithOutButton && width > CGRectGetWidth(self.view.frame)) {
        width = 300;
        height = width * sizeImage.height / sizeImage.width;
        
        posY = (heightCrop / 2);
        
    } else {
        width = widthWithOutButton;
        height = widthWithOutButton * sizeImage.height / sizeImage.width;
        
        posY = ((heightCrop + buttonHeight) / 2) - (height / 4);
    }
    

    
    
    
    CGRect rectCrop = CGRectMake(CGRectGetMidX(self.view.frame) - (width / 2),
                                 posY,
                                 width, height);
    return rectCrop;
}


-(void)viewDidAppear:(BOOL)animated {
    [self performSelector:@selector(stantandartTabBarButtons) withObject:self afterDelay:0.3f];
    
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    DeviceManager *deviceManager = [[DeviceManager alloc] init];
    NSString *analitisLabel = [NSString stringWithFormat:@"Device: %@; ImageSize: %@", [deviceManager getDeviceName], NSStringFromCGSize(_printImage.previewImage.size)];
    [[AnaliticsModel sharedManager] sendEventCategory:@"Warning" andAction:@"Edit.ReceiveMemoryWarning" andLabel:analitisLabel withValue:nil];

}


#pragma mark - Rotate
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
}



#pragma mark - Gesture
- (void) handlePan:(UIPanGestureRecognizer*)gesture {
    
//    UIView *view = gesture.view;
    
    //NSLog(@"Point: %@", NSStringFromCGPoint([gesture velocityInView:view]));
    
    /*if ([view isEqual:self.view]) {
        NSLog(@"OK");
    }*/
    
//    CGPoint point = [gesture locationInView:view];
//    if (point.y > 450) {
//        [self checkImageCoordinate];
//        return;
//    }
    
    
    
    if ([gesture state] == UIGestureRecognizerStateBegan) {                 // Began
        self.offsetImagePoint = self.photoImageView.center;
        self.offsetPoint = CGPointZero;
        
        
        
    } else if([gesture state] == UIGestureRecognizerStateEnded) {           // Ended
        [self checkImageCoordinate];
        
        
    } else if ([gesture state] == UIGestureRecognizerStateChanged) {        // Change
        CGPoint point = [gesture locationInView:self.view];
        
        CGPoint deltaPoint;
        if (CGPointEqualToPoint(self.offsetPoint, CGPointZero)) {
            self.offsetPoint = point;
            deltaPoint = CGPointZero;
            return;
        } else {
            CGFloat deltaX = point.x - self.offsetPoint.x;
            CGFloat deltaY = point.y - self.offsetPoint.y;
            deltaPoint = CGPointMake(deltaX, deltaY);
        }
        
        self.photoImageView.center = CGPointMake(deltaPoint.x + self.offsetImagePoint.x,
                                                 deltaPoint.y + self.offsetImagePoint.y);
        
        self.offsetPoint = point;
        self.offsetImagePoint = self.photoImageView.center;
    } else if ([gesture state] == UIGestureRecognizerStateFailed || [gesture state] == UIGestureRecognizerStateCancelled) {
//        NSLog(@"Filed || Canceled");
    }

}


- (void) handlePinch:(UIPinchGestureRecognizer*)gesturePinch {
    // Begin
    if (gesturePinch.state == UIGestureRecognizerStateBegan) {
        self.imageScale = 1.f;
    }
    
    
    // Change
    if (gesturePinch.state == UIGestureRecognizerStateChanged) {
        CGFloat delta = 1.f + gesturePinch.scale - self.imageScale;
        
        CGAffineTransform currenttransform = self.photoImageView.transform;
        CGAffineTransform newTransform = CGAffineTransformScale(currenttransform, delta, delta);
        
        self.photoImageView.transform = newTransform;
        
        self.imageScale = gesturePinch.scale;
    }
    
    
    // End Gesture state
    if (gesturePinch.state == UIGestureRecognizerStateEnded) {
        [self checkImageScale:NO];
        [self checkImageCoordinate];
        //[self checkWarningScale:self.photoImageView withHitTestCropView:self.cropImageView andPhotoObject:self.photoRecord.printData.photoObject];
    }
}






#pragma mark - Private Methods
- (void) configureForEditedSetting:(EditImageSetting*)setting andScaleButton:(UIButton *)scaleButton{
    //
    [self.contrastToolView setMemberEditedSetting:setting];
    
    //
    if (_clippingTool) {
        [(CLClippingTool*)_clippingTool setupMemberRect:setting.rectToVisibleEditor];
    }
    
    //
    if (_scaleTypeImage == ScaleTypeImageFullAll && !setting.isAutoResizing) {
        [self actionScaleButton:scaleButton];
    }
    
    //
    //if (_printData.purchaseID != PhotoHousePrintAlbum) {
        [self.photoImageView setFrame:setting.rectToVisibleEditor];
    //}
    
}



- (void) checkImageCoordinate {
    // Проверяем можно ли притягивать к краям
    if (self.scaleTypeImage == ScaleTypeImageFree/* || _printData.purchaseID == PhotoHousePrintAlbum*/) {
        return;
    }
    
    CGFloat deltaX = 0;
    CGFloat deltaY = 0;
    
    //По X
    if (CGRectGetMaxX(self.cropImageView.frame) > CGRectGetMaxX(self.photoImageView.frame)) {
        deltaX = CGRectGetMaxX(self.cropImageView.frame) - CGRectGetMaxX(self.photoImageView.frame);
        
    } else if (CGRectGetMinX(self.cropImageView.frame) < CGRectGetMinX(self.photoImageView.frame)) {
        deltaX = CGRectGetMinX(self.cropImageView.frame) - CGRectGetMinX(self.photoImageView.frame);
    }
    
    // По Y
    if (CGRectGetMaxY(self.cropImageView.frame) > CGRectGetMaxY(self.photoImageView.frame)) {
        deltaY = CGRectGetMaxY(self.cropImageView.frame) - CGRectGetMaxY(self.photoImageView.frame);
    } else if (CGRectGetMinY(self.cropImageView.frame) < CGRectGetMinY(self.photoImageView.frame)) {
        deltaY = CGRectGetMinY(self.cropImageView.frame) - CGRectGetMinY(self.photoImageView.frame);
    }
    
    
    CGPoint offset = CGPointMake(self.photoImageView.center.x + deltaX,
                                 self.photoImageView.center.y + deltaY);
    
    
    [UIView animateKeyframesWithDuration:0.3f
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                              animations:^{
                                  //
                                  self.photoImageView.center = offset;
                                  
                                  [self checkImageScale:NO];
                              }
                              completion:nil];
}







- (CGPoint) pointCenterImageView:(CGSize)sizeImageView ofCenterCropView:(UIImageView*)crop {
    // Центрируем изображение относительно Crop
    CGFloat posX = CGRectGetMinX(crop.frame);
    CGFloat posY = CGRectGetMinY(crop.frame);
    NSLog(@"image: %@", NSStringFromCGSize(sizeImageView));
    NSLog(@"crop: %@", NSStringFromCGRect(crop.frame));
    if (sizeImageView.width > CGRectGetWidth(crop.frame))
    {
        posX = CGRectGetMinX(crop.frame) - ((sizeImageView.width - CGRectGetWidth(crop.frame)) / 2);
    }
    else if(sizeImageView.width < CGRectGetWidth(crop.frame))
    {
        posX = CGRectGetMinX(crop.frame) + ((CGRectGetWidth(crop.frame) - sizeImageView.width) / 2);
    }
    
    
    if (sizeImageView.height > CGRectGetHeight(crop.frame))
    {
        posY = CGRectGetMinY(crop.frame) - ((sizeImageView.height - CGRectGetHeight(crop.frame)) / 2);
    }
    else if (sizeImageView.height < CGRectGetHeight(crop.frame))
    {
        posY = CGRectGetMinY(crop.frame) + ((CGRectGetHeight(crop.frame) - sizeImageView.height) / 2);
    }

    return CGPointMake(posX, posY);
}







- (void) checkImageScale:(BOOL)startEditor
{
    // Проверяем можно ли притягивать к краям
    if (self.scaleTypeImage == ScaleTypeImageFree/* || _printData.purchaseID == PhotoHousePrintAlbum*/) {
        return;
    }
    
    
    // Min: Width and Height
    if (CGRectGetWidth(self.photoImageView.frame) < CGRectGetWidth(self.cropImageView.frame) && CGRectGetHeight(self.photoImageView.frame) < CGRectGetHeight(self.cropImageView.frame)) {
        CGSize sizePhoto;
        if (CGRectGetWidth(self.cropImageView.frame) > CGRectGetHeight(self.cropImageView.frame)) {
            sizePhoto = CGSizeMake(CGRectGetWidth(self.cropImageView.frame),
                                    CGRectGetWidth(self.cropImageView.frame) * self.originalImageSize.height / self.originalImageSize.width);
        } else {
            sizePhoto = CGSizeMake(CGRectGetHeight(self.cropImageView.frame) * self.originalImageSize.width / self.originalImageSize.height,
                                          CGRectGetHeight(self.cropImageView.frame));
        }
        
        CGPoint pointCenter = [self pointCenterImageView:sizePhoto ofCenterCropView:self.cropImageView];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.photoImageView.frame = CGRectMake(pointCenter.x/*CGRectGetMinX(self.cropImageView.frame)*/,
                                                   pointCenter.y/*CGRectGetMinY(self.cropImageView.frame)*/,
                                                   sizePhoto.width,
                                                   sizePhoto.height);
        }];

    }
    
    
    
    
    
    // Min: Size Width
    if (CGRectGetWidth(self.photoImageView.frame) < CGRectGetWidth(self.cropImageView.frame)) {
        CGSize sizePhoto = CGSizeMake(CGRectGetWidth(self.cropImageView.frame),
                                      CGRectGetWidth(self.cropImageView.frame) * self.originalImageSize.height / self.originalImageSize.width);
        
        
        CGPoint pointCenter = [self pointCenterImageView:sizePhoto ofCenterCropView:self.cropImageView];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.photoImageView.frame = CGRectMake(CGRectGetMinX(self.cropImageView.frame),
                                                   pointCenter.y/*CGRectGetMinY(self.cropImageView.frame)*/,
                                                   sizePhoto.width,
                                                   sizePhoto.height);
        }];
    }
    
    
    // Min: Size Height
    else if (CGRectGetHeight(self.photoImageView.frame) < CGRectGetHeight(self.cropImageView.frame)) {
        CGSize sizePhoto = CGSizeMake(CGRectGetHeight(self.cropImageView.frame) * self.originalImageSize.width / self.originalImageSize.height,
                                      CGRectGetHeight(self.cropImageView.frame));
        
        CGPoint pointCenter = [self pointCenterImageView:sizePhoto ofCenterCropView:self.cropImageView];
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
            self.photoImageView.frame = CGRectMake(pointCenter.x,
                                                   CGRectGetMinY(self.cropImageView.frame),
                                                   sizePhoto.width,
                                                   sizePhoto.height);
        }];
    }
}




/*- (void) checkWarningScale:(UIImageView*)imageView withHitTestCropView:(UIImageView*)cropView andPhotoObject:(PhotoObject)photoObject
{
    // Чтобы не ошибиться, выделяем коэфицент и умножаем на 1 000 000
    NSUInteger maxSquare = [self minimumSquarePixelsPhotoObject:photoObject];//= maxSquare * 1000000;
    
    BOOL isSize = [imageView compareSquareHitTestCropView:cropView withMaxSquare:maxSquare];
    if (isSize) {
        [self.warningView showWarningView];
    } else {
        [self.warningView hideWarningView];
    }
}*/



/*- (NSUInteger) minimumSquarePixelsPhotoObject:(PhotoObject)photoObject {
    NSInteger maxSquare = 1;
    
    switch (photoObject) {
        case PhotoObjectBrelok:
        case PhotoObjectBrelokEightCorner:
        case PhotoObjectCaseIPhone5:
        case PhotoObjectCaseIPhone4:
        case PhotoObjectCaseIPhone6:
        case PhotoObjectPhoto_8x10:
        case PhotoObjectPhoto_10x13_5:
        case PhotoObjectPhoto_10x15:
        case PhotoObjectPhoto_13x18:
        case PhotoObjectPhoto_15x21:
        case PhotoObjectPhoto_20x30:
        case PhotoObjectAlbum_Marriage:
        case PhotoObjectMagnitCollage:
        case PhotoObjectMagnitSingle:
        case PhotoObjectMagnitHeart:
            maxSquare = 1;
            break;
            
        case PhotoObjectCup:
        case PhotoObjectCupHameleon:
        case PhotoObjectCupColor:
        case PhotoObjectCupGlass:
        case PhotoObjectCupLove:
        case PhotoObjectCupLatte:
            maxSquare = 2;
            break;
            
        case PhotoObjectMouseMat:
        case PhotoObjectClock:
        case PhotoObjectPlate:
        case PhotoObjectCanvas:
            maxSquare = 2;
            break;
            
        case PhotoObjectTShirt:
        case PhotoObjectBagCoton:
        case PhotoObjectBagStudents:
            maxSquare = 4;
            break;
            
        case PhotoObjectPuzzle:
        case PhotoObjectPuzzleHeart:
            maxSquare = 3;
            break;
            
        case PhotoObjectDelivery:
            break;
    }
    
    // ЧТобы не ошибиться, выделяем коэфицент и умножаем на 1 000 000
    return maxSquare * 1000000;
}*/




- (void) stantandartTabBarButtons {
    [self addCompleteNavigationBarButton];
    [self addCancelNavigationBarButton];
    
    self.isMoveImageView = YES;
    
    /*[UIView animateWithDuration:0.3f animations:^{
        self.scrollFilterView.alpha = 1;
    }];*/
}

- (void) addCompleteNavigationBarButton {
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Готово" style:UIBarButtonItemStylePlain target:self action:@selector(actionSaveAndCloseButton:)];
    //if ([MDUserDefaultsParameters IOS7]) {
    [button setTintColor:[UIColor whiteColor]];
    //}
    [self.navigationItem setRightBarButtonItem:button animated:YES];
}




- (void) addCancelNavigationBarButton {
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    [self.navigationController.navigationItem setBackBarButtonItem:nil];
    
    //
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:self action:@selector(actionCancelController:)];
    //if ([MDUserDefaultsParameters IOS7]) {
    [button setTintColor:[UIColor whiteColor]];
    //}
    [self.navigationItem setLeftBarButtonItem:button animated:YES];
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
    self.originalImageSize = image.size;
    
    CGSize imageSize = image.size;
    CGFloat oldWidth = CGRectGetWidth(self.photoImageView.frame);
    [self.photoImageView setFrame:CGRectMake(CGRectGetMinX(self.photoImageView.frame),
                                             CGRectGetMinY(self.photoImageView.frame),
                                             oldWidth,
                                             oldWidth * imageSize.height / imageSize.width)];
    [self.photoImageView setImage:image];

    self.editedImage = image;
    
    //
    [self checkImageCoordinate];
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



/*-(void)contrastToolDidFilterListOpened:(ContrastToolBarView *)contrastTool {
    
    
    self.isMoveImageView = YES;
}*/





#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"Begin");
    return  self.isMoveImageView;
}
// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"shouldReceiveTouch: %@", [[touch view] class]);
    if ([[touch view] isKindOfClass:[UISlider class]]) {
        return NO;
    }
    
    return YES;
}


#pragma mark - Public Methods
//- (void) setEditPhotoRecord:(PhotoRecord*)record; {
//    //self.photoRecord = record;
//    //NSLog(@"Edit: %@", NSStringFromCGSize(record.editedImage.size));
//}



- (void) printData:(PrintData *)printData andEditenImage:(PrintImage *)printImage
{
    self.printData = printData;
    self.printImage = printImage;
}


-(void)printData:(PrintData *)printData andEditenImage:(PrintImage *)printImage andGridAspectRatio:(CGFloat)aspect_ratio
{
    [self printData:printData andEditenImage:printImage];
    self.aspect_ratio = aspect_ratio;
}




#pragma mark - Actions
/* кнопка "Отмена" */
- (IBAction)actionCancelController:(UIButton *)sender
{
    // Progress
    [self contractTool:nil didUpdateProgressShow:YES];
    
    // Crop, Album
    /*if (self.photoRecord.printData.printObject == PrintObjectAlbum) {
        
        // Если перед этим редактировали. Т.е Витрина - Редактор - ОК - Редактор - Отмена
        if (self.photoRecord.editImageSetting)
        {
            __weak EditPhotoViewController *weakSelf = self;
            [(CLClippingTool*)_clippingTool setupMemberRect:self.photoRecord.editImageSetting.cropRect];
            [(CLClippingTool*)_clippingTool executeWithCustomCompletionBlock:^(UIImage *image, CGRect rectOriginal, CGRect cropRectSetting) {
                [weakSelf.photoRecord setCropImage:image];
                [weakSelf.photoRecord setEditedImage:self.editedImage];
            }];
        }
        else // Если не редактированили: Витрина - Редактор - Отмена
        {
            
            UIImage *img = [self.photoRecord.image copy];
            [self.photoRecord setCropImage:img];
            [self.photoRecord setEditedImage:img];
        }
    }
    else    // Other Prins
    {*/
        // Берем оригинальную фотку и обрезаем стандартно
        /*UIImage *img = [self.photoRecord.image copy];
        CGFloat aspect_ratio = self.photoRecord.printData.delitelHeight;
        
        CGRect rect = [[UIImage alloc] sizeImage:img withDelitelHeight:aspect_ratio];
        UIImage *cropImage = [[UIImage alloc] cropImageFrom:img WithRect:rect];*/
        
        EditImageSetting *config = self.printImage.editedImageSetting;
        [config changeSetupDefault];
        
        //[_printData createAndAddMergedImageWithPrintImage:self.printImage.previewImage];
        [_printData createMergedImageWithPreview:self.printImage.previewImage andCompleteBlock:nil andProgressBlock:nil];
        
        //
        NSNotification *notification = [NSNotification notificationWithName:EditorDidSaveNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];

        
        //
        //[self.photoRecord setCropImage:cropImage];
        //[self.photoRecord setEditedImage:img];
    //}
    
    
    
    // Analitics
    [[AnaliticsModel sharedManager] sendEventCategory:@"Edit" andAction:@"Action" andLabel:@"Cancel(Not Saved) Edit Image" withValue:nil];
    
    // Close
    [self closeViewController];
}


/* Кнопка "Готово" сохраняем и выходим */
- (void) actionSaveAndCloseButton:(UIBarButtonItem*)sender {
    // progress
    [self contractTool:nil didUpdateProgressShow:YES];
    
    
//    __weak EditPhotoViewController *weakSelf = self;
    
    // Crop
//    if (self.printData.purchaseID == PhotoHousePrintAlbum && [_printData.storeItem.propType.name isEqualToString:TypeNameDesign]) {
//        if (_clippingTool) {
//            [(CLClippingTool*)_clippingTool executeWithCustomCompletionBlock:^(UIImage *image, CGRect rectOriginal, CGRect cropRectSetting) {
//                CGFloat aspectScale = self.printImage.originalImageSize.width / self.originalImageSize.width;
//                
//                // Финальное обрезание, для оригинальной картинки
//                CGRect finalCropRect = CGRectMake(CGRectGetMinX(rectOriginal) * aspectScale,
//                                                  CGRectGetMinY(rectOriginal) * aspectScale,
//                                                  CGRectGetWidth(rectOriginal) * aspectScale,
//                                                  CGRectGetHeight(rectOriginal) * aspectScale);
//                [weakSelf saveCropImage:image andMemberSettingCrop:cropRectSetting andOriginalRect:finalCropRect];
//            }];
//        }
//    }
//    else
//    {
        //
        CGSize cropImageSize = self.cropImageView.image.size;
        CGFloat ratio = cropImageSize.width / cropImageSize.height;
        
        UIImage *cropImage = [[UIImage alloc] cropImage:self.photoImageView withCropImageView:self.cropImageView andRatio:ratio];
        
        // Обрезание картинки для обрезанной картинки printImage.previewImage.size
        CGRect cropRect = [[UIImage alloc] cropImageAndRect:self.photoImageView withCropImageView:self.cropImageView andRatio:ratio];
        CGFloat aspectScale = self.printImage.originalImageSize.width / self.originalImageSize.width;
        
        // Финальное обрезание, для оригинальной картинки
        CGRect finalCropRect = CGRectMake(CGRectGetMinX(cropRect) * aspectScale,
                                          CGRectGetMinY(cropRect) * aspectScale,
                                          CGRectGetWidth(cropRect) * aspectScale,
                                          CGRectGetHeight(cropRect) * aspectScale);
        [self saveCropImage:cropImage andMemberSettingCrop:CGRectZero andOriginalRect:finalCropRect];
//    }
}


- (void) actionScaleButton:(UIButton*)sender {
    if (self.scaleTypeImage == ScaleTypeImageFullAll) {
        self.scaleTypeImage = ScaleTypeImageFree;
    } else {
        self.scaleTypeImage = ScaleTypeImageFullAll;
        [self checkImageScale:NO];
        [self checkImageCoordinate];
    }
    
    [sender setSelected:(self.scaleTypeImage == ScaleTypeImageFullAll ? YES : NO)];
    
    // Check Warning
    //[self checkWarningScale:self.photoImageView withHitTestCropView:self.cropImageView andPhotoObject:self.photoRecord.printData.photoObject];
}


- (void) closeViewController {
    // Progress hide
    [self contractTool:nil didUpdateProgressShow:NO];
    
    //
    [self.navigationController popViewControllerAnimated:YES];
}



- (void) saveCropImage:(UIImage*)cropImage andMemberSettingCrop:(CGRect)settingCtop andOriginalRect:(CGRect)originalRect
{
    // Analitics
    [[AnaliticsModel sharedManager] sendEventCategory:@"Edit" andAction:@"Action" andLabel:@"Save Edit Image" withValue:nil];
    
    
    CGRect rectToVisible;
    if (_printData.purchaseID == PhotoHousePrintAlbum && [_printData.storeItem.propType.name isEqualToString:TypeNameDesign]) {
        rectToVisible = settingCtop;
    } else {
        rectToVisible = self.photoImageView.frame;
    }
    
    //
    EditImageSetting *config = self.printImage.editedImageSetting;
    [config changeFilter:self.contrastToolView.filterName];
    [config changeSaturation:self.contrastToolView.saturationSetting];
    [config changeBrightness:self.contrastToolView.brightnessSetting];
    [config changeContrast:self.contrastToolView.contrastSetting];
    [config changeOrientation:self.contrastToolView.orientationSetting];
    [config changeAutoResize:_scaleTypeImage == ScaleTypeImageFree ? NO : YES];
    [config changeCropVisible:rectToVisible];
    [config changeCropRect:originalRect];
    
    
    //
    if (self.printData.purchaseID == PhotoHousePrintAlbum && [_printData.storeItem.propType.name isEqualToString:TypeNameDesign]) {
        [_printImage updatePreviewImage:self.editedImage];
    } else
    if(_printData.imagesPreview.count > 2 || (_printData.purchaseID == PhotoHousePrintMagnit && _printData.imagesPreview.count > 1)) {
        [_printImage updatePreviewImage:cropImage];
    } else if (self.printData.purchaseID != PhotoHousePrintMug) {
        [_printData createMergedImageWithPreview:cropImage andCompleteBlock:nil andProgressBlock:nil];
    }
    
    
    // Update After Editor
    //CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    //[coreShop updateAfterEditorPrintData:self.printData andPrintImage:self.printImage];
    
    //
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.printImage.urlLibrary forKey:EditorDidSaveUserInfoKey];
    NSNotification *notification = [NSNotification notificationWithName:EditorDidSaveNotification object:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    // Close
    [self closeViewController];
    
}



#pragma mark - CLImageEditorLibrary
- (void)setupToolWithToolInfo:(CLImageToolInfo*)info
{
    if(self.clippingTool){ return; }
    
    Class toolClass = NSClassFromString(info.toolName);
    
    if(toolClass){
        id instance = [toolClass alloc];
        if(instance!=nil && [instance isKindOfClass:[CLImageToolBase class]]){
            instance = [instance initWithImageEditor:(id)self withToolInfo:info];
            self.currentTool = instance;
        }
    }
}

- (void)setCurrentTool:(CLImageToolBase *)currentTool
{
    if(currentTool != _clippingTool){
        [_clippingTool cleanup];
        _clippingTool = currentTool;
        [(CLClippingTool*)_clippingTool setupWithImageView:self.photoImageView andDelegate:self];
    }
}




#pragma mark - CLClippingToolDelegate
-(void)clClippingTool:(CLClippingTool *)tool didMoveSelectGridEnd:(CGRect)rect {
    //__weak EditPhotoViewController *weakSelf = self;
    
    [_clippingTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
        //
        /*PhotoObject photoObject = weakSelf.photoRecord.printData.photoObject;
        NSUInteger maxSquare = [weakSelf minimumSquarePixelsPhotoObject:photoObject];
        NSUInteger imageSquare = image.size.width * image.size.height;
        if (maxSquare > imageSquare) {
            [weakSelf.warningView showWarningView];
        } else {
            [weakSelf.warningView hideWarningView];
        }*/
    }];
}


@end
