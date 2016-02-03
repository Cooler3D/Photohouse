//
//  ShowCaseViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/28/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "ShowCaseViewController.h"
#import "EditPhotoViewController.h"
#import "MenuTableViewController.h"

#import "SelectNavigationViewController.h"
#import "SelectImagesNotification.h"

#import "AnaliticsModel.h"
#import "SkinModel.h"

#import "UIImage+Crop.h"
#import "NSArray+Reverse.h"
#import "UIView+Toast.h"
#import "UIImage+AssetResize.h"

#import "ToolPhotoView.h"
#import "ToolMainView.h"
#import "ToolIconTheme.h"
#import "TShirtSizeView.h"
#import "MugColorView.h"

#import "DeviceManager.h"

#import "WarningView.h"

#import "MBProgressHUD.h"

#import "PhAppNotifications.h"

#import "PrintData.h"
#import "PrintImage.h"
#import "StoreItem.h"
#import "PropType.h"
#import "PropSize.h"
#import "PropColor.h"


#import "SaveImageManager.h"
#import "CoreDataShopCart.h"



static NSString *const SEGUE_EDIT_CONTROLLER = @"goEditController";
static NSString *const SEGUE_ALBUM_QUEUE = @"segue_album_queue";
static NSString *const SEGUE_SELECT_PHOTO = @"segue_selectphoto";



@interface ShowCaseViewController () <ToolShowCaseDelegate, TShirtSizeDelegate, MugColorDelegate, SaveImageManagerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) UIImageView *shadowImageView;           ///< Картинка, поверх основной картинки (Передний слой)

@property (weak, nonatomic) MBProgressHUD *hud;                     ///< Загрузчик

@property (weak, nonatomic) WarningView *warningView;

@property (weak, nonatomic) UIButton *selectedCollageView;

@property (assign, nonatomic) BOOL isHamelionAnimate;
@property (assign, nonatomic) BOOL isHameleonCloseAnimate;

@property (strong, nonatomic) PrintData *printData;
@property (strong, nonatomic) StoreItem *storeItem;                 ///< Покупка
@property (strong, nonatomic) NSArray *printImages;                 ///< Массив [PrintImage] которые нужно сохранить, пришли из пердыдущего контроллера (Фотопечать, Альбом)

@property (weak, nonatomic) UIScrollView *toolBarScrollView;        ///< Скролл для иконок, в нем содержатся ToolTheme
//@property (weak, nonatomic) UIScrollView *mainPhotoScrollView;    ///< Скролл для обльших картинок

@property (weak, nonatomic) UIImageView *mainImageView;             ///< Основная картинка для показа

@property (assign, nonatomic) SaveProgressStatus saveProgress;      ///< Сохранение в фоне

@property (weak, nonatomic) UIButton *selectPhotoButton;            ///< Кнопка для открываения окна выбора фоток

/// Свойство автоматического открытия окна "Выбор фото", Yes - Открываем, NO - не открываем
//@property (assign, nonatomic) BOOL autoOpenSelectImages;

/// Автоматическое формирование очереди на сохранение в корзине
@property (strong, nonatomic) SaveImageManager *saveManager;

/// AlertView если во время отображения диалоговое окно активно, убираем
@property (weak, nonatomic) UIAlertView *alertView;

@end



@implementation ShowCaseViewController

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
    AnaliticsModel *analitics = [AnaliticsModel sharedManager];
    [analitics setScreenName:@"ShowCase Screen"];
    [analitics sendEventCategory:@"ShowCase" andAction:@"Purchase"
                        andLabel:[self analiticsPhotoPrint:self.storeItem ? (PhotoHousePrint)[self.storeItem.purchaseID integerValue] : self.printData.purchaseID]
                       withValue:nil];
    
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(self.storeItem.namePurchase, nil)];
    
    
    // Notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationPhotoEditorDidSave:) name:EditorDidSaveNotification object:nil];
    //[nc addObserver:self selector:@selector(notificationImagesDidSelected:) name:AllImagesSelectCompleteNotification object:nil];
    
    //
    UIBarButtonItem *shopCartButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"add_to_cart", nil)
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(actionCartButton:)];
    [shopCartButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:shopCartButton];
    
    
    
    // Main Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:imageView];
    self.mainImageView = imageView;

    
    // Tool Buttons
    //[self addToolButtons:purchaseID];
    
    
    // **************
    WarningView *warningView = [[[NSBundle mainBundle] loadNibNamed:@"WarningView" owner:self options:nil] firstObject];
    [warningView setCenter:CGPointMake(CGRectGetWidth(self.view.frame) - 151, 100)];
    //CGPointMake(printData.photoObject == PhotoObjectTShirt ? 195 : CGRectGetWidth(self.view.frame) - 151,
                                       //100)];
    [self.view addSubview:warningView];
    self.warningView = warningView;
    [self.warningView hideWarningView];
    
    
    // TShirt
    PhotoHousePrint purchaseID = (PhotoHousePrint)[self.storeItem.purchaseID integerValue];
    if (purchaseID == PhotoHousePrintTShirt) {
        TShirtSizeView *tShirtSizeView = [[[NSBundle mainBundle] loadNibNamed:@"TShirtSizeView" owner:self options:nil] firstObject];
        [tShirtSizeView setCenter:CGPointMake(52, 193)];
        [tShirtSizeView setPrintDataStoreItem:self.storeItem withDelegate:self];
        [self.view addSubview:tShirtSizeView];
        //self.tShirtSizeView = tShirtSizeView;
    }
    
    
    //Mug Color
    if (purchaseID == PhotoHousePrintMug && self.storeItem.propType.colors.count > 0) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MugColorView" owner:self options:nil];
        MugColorView *mugColorView = [array firstObject];
        [mugColorView setCenter:CGPointMake(52, 193)];
        [mugColorView setPrintDataStoreItem:self.storeItem withDelegate:self];
        [self.view addSubview:mugColorView];
        
        
        // Position WarningView
        //[warningView setCenter:CGPointMake(195, 100)];
    }
    
    
    
    // Проверяем есть ли не сохраненный альбом, потому что только он проверяется
    if (self.printData) {
        // Есть не сохраненные данные
        // Добавляем картинки
        NSArray *printImages = self.printData.imagesPreview;
        for (PrintImage *printImage in printImages) {
            [self addToolManyPrintImages:printImage];
        }
        // Tool Buttons
        [self addToolButtons:self.printData];
        
    } else {
        // Создаем новую покупку
        PrintData *printData = [[PrintData alloc] initWithStoreItem:self.storeItem andUniqueNum:0];
        self.printData = printData;
        [self showPreviewImage:printData.showCaseImage inMainImageView:self.mainImageView];
        
        
        // Simple Add image Button
        if (self.storeItem.categoryID != StoreTypePhotoPrint || self.storeItem.categoryID != StoreTypePhotoAlbum) {
            [self addSimpleSelectPhotoButton];
        }
        
        // Если фотопечать или альбом, запускаем сохранение
        if (self.storeItem.categoryID == StoreTypePhotoPrint || self.storeItem.categoryID == StoreTypePhotoAlbum) {
            NSDictionary *userInfo = @{SelectAllImagesKey : self.printImages, SelectAllRemoveImagesKey: @[]};
            NSNotification *notification = [NSNotification notificationWithName:@"Local" object:nil userInfo:userInfo];
            [self notificationImagesDidSelected:notification];
        }
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    // Check Rotate
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
    
    // Custom BackButton
    UIImage *image = [UIImage imageNamed:@"prevNavigation"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionBackBarButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [barButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:barButton animated:NO];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"ShowCase.didReceiveMemoryWarning");
    
    //
    if (self.saveProgress == SaveProgressActive) {
        for (ToolIconTheme *iconTheme in self.toolBarScrollView.subviews) {
            if ([iconTheme isKindOfClass:[ToolIconTheme class]]) {
                [iconTheme removeFromSuperview];
            }
        }
    }
}


-(void)dealloc {
    //[self.shadowImageView.layer removeAllAnimations];
    self.isHameleonCloseAnimate = YES;
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Rotate
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
}




#pragma mark - SaveImageManagerDelegate
-(void)saveImageManager:(SaveImageManager *)manager didSaveAllToPrepareFinalSave:(PrintData *)printData
{
    // Все подготовили к сохранению
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop updateTemplateOrPropsPrintData:printData];
    [coreShop finalCompletePrintData:self.printData];
    
    // Alert remove
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:YES];
    
    // GoTo Cart
    [[NSNotificationCenter defaultCenter] postNotificationName:GoToCartSegueNotification object:nil];
}


-(void)saveImageManager:(SaveImageManager *)manager didBigImagesSaved:(PrintImage *)printImage withPrintData:(PrintData *)printData
{
    // Если фотопечать, требуется обрезать
    if ([self isPhotoPrintPurchase:_printData.purchaseID]) {
        [printImage cropPhotPrintWithGrigImage:_printData.gridImage];
        
    } else if (printData.purchaseID == PhotoHousePrintAlbum) {
        [printImage cropImageForDesingAlbum];
        
    } else {
        [printImage cropImageForObjects:printData.gridImage];
    }
    
    NSLog(@"saveImage: %@", printImage.urlLibrary);
    [self addToolManyPrintImages:printImage];
}


-(void)saveImageManager:(SaveImageManager *)manager didAllBigImagesSaved:(PrintData *)printData
{
    //
    NSLog(@"saveAllImage");
    switch (self.saveProgress) {
        case SaveProgressBackgroundActive:
            // Сохранение в фоне закончилось
            self.saveProgress = SaveProgressBackgroundFinish;
            break;
            
        case SaveProgressActive:
            // Переходим в корзину и ничего не показываем
            [self actionCartButton:nil];
            return;
            break;
           
        case SaveProgressWait:
        case SaveProgressBackgroundFinish:
        case SaveProgressFinish:
            break;
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
        //
    
        [self showProgress:0.f withLocalizedText:NSLocalizedString(@"processing", nil) withMode:MBProgressHUDModeIndeterminate];
        
//    });
        //
        PrintImage *printImage = [printData.imagesPreview firstObject];
        [printData createMergedImageWithPreview:printImage.previewImage andCompleteBlock:^(NSArray *images) {
            PrintImage *merged = [printData.mergedImages firstObject];
            [self showPreviewImage:merged.previewImage inMainImageView:self.mainImageView];
            [self chectMugHameleonWithPrintData:self.printData];
            [self hideHud];
        } andProgressBlock:^(CGFloat progress) {
            [self showProgress:progress withLocalizedText:NSLocalizedString(@"processing", nil) withMode:MBProgressHUDModeIndeterminate];
        }];
    
    // Remove
    self.saveManager = nil;
    manager.delegate = nil;
}


-(void)saveImageManager:(SaveImageManager *)manager didCancelSave:(PrintData *)printData
{
    __weak ShowCaseViewController *weakSelf = self;
    CoreDataShopCart *coreShopCart = [[CoreDataShopCart alloc] init];
    [coreShopCart removeFromShopCartUnique:printData.unique_print withBlock:^{
        [weakSelf backToStore];
    }];
}



//- (void)saveImageManager:(SaveImageManager *)manager didReSave:(PrintData *)printData andRemovedPrintImages:(NSArray *)printImages
//{
//    //
////    [manager setDelegate:nil];
////    manager = nil;
//    
//    
//    /// Блок возвращения ссылкок картинок PrintImage -> NSString
//    NSArray* (^GetUrlsLibraryWithPrintImages)(NSArray *) = ^(NSArray *images) {
//        NSMutableArray *urls = [NSMutableArray array];
//        for (PrintImage *pImage in images) {
//            [urls addObject:pImage.urlLibrary];
//        }
//        return [urls copy];
//    };
//    
//    
//    // Сначала удаляем из Корзины заказ
//    CoreDataShopCart *coreShopCart = [[CoreDataShopCart alloc] init];
//    NSArray *urls = GetUrlsLibraryWithPrintImages(printImages ? printImages : printData.imagesPreview);
//    [coreShopCart removeImages:urls];
//    
//    
//    // Удаляем картинки из объекта
//    [self.printData removeImagesWithUrls:urls];
//    
//    
//    // Сохраняем Снова
//    SaveImageManager *saveManager;
//    if (self.printData.imagesPreview.count == 0) {
//        NSLog(@"Save New Images");
//        [self.printData addPrintImagesFromPhotoLibrary:printImages];
//        saveManager = [[SaveImageManager alloc] initManagerWithPrintData:self.printData andDelegate:self orPrintImages:nil];
//    } //else {
//        NSLog(@"Save Add New Images");
//        saveManager = [[SaveImageManager alloc] initManagerWithPrintData:self.printData andDelegate:self orPrintImages:printImages];
//    }
//    
//    //
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [saveManager startSave];
//        self.saveManager = saveManager;
//    });
//    //
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [manager resaveImages:self.printData andPrintImages:self.printData.imagesPreview.count == 0 ? nil : printImages];
//    });
//}


-(void)saveImageManager:(SaveImageManager *)manager didSavedToProgress:(CGFloat)progress
{
    [self.hud setProgress:progress];
}



#pragma mark - Methods
- (void) addSimpleSelectPhotoButton
{
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 53, CGRectGetMidY(self.view.frame) - 35, 107, 70)];
    [addButton setTitle:NSLocalizedString(@"choose_photo", nil) forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"frame"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"TShirtSizeStatic"] forState:UIControlStateNormal];
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12.f];
    [addButton.titleLabel setFont:font];
    
    UIEdgeInsets titleinserts = UIEdgeInsetsMake(34, -29, 0, 0);
    [addButton setTitleEdgeInsets:titleinserts];
    
    UIEdgeInsets imageinset = UIEdgeInsetsMake(-27, 36, 0, 0);
    [addButton setImageEdgeInsets:imageinset];
    [addButton addTarget:self action:@selector(actionAddPhotoButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    self.selectPhotoButton = addButton;
}


- (void) addToolManyPrintImages:(PrintImage *)printImage
{
    // Icon Theme
    if (!self.toolBarScrollView) {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                              CGRectGetHeight(self.view.frame) - 50,
                                                                              CGRectGetWidth(self.view.frame),
                                                                              50)];
        [self.view addSubview:scroll];
        self.toolBarScrollView = scroll;
    }
    
    // Icon
    CGFloat contentWidth = self.toolBarScrollView.contentSize.width;
    ToolIconTheme *tool = [[ToolIconTheme alloc] initWithFrame:CGRectMake(contentWidth == 0 ? 0 : contentWidth + 5, 0, 50, 50)
                                                target:self
                                                action:@selector(tappedFilterPanel:)
                                            printImage:printImage];
    [self.toolBarScrollView addSubview:tool];
    [self.toolBarScrollView setContentSize:CGSizeMake(CGRectGetMinX(tool.frame) + CGRectGetWidth(tool.frame),
                                                      CGRectGetHeight(tool.frame))];
    
    
    // Проверяем, если первая картинка, то ставим на экран и выделяем
    StoreItem *sItem = self.printData.storeItem;
    if ([self isFirstPrintImage] && (sItem.categoryID == StoreTypePhotoAlbum || sItem.categoryID == StoreTypePhotoPrint)) {
        [tool selectedImage];
        [self showPreviewImage:tool.previewImage inMainImageView:self.mainImageView];
    }
    
    
    
    // Если одна картинка, то скрываем ToolBar с иконками
    if (self.printData.imagesPreview.count == 1) {
        [_toolBarScrollView setHidden:YES];
    } else {
        [_toolBarScrollView setHidden:NO];
    }
}


- (void)tappedFilterPanel:(UITapGestureRecognizer*)sender
{
    static BOOL inProgress = NO;
    
    if(inProgress){ return; }
    inProgress = YES;
    
    UIView *view = sender.view;
    
    if ([view isKindOfClass:[ToolIconTheme class]]) {
        
        // Deselect
        for (UIView *viewtheme in _toolBarScrollView.subviews) {
            if ([viewtheme isKindOfClass:[ToolIconTheme class]]) {
                [(ToolIconTheme* )viewtheme deselectedImage];
            }
            
        }
        
        // Select
        ToolIconTheme *tool = (ToolIconTheme *)view;
        [tool selectedImage];
        [self showPreviewImage:tool.previewImage inMainImageView:self.mainImageView];
        inProgress = NO;
    }
}



- (void) showAlertToashWithText:(NSString *)toastText
{
    // ShowToast
    CGPoint point = CGPointMake(CGRectGetMidX(self.view.frame),
                                CGRectGetMidY(self.view.frame));
    [self.view makeToast:toastText
                duration:3
                position:[NSValue valueWithCGPoint:point]
                   title:NSLocalizedString(@"Warning", nil)
                   image:nil];
}

- (void) showAlertTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"no", nil)
                                          otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
    [alert show];
    self.alertView = alert;
}




- (void) showPreviewImage:(UIImage *)image inMainImageView:(UIImageView *)imageView
{
    if (image == nil) {
        return;
    }
    
    imageView.image = image;
    CGSize photSize = image.size;
    
    NSInteger const widthRootView = CGRectGetWidth(self.view.frame) - 10;
    NSInteger const heightRootView = CGRectGetHeight(self.view.frame) - 70 - 50 - (self.printData.imagesPreview.count > 1 ? 50 : 0);
    
    
    CGFloat widthImage = widthRootView;
    CGFloat heightImage = widthImage * photSize.height / photSize.width;
    CGFloat posX = 5;
    CGFloat posY = (heightRootView - heightImage) / 2 + 73;
    
    if (heightImage >= heightRootView) {
        widthImage = heightRootView * photSize.width / photSize.height;
        heightImage = heightRootView;
        
        posX = (widthRootView - widthImage) / 2 + 5;
        posY = 73;
    }
    
    CGRect rectPhoto = CGRectMake(posX, posY, widthImage, heightImage);
    [imageView setFrame:rectPhoto];
    
    [self.shadowImageView setFrame:rectPhoto];
    [self.shadowImageView setHidden:NO];
    //[self showCupHamelionAnimate:self.shadowImageView];
    //[imageView setBackgroundColor:[UIColor redColor]];
}



- (BOOL) isFirstPrintImage {
    NSInteger count = 0;
    
    for (UIView *view in self.toolBarScrollView.subviews) {
        if ([view isKindOfClass:[ToolIconTheme class]]) {
            count++;
        }
    }
    
    return count == 1 ? YES : NO;
}


- (BOOL) isPhotoPrintPurchase:(PhotoHousePrint)photoPrint
{
    if (photoPrint == PhotoHousePrintPhoto8_10 || photoPrint == PhotoHousePrintPhoto10_13 || photoPrint == PhotoHousePrintPhoto10_15 ||
        photoPrint == PhotoHousePrintPhoto13_18 || photoPrint == PhotoHousePrintPhoto15_21 || photoPrint == PhotoHousePrintPhoto20_30) {
        return YES;
    } else {
        return NO;
    }
}



- (PrintImage *) getActivePrintImage
{
    PrintImage *selectImage;
    
    // Выясняем какая из картинок выделена
    for (UIView *view in self.toolBarScrollView.subviews) {
        if ([view isKindOfClass:[ToolIconTheme class]]) {
            ToolIconTheme *iconTheme = (ToolIconTheme *)view;
            if (iconTheme.isSelected) {
                selectImage = iconTheme.printImage;
            }
        }
    }
    
    if (selectImage == nil) {
        for (UIView *view in self.toolBarScrollView.subviews) {
            if ([view isKindOfClass:[ToolIconTheme class]]) {
                ToolIconTheme *iconTheme = (ToolIconTheme *)view;
                [iconTheme selectedImage];
                selectImage = iconTheme.printImage;
                break;
            }
        }
    }
    
    if (selectImage == nil) {
        selectImage = [self.printData.imagesPreview firstObject];
    }

    return selectImage;
}

- (void) backToStore
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showProgress:(CGFloat)progress withLocalizedText:(NSString *)localizedText withMode:(MBProgressHUDMode)mode {
    if (!self.hud) {
        [self setHud:[MBProgressHUD showHUDAddedTo:self.view animated:YES]];
    }
    
    //
    [self.hud setLabelText:localizedText];
    [self.hud setMode:mode];
    [self.hud setProgress:progress];
}

- (void) hideHud {
    [self.hud hide:YES];
}

- (NSString*) analiticsPhotoPrint:(PhotoHousePrint)photoPrint {
   
    NSString *result;
    
    switch (photoPrint) {
        case PhotoHousePrintPhoto8_10:
            result = @"PrintPhoto_8x10";
            break;
            
        case PhotoHousePrintPhoto10_13:
            result = @"PrintPhoto_10x13.5";
            break;
           
        case PhotoHousePrintPhoto10_15:
            result = @"PrintPhoto_10x15";
            break;
            
        case PhotoHousePrintPhoto13_18:
            result = @"PrintPhoto_13x18";
            break;
            
        case PhotoHousePrintPhoto15_21:
            result = @"PrintPhoto_15x21";
            break;
            
        case PhotoHousePrintPhoto20_30:
            result = @"PrintPhoto_20x30";
            break;
            
        case PhotoHousePrintIPhone4:
            result = @"PrintObject IPhone4 Case";
            break;
            
        case PhotoHousePrintIPhone5:
            result = @"PrintObject IPhone5 Case";
            break;
            
        case PhotoHousePrintIPhone6:
            result = @"PrintObject IPhone6 Case";
            break;
            
        case PhotoHousePrintMug:
            result = @"PrintObject Cup";
            break;
            
        case PhotoHousePrintMouseMag:
            result = @"PrintObject Mat";
            break;
            
        case PhotoHousePrintPuzzle:
            result = @"PrintObject Puzzle";
            break;
            
        case PhotoHousePrintTShirt:
            result = @"PrintObject TShirt";
            break;
            
        case PhotoHousePrintAlbum:
            result = @"PrintAlbum Marriage";
            break;
            
        case PhotoHousePrintBrelok:
            result = @"PrintObject Brelok";
            break;
            
        case PhotoHousePrintClock:
            result = @"PrintObject Clock";
            break;
            
        case PhotoHousePrintPlate:
            result = @"PrintObject Plate";
            break;
            
        case PhotoHousePrintMagnit:
            result = @"PrintObject Magnit Collage";
            break;
            
            
        case PhotoHousePrintHolst:
            result = @"PringObject Canvas";
            break;
            
        case PhotoHousePrintDelivery:
            break;
    }
    
    return result;
}




#pragma mark - Notofication
- (void) notificationPhotoEditorDidSave:(NSNotification *)notofication {
    
    
    /// Блок обновления иконки ToolBar, Массив UIScrollView.subviews - массив subview, urlLibrary - адрес которой обновили
    void (^UpdateToolBarIcon)(NSArray *subviews, NSString *urlLibrary) = ^(NSArray *subviews, NSString *urlLibrary) {
        
        for (ToolIconTheme *iconTheme in subviews) {
            // Проверяем класс принадлежит ли объекту
            if ([iconTheme isKindOfClass:[ToolIconTheme class]]) {
                
                // ЕСли совпадает иконка, то обновляем
                if ([iconTheme.printImage.urlLibrary isEqualToString:urlLibrary]) {
                    [iconTheme updateIcon];
                }
            }
        }
    };
    
    
    
    //
    if (_printData.purchaseID == PhotoHousePrintMagnit && [_printData.storeItem.propType.name isEqualToString:@"collage"]) {
        /// Магниты и Магниты-коллаж
        [_printData createMergedImageWithPreview:nil andCompleteBlock:^(NSArray *images) {
            [self showPreviewImage:[[images firstObject] previewImage] inMainImageView:self.mainImageView];
        } andProgressBlock:^(CGFloat progress) {
            [self showProgress:progress withLocalizedText:NSLocalizedString(@"processing", nil) withMode:MBProgressHUDModeIndeterminate];
        }];
        
    }
    else if (_printData.imagesPreview.count > 1)
    {
        // Альбомы
        PrintImage *printImage;
        NSDictionary *userInfo = notofication.object;
        NSString *urlLibrary = [userInfo objectForKey:EditorDidSaveUserInfoKey];
        for (PrintImage *image in self.printData.imagesPreview) {
            if ([image.urlLibrary isEqualToString:urlLibrary]) {
                printImage = image;
                
                // Если статус сохранения не занят, то обновляем
                if(self.saveProgress == SaveProgressBackgroundFinish) {
                    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
                    [coreShop updateAfterEditorPrintData:self.printData andPrintImage:printImage];
                }
            }
        }
        
        //
        UpdateToolBarIcon(self.toolBarScrollView.subviews, urlLibrary);
        
        //
        [self showPreviewImage:printImage.previewImage inMainImageView:self.mainImageView];
    }
    else if (_printData.purchaseID == PhotoHousePrintMug) {
        //Кружки
        [self showProgress:0.f withLocalizedText:NSLocalizedString(@"processing", nil) withMode:MBProgressHUDModeIndeterminate];
        
        PrintImage *printImage = [_printData.imagesPreview firstObject];
        UIImage *filtred = [printImage.editedImageSetting executeImage:printImage.previewImage];
        [_printData createMergedImageWithPreview:filtred andCompleteBlock:^(NSArray *images) {
            PrintImage *merged = [_printData.mergedImages firstObject];
            [self showPreviewImage:merged.previewImage inMainImageView:self.mainImageView];
            [self chectMugHameleonWithPrintData:self.printData];
            [self hideHud];
        } andProgressBlock:^(CGFloat progress) {
            [self showProgress:progress withLocalizedText:NSLocalizedString(@"processing", nil) withMode:MBProgressHUDModeIndeterminate];
        }];

    }
    else
    {
        // Другие заказы
        PrintImage *printImage = [self.printData.mergedImages firstObject];
        [self showPreviewImage:printImage.previewImage inMainImageView:self.mainImageView];
    }
}


- (void) notificationImagesDidSelected:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SelectAllImagesSelectCompleteNotification object:nil];
    
    
    NSDictionary *info = notification.userInfo;
    NSArray *printImages = [info objectForKey:SelectAllImagesKey];
    
    // Change Status Progress
    self.saveProgress = SaveProgressBackgroundActive;
    
    // Если повторно выбрали картинку
    PrintData *printData = self.printData;
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    if (printData.imagesPreview.count > 0 && printData.purchaseID != PhotoHousePrintAlbum &&
                                              printData.purchaseID != PhotoHousePrintPhoto8_10 &&
                                              printData.purchaseID != PhotoHousePrintPhoto20_30 &&
                                              printData.purchaseID != PhotoHousePrintPhoto15_21 &&
                                              printData.purchaseID != PhotoHousePrintPhoto13_18 &&
                                              printData.purchaseID != PhotoHousePrintPhoto10_15)
    {
        // Remove from CoreData
        [coreShop removeFromShopCartUnique:0 withBlock:nil];
        
        // Remove Icons
        [self.toolBarScrollView removeFromSuperview];
        
        // Create New PrintData
        self.printData = [[PrintData alloc] initWithStoreItem:self.storeItem andUniqueNum:0];
    }
    
    // Add Images
    [self.printData addPrintImagesFromPhotoLibrary:printImages];
    [self addToolButtons:self.printData];
    
    // Save
    [coreShop savePrintData:self.printData];
    
    
    //
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Save Images
        SaveImageManager *manager = [[SaveImageManager alloc] initManagerWithPrintData:self.printData andDelegate:self orPrintImages:nil];
        [manager startSave];
        self.saveManager = manager;
    });
    
    
    
    // Remove Select Button
    [self.selectPhotoButton removeFromSuperview];
}

- (void) notificationImagesDidSelectedCancel:(NSNotification *)notification {
    PrintData *printData = self.printData;
    
    /// Фотопечать ли сейчас на экране
    BOOL hasPhotoPrints = printData.storeItem.categoryID == StoreTypePhotoPrint ? YES : NO;
    
    if (self.printData.imagesPreview.count == 0 && hasPhotoPrints) {
        // Фотки не небрали, возвращаемся  еще выше
        [self.navigationController popViewControllerAnimated:NO];
    }
}



#pragma mark - ToolsButtons (Photo, Object, Album)
- (void) addToolButtons:(PrintData *)printData
{
    // Если повторно приходим в этот метод, проходимся по всем View и удаляем ToolMainView
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[ToolMainView class]]) {
            [view removeFromSuperview];
        }
    }
    
    
    NSString *const TOOL_PHOTO_VIEW = @"ToolPhotoView";
    NSString *const TOOL_ALBUM_VIEW = @"ToolAlbumView";
    NSString *const TOOL_OBJECT_VIEW = @"ToolOtherView";
    

    PhotoHousePrint print = printData.purchaseID;
    NSString *toolName;
    switch (print) {
        case PhotoHousePrintAlbum:
        case PhotoHousePrintPhoto10_13:
        case PhotoHousePrintPhoto13_18:
        case PhotoHousePrintPhoto10_15:
        case PhotoHousePrintPhoto15_21:
        case PhotoHousePrintPhoto20_30:
        case PhotoHousePrintPhoto8_10:
            toolName = TOOL_ALBUM_VIEW;
            break;
           
        case PhotoHousePrintMagnit:
        case PhotoHousePrintBrelok:
        case PhotoHousePrintClock:
        case PhotoHousePrintDelivery:
        case PhotoHousePrintHolst:
        case PhotoHousePrintIPhone4:
        case PhotoHousePrintIPhone5:
        case PhotoHousePrintIPhone6:
        case PhotoHousePrintMouseMag:
        case PhotoHousePrintPlate:
        case PhotoHousePrintPuzzle:
        case PhotoHousePrintTShirt:
            toolName = TOOL_PHOTO_VIEW;
            break;
        
        case PhotoHousePrintMug:
            toolName = TOOL_OBJECT_VIEW;
            break;
    }
    
    
    ToolMainView *toolButtons = [[[NSBundle mainBundle] loadNibNamed:toolName owner:self options:nil] objectAtIndex:0];
    CGFloat posY = CGRectGetMaxY(self.view.frame) - (self.printData.imagesPreview.count == 1 ? 36 : 85);
    [toolButtons setDelegate:self];
    [toolButtons setCenter:CGPointMake(CGRectGetMidX(self.view.frame),
                                       posY)];
    [self.view addSubview:toolButtons];
}





#pragma mark - Animate Hameleon Cup
- (void) chectMugHameleonWithPrintData:(PrintData *)printData
{
    PhotoHousePrint purchaseID = printData.purchaseID;
    if (purchaseID == PhotoHousePrintMug && [self.storeItem.propType.name isEqualToString:@"chameleon"]) {
        UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mug_chameleon_a"]];
        [shadow setFrame:self.mainImageView.frame];
        [self.view addSubview:shadow];
        self.shadowImageView = shadow;
        
        self.isHameleonCloseAnimate = NO;
        
        [self showCupHamelionAnimate:shadow];
        [self.shadowImageView setHidden:NO];
    }

}

- (void) showCupHamelionAnimate:(UIImageView*)imgView {
    CGFloat alpha = imgView.alpha;
    
    if (alpha == 0) {
        alpha = 1;
    } else {
        alpha = 0;
    }
    
    //
    self.isHamelionAnimate = YES;
    
    // Animate
    [UIView animateKeyframesWithDuration:3.f
                                   delay:0.f
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear | UIViewKeyframeAnimationOptionAllowUserInteraction
                              animations:^{
                                  //
                                  [imgView setAlpha:alpha];
        
                                }
     
                              completion:^(BOOL finished) {
                                  if (self.isHameleonCloseAnimate) {
                                      return;
                                  }
                                    __weak UIImageView *v = imgView;
                                    [self showCupHamelionAnimate:v];
                                  
                              }];
}





#pragma mark - TShirtSizeDelegate
-(void)tshirt:(TShirtSizeView *)tshirt didChangeSize:(PropSize *)size
{
    // Change
    [self.printData changeProp:size];
    
    //
    if (self.printData.imagesPreview.count == 0) {
        return;
    }
    
    
    // Save To CoreData
    CoreDataShopCart *coreCart = [[CoreDataShopCart alloc] init];
    [coreCart updateTemplateOrPropsPrintData:self.printData];
}




#pragma mark - CupColorDelegate
-(void)cupColorView:(MugColorView *)view didSelectColor:(PropColor *)color
{
    // Change
    [self.printData changeProp:color];
    
    //
    if (self.printData.imagesPreview.count == 0) {
        [self showPreviewImage:self.printData.showCaseImage inMainImageView:self.mainImageView];
        return;
    }
    
    
    // Save To CoreData
    CoreDataShopCart *coreCart = [[CoreDataShopCart alloc] init];
    [coreCart updateTemplateOrPropsPrintData:self.printData];
    
    
    // Draw
    PrintImage *printImage = [self.printData.imagesPreview firstObject];
    [self.printData createMergedImageWithPreview:printImage.previewImage andCompleteBlock:^(NSArray *images) {
        PrintImage *merged = [self.printData.mergedImages firstObject];
        [self showPreviewImage:merged.previewImage inMainImageView:self.mainImageView];
    } andProgressBlock:^(CGFloat progress) {
        [self showProgress:progress withLocalizedText:NSLocalizedString(@"processing", nil) withMode:MBProgressHUDModeIndeterminate];
    }];
}


#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (_saveManager) {
            [_saveManager stopSave];
        } else {
            [self saveImageManager:_saveManager didCancelSave:self.printData];
        }
    }
}


#pragma mark - Actions
- (void)actionAddPhotoButton:(UIButton *)sender
{
    [self addPhoto];
}

- (void)actionCartButton:(UIBarButtonItem *)sender {
    //
    [self.navigationItem setRightBarButtonItem:nil];
//    [self.navigationItem setLeftBarButtonItem:nil];
    
    
    //
    __weak ShowCaseViewController *weakSelf = self;
    void (^PrepareToSave)(void) = ^{
        SaveImageManager *manager = [[SaveImageManager alloc] initFinalSavePrintData:weakSelf.printData andDelegate:weakSelf];
        [manager startSave];
    };
    
    
    
    // Определяем статус
    switch (self.saveProgress) {
        case SaveProgressBackgroundActive:
            // Сохраняли в фоне, переключаем в активную фазу
            self.saveProgress = SaveProgressActive;
            
            // Иницализируем загрузчик
            [self showProgress:0.f withLocalizedText:NSLocalizedString(@"save_to_shop_cart", nil) withMode:MBProgressHUDModeAnnularDeterminate];

            break;
            
        case SaveProgressActive:
        case SaveProgressBackgroundFinish:
        case SaveProgressFinish:
        case SaveProgressWait:
            // Сохранение больших картинок законичилось
            PrepareToSave();
            
            // Иницализируем загрузчик
            [self showProgress:0.f withLocalizedText:NSLocalizedString(@"save_to_shop_cart", nil) withMode:MBProgressHUDModeAnnularDeterminate];
            break;
    }
}


- (void) actionBackBarButton:(UIBarButtonItem *)sender
{
    // Идет ли активное сохранение
    PrintData *pData = self.printData;
    if (pData.purchaseID != PhotoHousePrintAlbum && pData.imagesPreview.count > 0) {
        // Это не альбом, предупреждаем об удалении
        NSString *text = [NSString stringWithFormat:@"%@ %@(%@) %@. %@?",
                          NSLocalizedString(@"if_you_come_back_your", nil),
                          NSLocalizedString(pData.storeItem.categoryName, nil),
                          NSLocalizedString(pData.storeItem.propType.name, nil),
                          NSLocalizedString(@"will_removed", nil),
                          NSLocalizedString(@"do_you_want_come_back", nil)];
        [self showAlertTitle:NSLocalizedString(@"Attention", nil) andMessage:text];
    
    } else if((self.saveProgress == SaveProgressBackgroundActive || self.saveProgress == SaveProgressActive) && pData.purchaseID == PhotoHousePrintAlbum) {
        // Альбом и идет сохранение, просим подождать
        [self showAlertToashWithText:NSLocalizedString(@"You can add images, after all photos will be saved", nil)];
    
    } else {
        // Возвращаем назад
        [self backToStore];
    }
}




#pragma mark - Public Methods
- (void) setPurshaseStoreItem:(StoreItem *)storeItem
{
    self.storeItem = storeItem;
}


- (void) setUnsavedPrintDataStore:(PrintData *)printData
{
    self.printData = printData;
}

- (void)setPhotoPrintItem:(StoreItem *)storeItem andSelectedImages:(NSArray *)images {
    self.storeItem = storeItem;
    self.printImages = images;
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Edit
    if ([segue.destinationViewController isKindOfClass:[EditPhotoViewController class]]) {
        PrintImage *selectImage = [self getActivePrintImage];
        
        // Если картинку редактировали и это Альбом, || ЭТО "ФОТОПЕЧАТЬ",
        // то берем оригинальную картинку из CoreData
        if (([selectImage isDidEdited] && self.printData.purchaseID == PhotoHousePrintAlbum) ||
            [self isPhotoPrintPurchase:_printData.purchaseID] ||
            (self.printData.purchaseID == PhotoHousePrintMagnit && self.printData.imagesPreview.count > 1)) {
            
            // Если активный процесс сохранения, то берем PhotoPrint
            if (self.saveProgress == SaveProgressBackgroundActive) {
                [selectImage updatePreviewImage:selectImage.photoPrintImage];
            } else {
                CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
                selectImage = [coreShop getPreviewImageWithPrintDataUnique:self.printData.unique_print andPrintImage:selectImage];
            }
        }
        
        [segue.destinationViewController printData:self.printData andEditenImage:selectImage];
    }
    
    
    // Album Queue
//    if([segue.destinationViewController isKindOfClass:[AlbumQueueViewController class]]) {
//        //[segue.destinationViewController setSelectedPhotoRecords:self.selectedPhotoRecordArray];
//    }
    
    // Select Photo
    if ([segue.identifier isEqualToString:SEGUE_SELECT_PHOTO]) {
        BOOL coreDataUse = self.saveProgress == SaveProgressBackgroundActive ? YES : NO;
        [segue.destinationViewController setRootStoreItem:self.storeItem andImages:self.printData.imagesNames andCoreDataUse:coreDataUse];
    }
//    if ([segue.destinationViewController isKindOfClass:[SelectNavigationViewController class]]) {
//        NSLog(@"Select");
//    }
    
    // Collage Queue
    /*if([segue.destinationViewController isKindOfClass:[CollageQueueViewController class]]) {
        [segue.destinationViewController setSelectedPhotoRecords:self.selectedPhotoRecordArray];
        self.editController = nil;
    }*/
}


#pragma mark - ToolShowCaseDelegate
- (void)addPhoto
{
    if (self.saveProgress == SaveProgressBackgroundActive) {
        [self showAlertToashWithText:NSLocalizedString(@"You can add images, after all photos will be saved", nil)];
        return;
    }
    
    //
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationImagesDidSelected:) name:SelectAllImagesSelectCompleteNotification object:nil];
    [nc addObserver:self selector:@selector(notificationImagesDidSelectedCancel:) name:SelectAllImagesSelectCancelNotification object:nil];

    //
    [self performSegueWithIdentifier:SEGUE_SELECT_PHOTO sender:self];
}



-(void)editPhoto {
    PrintImage *selectImage = [self getActivePrintImage];
    if (selectImage) {
        [self performSegueWithIdentifier:SEGUE_EDIT_CONTROLLER sender:self];
    }
    
//    [self performSegueWithIdentifier:SEGUE_EDIT_CONTROLLER sender:self];
}



// Flip Horizontal
-(void)rotatePhoto:(FlipToOrientation)orientation
{
    PrintImage *merged = orientation == FlipToRight ? [[self.printData mergedImages] firstObject] : [[self.printData mergedImages] lastObject];
    [self showPreviewImage:merged.previewImage inMainImageView:self.mainImageView];
    
    
    UIImage *blackChameleon = self.shadowImageView.image;
    UIImage* imageMugGlass = [UIImage imageWithCGImage:blackChameleon.CGImage
                                                 scale:blackChameleon.scale
                                           orientation:orientation == FlipToLeft ? UIImageOrientationUpMirrored : UIImageOrientationUp];
    [self.shadowImageView setImage:imageMugGlass];
}

@end
