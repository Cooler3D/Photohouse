//
//  ViewController.m
//  CollectionViewLayout
//
//  Created by Дмитрий Мартынов on 4/23/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreGraphics/CoreGraphics.h>
#import "AssetManager.h"

#import "SelectImagesViewController.h"
#import "SelectImageCell.h"
#import "SelectImagesNotification.h"

#import "SkinModel.h"
#import "AnaliticsModel.h"
#import "DeviceManager.h"

#import "MBProgressHUD.h"

#import "PhotoRecord.h"
#import "ImageDownloader.h"
#import "PendingOperations.h"

#import "UIImage+MinimalSize.h"
#import "UIView+Toast.h"

#import "CoreDataSocialImages.h"
#import "CoreDataShopCart.h"

#import "InstagramAPIModel.h"
#import "VkontakteAPIModel.h"
#import "InstagramAccessToken.h"

#import "StoreItem.h"
#import "PropType.h"
#import "PropStyle.h"
#import "PrintImage.h"

#import "AssetOperation.h"
#import "AssetPendingOperations.h"

#import "AssetImage.h"

#import "MDPhotoLibrary.h"


/// Список Какртинок в каком формате отображать, большом или маленьком.
typedef enum {
    /// Максимальное увеличение
    ScaleSmallImages,
    /// Минимальное увеличение
    ScaleBigImages
} ScaleImagesStatus;




@interface SelectImagesViewController () <UIWebViewDelegate, InstagramSDKDelegate, VKontakteDelegate, ImageDownloaderDelegate, UIScrollViewDelegate, AssetOperationDelegate>
//@property (strong, nonatomic) NSArray *data;

/// Кнопка увеличения картинок
@property (weak, nonatomic) UIButton *scaleButton;

/// Статус увеличения картинок
@property (assign, nonatomic) ScaleImagesStatus scaleStatus;

/// Открытая библиотека
@property (assign, nonatomic) ImportLibrary selectLibrary;

/// Выбранные фотографии ранее
@property (strong, nonatomic, readonly) NSArray *savedUrlNames;

/// Используется ли сейчас доступ к CoreData, Yes-используется, NO-не используется
@property (assign, nonatomic, readonly) BOOL coreDataUse;

/// Панель кнопка переключения библиотек, Phone, Instagram, VK
@property (weak, nonatomic) UIView *controlsView;

/// WebView для показа окна ввода логина и пароля к соц.сетям
@property (weak, nonatomic) UIWebView *webView;

/// Выбранная покупка
@property (strong, nonatomic) StoreItem *storeItem;

/// Массив с PhotoRecord, требующихся для загрузки
@property (strong, nonatomic, readonly) NSMutableArray *photoRecords;

/// Для очереди закачки
@property (nonatomic, strong) PendingOperations *pendingOperations;

/// Для очереди картинок с устройста
@property (nonatomic, strong) AssetPendingOperations *pendingAsset;

/// Прогресс
@property (weak, nonatomic) MBProgressHUD *hud;

/// Кнопки добавляем новые фотографии
@property (weak, nonatomic) UIBarButtonItem *okBautton;


/// Фотобиблиотека, загрузка по частям
@property (strong, nonatomic) MDPhotoLibrary *photoLibrary;
@end



@implementation SelectImagesViewController
{
    NSMutableArray *_instagramRecords;
    NSMutableArray *_vkRecords;
    NSMutableArray *_deviceRecords;
}
@synthesize photoRecords = _photoRecords;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Analitics
    [[AnaliticsModel sharedManager] setScreenName:@"SelectImage"];
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    
    
    // Empty Array
    _instagramRecords   = [NSMutableArray array];
    _vkRecords          = [NSMutableArray array];
    _deviceRecords      = [NSMutableArray array];
    
    
    //
//    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
//    _savedUrlNames = [coreShop getUnsavedURLNamesPrintData:0];
    
    
    // ScaleView
    [self createScaleButtonWithView:self.view andActionTarget:self andSelector:@selector(actionScaleButton:)];
    
    // Controls Buttons
    [self createControlsButtonsView];
    
    
    // Data's
//    NSMutableArray *doubleList = [NSMutableArray array];
//    //
//    for (int column = 0; column<5; column++) {
//        NSMutableArray *list = [NSMutableArray array];
//        for (int row = 0; row < 6; row++) {
//            [list addObject:@"1"];
//        }
//        [doubleList addObject:list];
//    }
//    
//    self.data = doubleList;
    
    
    
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    //
    NSInteger curentSelectCount = self.savedUrlNames.count > 0 ? self.savedUrlNames.count : [self selectedRecordsCount:_photoRecords];
    NSInteger updatedSelected = curentSelectCount;
    [self compareSelectedCount:curentSelectCount andUpdatedSelectedCount:updatedSelected andStoreItem:self.storeItem.propType.selectPropStyle];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    //
    [self calculateFlowLayoutAndEdgeInsetsWithColletction:self.collectionView isFirstStart:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Rotation
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //
    NSLog(@"Orientation: %@", NSStringFromCGSize(self.view.frame.size));
    [self calculateFlowLayoutAndEdgeInsetsWithColletction:self.collectionView isFirstStart:NO];
}




#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.photoRecords count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;//self.data.count;
}



#pragma mark - UICollectionViewDelegate
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"Celler";
    SelectImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifer forIndexPath:indexPath];
    if (!cell) {
        cell = [[SelectImageCell alloc] init];//initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 1: To provide feedback to the user, create a UIActivityIndicatorView and set it as the cellís accessory view.
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.activityIndicatorView = activityIndicatorView;
        
    }
    PhotoRecord *aRecord = [self.photoRecords objectAtIndex:indexPath.row];
    
    // 3: Inspect the PhotoRecord. If its image is downloaded, display the image, the image name, and stop the activity indicator.
    if (aRecord.hasImage) {
        [cell.activityIndicatorView stopAnimating];
        [cell.activityIndicatorView setHidden:YES];
        [cell.selectedIconImageView setHidden:(aRecord.isSelected ? NO : YES)];
        [cell.imageView setImage:aRecord.image];
        [cell.warningImageView setHidden:![aRecord.image isMinimalImageSize:kDefaultMinimalSquare]];
    }
    // 4: If downloading the image has failed, display a placeholder to display the failure, and stop the activity indicator.
    else if (aRecord.isFailed) {
        [((UIActivityIndicatorView *)cell.activityIndicatorView) stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"placehold"];
        NSLog(@"photo Can't load");
    }
    // 5: Otherwise, the image has not been downloaded yet. Start the download and filtering operations (theyíre not yet implemented), and display a placeholder that indicates you are working on it. Start the activity indicator to show user something is going on.
    else {
        
        [((UIActivityIndicatorView *)cell.activityIndicatorView) startAnimating];
        [cell.selectedIconImageView setHidden:YES];
        [cell.warningImageView setHidden:YES];
        cell.imageView.image = [UIImage imageNamed:@"placehold"];
        
        if (!collectionView.dragging && !collectionView.decelerating/* && indexPath.row == 0*/) {
            [self startOperationsForPhotoRecord:aRecord atIndexPath:indexPath];
        }
    }
    
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoRecord *record = [self.photoRecords objectAtIndex:indexPath.row];
    if (!record.hasImage) {
        return;
    }
    
    
    // Если фотография не выбрана, то проверяем
    NSInteger curentSelectCount = [self selectedRecordsCount:_photoRecords];
    NSInteger updatedSelected = curentSelectCount + 1;
    if (!record.selected) {

        BOOL canSelectImage = [self compareSelectedCount:curentSelectCount andUpdatedSelectedCount:updatedSelected andStoreItem:self.storeItem.propType.selectPropStyle];
        if (canSelectImage) {
            record.selected = !record.selected;
        }

    } else {
        // Иначе просто убираем выделение
        curentSelectCount = [self selectedRecordsCount:_photoRecords];
        updatedSelected = curentSelectCount - 1;
        
        [self compareSelectedCount:curentSelectCount andUpdatedSelectedCount:updatedSelected andStoreItem:self.storeItem.propType.selectPropStyle];
        
        record.selected = !record.selected;
    }

    
    // Reload Cell
    NSArray *array = [NSArray arrayWithObject:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:array];
}




#pragma mark - InstagramSDKDelegate
-(void)instagramTokenHasExpired:(InstagramAccessToken *)expiredToken {
    //NSLog(@"token: %@", expiredToken.accessToken);
//#warning ToDo: Choose original
    InstagramAPIModel *model = [InstagramAPIModel sharedManager];//1148431 // 183238952
    [model instagramLoadPhotoArrayWithUserID:expiredToken.user_id orStrongURL:@""]; //
    
    // Remove WebView
    self.webView.delegate = nil;
    [self.webView removeFromSuperview];
}


//The Internet connection appears to be offline.
- (void) instagramPhotoList:(NSArray *)photos {
    
    [self createArrayQueueWithArray:photos];
    
    [self.collectionView reloadData];
    
    //
//    [MBProgressHUD hideHUDForView:self.collectionView animated:YES];
    [self hideProgressView];
}



- (void) instagramShowWebViewWithAnimate {
    // Проверяем
    if (!self.webView.hidden) {
        return;
    }
    
    self.webView.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetHeight(self.parentViewController.view.frame) + CGRectGetMidY(self.webView.frame));
    [self.webView setHidden:NO];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.webView.center = CGPointMake(CGRectGetMidX(self.view.frame),
                                          CGRectGetMidY(self.view.frame) + 54);
    }];
}


- (void) instagramError:(NSString *)errorText {
    // Проверяем есть ли картинки в CoreData
    CoreDataSocialImages *model = [[CoreDataSocialImages alloc] init];
    NSArray *savedRecords = [model getAllImgesWithLibraryType:ImportLibraryInstagram];
    
    //
    if([savedRecords count] == 0) {
        // Сохраненных фото, НЕТ
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    } else {
        // Есть фотографии
//        self.photoRecords = [savedRecords mutableCopy];
//        
//        // Возможно сюда передали массив с выделенными фотографиями
//        for (PhotoRecord *selectedRrecord in _selectedPhotoRecords) {
//            for (PhotoRecord *record in self.photoRecords) {
//                if ([selectedRrecord.name isEqualToString:record.name]) {
//                    [record setImage:selectedRrecord.image];
//                    [record setSelected:YES];
//                }
//            }
//        }
//        
//        
//        // Reload
//        [self.collectionView reloadData];
//        
//        // Remove WebView
//        self.webView.delegate = nil;
//        [self.webView removeFromSuperview];
    }
    
//    [MBProgressHUD hideHUDForView:self.collectionView animated:YES];
    [self hideProgressView];
}




- (void) instagramWebViewDidLoad {
//    [MBProgressHUD hideHUDForView:self.collectionView animated:YES];
    [self hideProgressView];
}



#pragma mark - VKontakteDelegate
- (void) authenticationComplete {
    NSLog(@"authenticationComplete");
    
    [self.webView removeFromSuperview];
}



- (void) vKontaktePhotoList:(NSArray *)photos {
    [self createArrayQueueWithArray:photos];
    [self.collectionView reloadData];
    
    //
    [self vKontakteWebViewDidLoaded];
}



-(void)vKontakteWebViewDidLoaded {
//    [MBProgressHUD hideHUDForView:self.collectionView animated:YES];
    [self hideProgressView];
}



-(void)vKontakteError:(NSString *)errorText {
    
    // Проверяем есть ли картинки в CoreData
    CoreDataSocialImages *model = [[CoreDataSocialImages alloc] init];
    NSArray *savedRecords = [model getAllImgesWithLibraryType:ImportLibraryVKontkte];
    
    //
    if([savedRecords count] == 0) {
        // Сохраненных фото, НЕТ
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attention", nil)
                                                            message:errorText
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        
    } else {
//        self.photoRecords = [savedRecords mutableCopy];
//        
//        // Возможно сюда передали массив с выделенными фотографиями
//        for (PhotoRecord *selectedRrecord in _selectedPhotoRecords) {
//            for (PhotoRecord *record in self.photos) {
//                if ([selectedRrecord.name isEqualToString:record.name]) {
//                    [record setImage:selectedRrecord.image];
//                    [record setSelected:YES];
//                }
//            }
//        }
//        
//        
//        // Reload
//        [self.collectionView reloadData];
//        
//        //
//        [self authenticationComplete];
    }
    
    
    // Hide Preloader
    [self vKontakteWebViewDidLoaded];
}



#pragma mark - Private
- (void) createScaleButtonWithView:(UIView *)mainView andActionTarget:(id)target andSelector:(SEL)selecor
{
    UIView *scaleView = [UIView new];
//    [scaleView setBackgroundColor:[UIColor yellowColor]];
    [scaleView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [mainView addSubview:scaleView];
    NSDictionary *viewsDictionary = @{@"redView":scaleView};
    NSDictionary *metrics = @{@"vSpacing":@45,
                              @"hSpacing":@15,
                              @"sideSize":@50};
    
    // 2. Define the view Position and automatically the Size
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[redView(sideSize)]-vSpacing-|"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:viewsDictionary];
    
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[redView(sideSize)]-hSpacing-|"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:viewsDictionary];
    
    [self.view addConstraints:constraint_POS_V];
    [self.view addConstraints:constraint_POS_H];
    
    
    // Scale Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 50.f, 50.f)];
    [button setBackgroundImage:[UIImage imageNamed:@"scaleUpButton"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionScaleButton:) forControlEvents:UIControlEventTouchUpInside];
    [scaleView addSubview:button];
}


- (void) createControlsButtonsView
{
    // Controls Buttons
    UIView *controlsView = [UIView new];
    [controlsView setBackgroundColor:[UIColor colorWithRed:6/255.f green:28/255.f blue:45/255.f alpha:1.f]];
    [controlsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:controlsView];
    self.controlsView = controlsView;
    
    
    // SocilalView1
    UIButton *phoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [phoneButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [phoneButton setTag:ImportLibraryPhone];
    [phoneButton setTitle:NSLocalizedString(@"device_btn", nil) forState:UIControlStateNormal];
    [phoneButton setBackgroundImage:[UIImage imageNamed:@"libraryButtonBackground"] forState:UIControlStateNormal];
    [phoneButton addTarget:self action:@selector(actionSelectLibraryButton:) forControlEvents:UIControlEventTouchUpInside];
    [controlsView addSubview:phoneButton];
    
    
    // SocilalView2
    UIButton *vkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [vkButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [vkButton setTag:ImportLibraryVKontkte];
    [vkButton setTitle:@"VK" forState:UIControlStateNormal];
    [vkButton setBackgroundImage:[UIImage imageNamed:@"libraryButtonBackground"] forState:UIControlStateNormal];
    [vkButton addTarget:self action:@selector(actionSelectLibraryButton:) forControlEvents:UIControlEventTouchUpInside];
    [controlsView addSubview:vkButton];
    
    
    // SocilalView3
    UIButton *instagramButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [instagramButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [instagramButton setTag:ImportLibraryInstagram];
    [instagramButton setTitle:@"Instagram" forState:UIControlStateNormal];
    [instagramButton setBackgroundImage:[UIImage imageNamed:@"libraryButtonBackground"] forState:UIControlStateNormal];
    [instagramButton addTarget:self action:@selector(actionSelectLibraryButton:) forControlEvents:UIControlEventTouchUpInside];
    [controlsView addSubview:instagramButton];
    
    // Constraits
    [self constraitControlView:controlsView andPhoneButtonView:phoneButton andInastaButtonView:instagramButton andVkButtonView:vkButton];
    
    // Select First
//    DeviceManager *deviceManager = [[DeviceManager alloc] init];
    [self actionSelectLibraryButton:/*[[deviceManager getDeviceName] isEqualToString:IPHONE4] ? vkButton : */phoneButton];
    
    
    
    
    // And NaviationButtons
    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStylePlain target:self action:@selector(actionOkButton:)];
    [okButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:okButton];
    self.okBautton = okButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(actionCancelButton:)];
    [cancelButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}



- (UIWebView *) createWebViewAndAddToControllerView:(UIView *)controllerView
{
    if (self.webView) {
        [self.webView removeFromSuperview];
        self.webView = nil;
    }
    
    UIWebView *webView = [UIWebView new];
    [webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [controllerView addSubview:webView];
    self.webView = webView;
    
    
    
    /// Блок для установки Constraits
    void (^WebViewConstaitsBlock)(UIWebView*) = ^(UIWebView *webView) {
        id topGuide = self.topLayoutGuide;
        NSDictionary *viewsDictionary = @{@"webView":   webView,
                                          @"topGuide":  topGuide};
        
        NSDictionary *metrics = @{@"heightView":@36};
        
        // **********
        // WebView
        NSArray *constraint_main_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide][webView]-heightView-|"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:viewsDictionary];
        
        NSArray *constraint_main_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:viewsDictionary];
        
        [controllerView addConstraints:constraint_main_POS_V];
        [controllerView addConstraints:constraint_main_POS_H];
    };
    
    
    // Animation
//    [UIView animateWithDuration:0.5f animations:^{
        // Status Frame
//        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
//        
//        // Add Status Bar and Navigation Bar heights together
//        CGFloat height = CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight(statusBarFrame) + CGRectGetHeight(self.controlsView.frame);
//        
//        // Position
//        [webView setCenter:CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame) + height)];
    
//    } completion:^(BOOL finished) {
    
        // Start Page
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.ya.ru"]];
//        [webView loadRequest:request];
//        [webView setDelegate:self];
        
        // Constrains
        WebViewConstaitsBlock(webView);
//    }];
    
    return webView;
}



- (void) createArrayQueueWithArray:(NSArray*)photoStringList {
    //
    NSMutableArray *recordlist = [NSMutableArray array];
    
    //
    NSInteger num = 0;
    for (NSString *urlPath in photoStringList) {
        PhotoRecord *record = [[PhotoRecord alloc] initWithSocialURl:urlPath withImage:nil andImportLibrary:self.selectLibrary];//initWithSocialURl:urlPath andImaportLibrary:self.selectLibrary];
        [recordlist addObject:record];
        
        // Возможно фотографии есть и мы догружаем в список
//        NSInteger photosCount = self.photoRecords.count == 0 ? 0 : self.photoRecords.count - 1;
//        PhotoRecord *selectRecord = [self.photoRecords objectAtIndex:(num > photosCount ? photosCount : num)];
//        if (selectRecord) {
//            if ([urlPath isEqualToString:selectRecord.name]) {
//                [record setSelected:selectRecord.selected];
//            }
//        }
        
        // Incleminal
        num++;
        
    }
    
    
    //
    [self addPhotoRecords:recordlist];
    
    
    
    
    
    /*******
     * Сравниваем с предыдущей сессисей если есть
     *******/
    
    /// Блок сравнения загруженной фотографии с сохраненными фотографиями
    BOOL (^CompareBeforeImagesWithDownloadImage)(NSArray *, NSString *) = ^(NSArray *beforeNames, NSString *newImageName) {
        for (NSString *beforeName in beforeNames) {
            if ([beforeName isEqualToString:newImageName]) {
                return YES;
            }
        }
        return NO;
    };
    
    
    // Возможно сюда передали массив с выделенными фотографиями
    for (PhotoRecord *selectedRecord in recordlist) {
        BOOL selected = CompareBeforeImagesWithDownloadImage(_savedUrlNames, selectedRecord.name);
        [selectedRecord setSelected:selected];
    }
}




- (void) calculateFlowLayoutAndEdgeInsetsWithColletction:(UICollectionView *)collectionView isFirstStart:(BOOL)firstStart
{
    // UIEdgeInsets
    CGFloat offsetTop = self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight ? 60 : /*(firstStart ? 40 : */70/*)*/;
    CGFloat offsetLeft = 10.f;
    CGFloat offsetRight = self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight ? 80 : offsetLeft;
    CGFloat offsetBottom = self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight ? 45 : 45;
    UIEdgeInsets inset = UIEdgeInsetsMake(offsetTop, offsetLeft, offsetBottom, offsetRight);
    
    
    
    
    // FlowLayout
    CGSize sizeController = self.view.frame.size;
    CGFloat contentWidth = sizeController.width - inset.right - inset.left;
    CGFloat side = [self getCellSideWithScale:self.scaleStatus andSizeController:sizeController andInterfaceOrientation:self.interfaceOrientation andSContentWidth:contentWidth];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setItemSize:CGSizeMake(side, side)];
    flow.minimumInteritemSpacing = 2.f;
    flow.minimumLineSpacing = 4.f;
    [self.collectionView setCollectionViewLayout:flow];
    
    
    
    [collectionView reloadData];
    [collectionView setContentInset:inset];
}



- (CGFloat) getCellSideWithScale:(ScaleImagesStatus)scaleType andSizeController:(CGSize)controllerSize andInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation andSContentWidth:(CGFloat)contentWidth
{
    NSInteger cellCount;
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        cellCount = (scaleType == ScaleBigImages) ? 3 : 6;
    } else {
        cellCount = (scaleType == ScaleBigImages) ? 2 : 3;
    }
    
    
    CGFloat symmaCells = contentWidth - ((cellCount - 1) * 4);
    CGFloat side = symmaCells / cellCount;
    return side;
}


- (void) deSelectAllContolsButtonsWithView:(UIView *)controlsView andSelectButton:(UIButton *)selectButton
{
    for (UIButton *button in controlsView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button setBackgroundImage:nil forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor colorWithRed:6/255.f green:28/255.f blue:45/255.f alpha:1.f]];
        }
    }
    
    [selectButton setBackgroundColor:[UIColor clearColor]];
    [selectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectButton setBackgroundImage:[UIImage imageNamed:@"libraryButtonBackground"] forState:UIControlStateNormal];
}



/** Сравниваем, можно ли добавлять еще картинки
 *@param currentSelectedCount текущее значение выделенных фотографий
 *@param updatedSelectedCount обновленное значение, которое будет, может быть как больше на 1 или меньше на единицу от currentSelectedCount
 *@param propStyle стиль покупки, для выяснения диапозона
 *@return возвращается YES - можно добавлять, возвращается NO - добавлять нельзя
 */
- (BOOL) compareSelectedCount:(NSInteger)currentSelectedCount andUpdatedSelectedCount:(NSInteger)updatedSelectedCount andStoreItem:(PropStyle *)propStyle
{
//    PropStyle *style = storeItem.propType.selectPropStyle;
    NSRange range = propStyle.rangeImages;
    if (range.location == 0) {
        range = NSMakeRange(1, 0);
    }
//#warning ToDo: Remove
    NSInteger min = range.location;
    NSInteger max = range.length + min;
    
    
    //
//    if (min >= updatedSelectedCount && selectedCount <= max) {
//        //[self.okBarButton setEnabled:NO];
//        return YES;
//    } else if(selectedCount >= max) {
//        
//        // ShowToast
//        [self showAlertToashWithText:[NSString stringWithFormat:@"%@ %li %@. %@", NSLocalizedString(@"You are choosed", nil), (long)max, NSLocalizedString(@"photos", nil), NSLocalizedString(@"This is maximun photos", nil)]];
//        
//        return NO;
//    } else if(selectedCount == 0) {
//        return YES;
//    } else {
////        [self.okBarButton setEnabled:YES];
//    }
    
    BOOL result = NO;
    if (min == max && updatedSelectedCount < min) {
        [self.okBautton setEnabled:NO];
        result = YES;
    } else if (min == max && updatedSelectedCount == max) {
        [self.okBautton setEnabled:YES];
        result = YES;
    } else if (updatedSelectedCount > max) {
        [self showAlertToashWithText:[NSString stringWithFormat:@"%@ %li %@. %@", NSLocalizedString(@"You are choosed", nil), (long)max, NSLocalizedString(@"photos", nil), NSLocalizedString(@"This is maximun photos", nil)]];
        [self.okBautton setEnabled:YES];
        result = NO;
    } else if (min != max && updatedSelectedCount < min) {
        [self.okBautton setEnabled:NO];
        result = YES;
    } else if (min != max && updatedSelectedCount >= min && updatedSelectedCount <= max) {
        [self.okBautton setEnabled:YES];
        result = YES;
    } else if (min != max && updatedSelectedCount > max) {
        [self showAlertToashWithText:[NSString stringWithFormat:@"%@ %li %@. %@", NSLocalizedString(@"You are choosed", nil), (long)max, NSLocalizedString(@"photos", nil), NSLocalizedString(@"This is maximun photos", nil)]];
        [self.okBautton setEnabled:YES];
        result = NO;
    }
    
    
    // Title
    [self showTitleSelected:(result ? updatedSelectedCount : currentSelectedCount) andMinCount:min andMaxCount:max];
    
    return result;
}



- (void) startAutorizationInstagram:(UIWebView *)webView
{
    // Instagram API
    InstagramAPIModel *instagram = [InstagramAPIModel sharedManager];
    instagram.delegate = self;
    [instagram autorizationInWebView:webView];
}


- (void) startAutorizationVkontakte:(UIWebView *)webView
{
    // VK API
    VkontakteAPIModel *vk = [VkontakteAPIModel sharedManager];
    vk.delegate = self;
    [vk autorizationInWebView:webView];
}



- (void) startAutorizeWithDevice
{
    if (!self.photoRecords) {
        [self addPhotoRecords:[NSArray array]];
    }
    
    
    /// Блок сравнения загруженной фотографии с сохраненными фотографиями
    BOOL (^CompareBeforeImagesWithDownloadImage)(NSArray *, NSString *) = ^(NSArray *beforeNames, NSString *newImageName) {
        for (NSString *beforeName in beforeNames) {
            if ([beforeName isEqualToString:newImageName]) {
                return YES;
            }
        }
        return NO;
    };
    
    [self showProgressHud];
    
    if (!_photoLibrary) {
        _photoLibrary = [[MDPhotoLibrary alloc] init];
    }

    [self.photoLibrary loadPhotosAsynchronously:^(NSArray *assets, NSError *error) {
        if (!error) {
            NSMutableArray *records = [NSMutableArray array];
            for (ALAsset *asset in assets) {
                ALAssetRepresentation *representation = asset.defaultRepresentation;
                NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
                
                NSDictionary *metadata = asset.defaultRepresentation.metadata;
                CGSize imageSize = [self.photoLibrary imageSizeWithMetaData:metadata];
                ALAssetOrientation aOrientation = representation.orientation;
                CGSize imageOrientationSize = (aOrientation == ALAssetOrientationLeft || aOrientation == ALAssetOrientationRight) ? CGSizeMake(imageSize.height, imageSize.width) : imageSize;
                
                PhotoRecord *record = [[PhotoRecord alloc] initAssetThumbal:asset.thumbnail andNameUrlLibary:[representation.url absoluteString] andDate:date andImageSize:imageOrientationSize];
                BOOL selected = CompareBeforeImagesWithDownloadImage(_savedUrlNames, record.name);
                [record setSelected:selected];
                [records addObject:record];
            }
            [self sortPhotoWithDate:records];
            
            [self addPhotoRecords:records];
            [self.collectionView reloadData];
        } else {
            NSDictionary *userIndo = error.userInfo;
            [self showAlertToashWithText:[userIndo objectForKey:PHOTO_LIBRARY_ERROR_KEY]];
        }
        
        [self hideProgressView];
    }];

}



- (void) sortPhotoWithDate:(NSMutableArray *)records
{
    if ([records count] > 0) {
        [records sortUsingComparator:^NSComparisonResult(PhotoRecord *obj1, PhotoRecord *obj2) {
            //
            NSDate *date1 = obj1.dateSave;//[obj1.asset valueForProperty:ALAssetPropertyDate];
            NSDate *date2 = obj2.dateSave;//[obj2.asset valueForProperty:ALAssetPropertyDate];
            
            return [date2 compare:date1];
        }];
    }
}



- (void) nextPhotoLoading
{
    if (self.selectLibrary == ImportLibraryInstagram) {
        InstagramAPIModel *instagramApi = [InstagramAPIModel sharedManager];
        [instagramApi setDelegate:self];
        [instagramApi instagramNextPhotosLoad];
    } else if (self.selectLibrary == ImportLibraryVKontkte) {
        VkontakteAPIModel *vkApi = [VkontakteAPIModel sharedManager];
        [vkApi setDelegate:self];
        [vkApi vKontaktePhotosGetAll];
    } else if(self.selectLibrary == ImportLibraryPhone) {
        [self startAutorizeWithDevice];
    }
}



- (void) showTitleSelected:(NSInteger)selectCount andMinCount:(NSInteger)minCount andMaxCount:(NSInteger)maxCount
{
    //
//    selectCount = [self selectedRecordsCount:_photoRecords];
    StoreItem *storeItem = self.storeItem;
    PhotoHousePrint print = (PhotoHousePrint)[storeItem.purchaseID integerValue];
    NSString *title;
    switch (print) {
        case PhotoHousePrintAlbum:
        case PhotoHousePrintPhoto20_30:
        case PhotoHousePrintPhoto15_21:
        case PhotoHousePrintPhoto13_18:
        case PhotoHousePrintPhoto8_10:
        case PhotoHousePrintPhoto10_15:
        case PhotoHousePrintPhoto10_13:
            if (minCount == maxCount) {
                title = [NSString stringWithFormat:@"%lu %@ %lu", (unsigned long)selectCount, NSLocalizedString(@"of", nil), (unsigned long)maxCount];
            } else if(minCount != maxCount) {
               title = [NSString stringWithFormat:@"%lu %@ %lu...%lu", (unsigned long)selectCount, NSLocalizedString(@"of", nil), (unsigned long)minCount, (unsigned long)maxCount];
            }
            break;
            
        default:
            title = NSLocalizedString(@"choose_photo_title", nil);
            break;
    }
    
    //
    self.navigationItem.titleView = [[SkinModel sharedManager] headerForViewControllerWithTitle:title];
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



- (void) showProgressHud
{
    [self hideProgressView];
    
    
    // !!!
    // Добавляем на CollectionView, потому что не будут активны кнопки передключения
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    [hud setLabelText:NSLocalizedString(@"Loading", nil)];
    self.hud = hud;
}


- (void) hideProgressView
{
    if (self.hud) {
        [self.hud hide:YES];
        self.hud = nil;
    }
}


#pragma mark - Records
- (NSArray *) addPhotoRecords:(NSArray *)records
{
    if (!_photoRecords) {
        _photoRecords = [NSMutableArray array];
    }
    
    /// Блок посика PhotoRecord, возможно уже добавлена возвращается YES, Если нету, то NO и нужно добавить
    BOOL (^SearchPhotoRecordNameBlock)(NSArray* curRecords, NSString* searchName) = ^(NSArray* curRecords, NSString* searchName) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", searchName];
        NSArray *array = [curRecords filteredArrayUsingPredicate:predicate];
        BOOL result = [array count] > 0 ? YES : NO;
        return result;
    };
    
    
    // Add
    for (PhotoRecord *newRecord in records) {
        if (!SearchPhotoRecordNameBlock(_photoRecords, newRecord.name)) {
            [_photoRecords addObject:newRecord];
        }
    }
    
    return _photoRecords;
}


-(NSMutableArray *)photoRecords
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"importFromLibrary == %li", (long)self.selectLibrary];
    NSArray *result = [[_photoRecords copy] filteredArrayUsingPredicate:predicate];
    return result.count == 0 ? _photoRecords : [result mutableCopy];
//    NSMutableArray *result;
//    switch (self.selectLibrary) {
//        case ImportLibraryInstagram:
//            result = _instagramRecords;
//            break;
//            
//        case ImportLibraryPhone:
//            result = _vkRecords;
//            break;
//            
//        case ImportLibraryVKontkte:
//            result = _deviceRecords;
//            break;
//    }
//    
//    return result;
}


- (NSInteger) selectedRecordsCount:(NSMutableArray *)records
{
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selected == YES"];
//    NSArray *result = [[_photoRecords copy] filteredArrayUsingPredicate:predicate];
    return [[self selectedRecords:records] count];
}


- (NSArray *) selectedRecords:(NSMutableArray *)records
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selected == YES"];
    NSArray *result = [[_photoRecords copy] filteredArrayUsingPredicate:predicate];
    return result;
}


- (void) replacePhotoRecord:(PhotoRecord *)photoRecord
{
    /// Блок посика PhotoRecord, нужно узнать Index в массиве, для последующей замены
    int (^SearchPhotoRecordNameBlock)(NSMutableArray* curRecords, NSString* searchName) = ^(NSMutableArray* curRecords, NSString* searchName){
        for (int index=0; index<curRecords.count; index++) {
            PhotoRecord *record = (PhotoRecord *)[curRecords objectAtIndex:index];
            if ([record.name isEqualToString:searchName]) {
                return index;
            }
        }
        return -1;
    };

    //
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", photoRecord.name];
    NSArray *result = [[_photoRecords copy] filteredArrayUsingPredicate:predicate];
    PhotoRecord *newRecord = [result firstObject];
    NSInteger index = SearchPhotoRecordNameBlock(_photoRecords, photoRecord.name);
    if (index > -1) {
        [_photoRecords replaceObjectAtIndex:index withObject:newRecord];
    } else {
        NSLog(@"Replace not Found");
    }
}





#pragma mark - Operations

// 1: To keep it simple, you pass in an instance of PhotoRecord that requires operations, along with its indexPath.
- (void)startOperationsForPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    
    // 2: You inspect it to see whether it has an image; if so, then ignore it.
    if (!record.hasImage) {
        
        // 3: If it does not have an image, start downloading the image by calling startImageDownloadingForRecord:atIndexPath: (which will be implemented shortly). Youíll do the same for filtering operations: if the image has not yet been filtered, call startImageFiltrationForRecord:atIndexPath: (which will also be implemented shortly).
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
        
    }
}


- (void)startImageDownloadingForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath {
    if (!self.pendingOperations) {
        self.pendingOperations = [[PendingOperations alloc] init];
    }
    
    // 1: First, check for the particular indexPath to see if there is already an operation in downloadsInProgress for it. If so, ignore it.
//    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
    
        // 2: If not, create an instance of ImageDownloader by using the designated initializer, and set ListViewController as the delegate. Pass in the appropriate indexPath and a pointer to the instance of PhotoRecord, and then add it to the download queue. You also add it to downloadsInProgress to help keep track of things.
        // Start downloading
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self andCoreDataUse:self.coreDataUse];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
//    }
}


//#pragma mark - Asset Operations
//-(void) startAsset:(ALAsset *)asset atIndexPath:(NSIndexPath *)indexPath {
//    if (![self.pendingAsset.asssetInProgress.allKeys containsObject:indexPath]) {
//        AssetOperation *operation = [[AssetOperation alloc] initWithAsset:asset andIndexPath:indexPath andCompareSavedUrls:_savedUrlNames andDelegate:self];
//        [self.pendingAsset.assetQueue addOperation:operation];
//    }
//}

#pragma mark -
#pragma mark - ImageDownloader delegate


- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    if (!self) {
        return;
    }
    
    if (!self.collectionView) {
        return;
    }
    NSLog(@"imageDownloaderDidFinish: %li", (long)downloader.indexPathInTableView.row);
    // 1: Check for the indexPath of the operation, whether it is a download, or filtration.
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    
    
    // 2: Get hold of the PhotoRecord instance.
    PhotoRecord *theRecord = downloader.photoRecord;
    
    // 3: Replace the updated PhotoRecord in the main data source (Photos array).
//    [[self.photoRecords mutableCopy] replaceObjectAtIndex:indexPath.row withObject:theRecord];
    [self replacePhotoRecord:theRecord];
    
    
    // Reload Cell
    NSArray *array = [NSArray arrayWithObject:indexPath];
    [self.collectionView reloadItemsAtIndexPaths:array];
    
    // 5: Remove the operation from downloadsInProgress (or filtrationsInProgress).
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}


#pragma mark - AssetOperationDelegate
-(void)assetOperation:(AssetOperation *)operation didAddImage:(PhotoRecord *)record {
    [self addPhotoRecords:@[record]];
    
    NSIndexPath *indexPath = operation.indexPath;
    // 2
//    if (_photoRecords.count < 50) {
        [self.collectionView reloadData];
//    } else {
//        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
//    }
    
        // 3
    [self.pendingAsset.asssetInProgress removeObjectForKey:indexPath];
}


#pragma mark -
#pragma mark - UIScrollView delegate


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 1: As soon as the user starts scrolling, you will want to suspend all operations and take a look at what the user wants to see.
    [self suspendAllOperations];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 2: If the value of decelerate is NO, that means the user stopped dragging the table view. Therefore you want to resume suspended operations, cancel operations for offscreen cells, and start operations for onscreen cells.
    if (!decelerate) {
        [self loadImagesForOnscreenCells];
        [self resumeAllOperations];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 3: This delegate method tells you that table view stopped scrolling, so you will do the same as in #2.
    [self loadImagesForOnscreenCells];
    [self resumeAllOperations];
    
    if (scrollView.contentOffset.y < scrollView.contentSize.height - scrollView.frame.size.height) {
        //NSLog(@"size: %@", NSStringFromCGSize(scrollView.frame.size));
    }
    else if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
//        InstagramAPIModel *instagramApi = [InstagramAPIModel sharedManager];
//        [instagramApi setDelegate:self];
//        [instagramApi instagramNextPhotosLoad];
        [self nextPhotoLoading];
    }
    
}


#pragma mark -
#pragma mark - Cancelling, suspending, resuming queues / operations


- (void)suspendAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:YES];
    //[self.pendingOperations.filtrationQueue setSuspended:YES];
}


- (void)resumeAllOperations {
    [self.pendingOperations.downloadQueue setSuspended:NO];
    //[self.pendingOperations.filtrationQueue setSuspended:NO];
}


- (void)cancelAllOperations {
    [self.pendingOperations.downloadQueue cancelAllOperations];
    //[self.pendingOperations.filtrationQueue cancelAllOperations];
}


- (void)loadImagesForOnscreenCells {
    
    // 1: Get a set of visible rows.
    NSSet *visibleRows = [NSSet setWithArray:[self.collectionView indexPathsForVisibleItems]];
    
    // 2: Get a set of all pending operations (download and filtration).
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.downloadsInProgress allKeys]];
    //[pendingOperations addObjectsFromArray:[self.pendingOperations.filtrationsInProgress allKeys]];
    
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    // 3: Rows (or indexPaths) that need an operation = visible rows ñ pendings.
    [toBeStarted minusSet:pendingOperations];
    
    // 4: Rows (or indexPaths) that their operations should be cancelled = pendings ñ visible rows.
    [toBeCancelled minusSet:visibleRows];
    
    // 5: Loop through those to be cancelled, cancel them, and remove their reference from PendingOperations.
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        
        ImageDownloader *pendingDownload = [self.pendingOperations.downloadsInProgress objectForKey:anIndexPath];
        [pendingDownload cancel];
        [self.pendingOperations.downloadsInProgress removeObjectForKey:anIndexPath];
        
        /*ImageFiltration *pendingFiltration = [self.pendingOperations.filtrationsInProgress objectForKey:anIndexPath];
         [pendingFiltration cancel];
         [self.pendingOperations.filtrationsInProgress removeObjectForKey:anIndexPath];*/
    }
    toBeCancelled = nil;
    
    // 6: Loop through those to be started, and call startOperationsForPhotoRecord:atIndexPath: for each.
    for (NSIndexPath *anIndexPath in toBeStarted) {
        
        PhotoRecord *recordToProcess = [self.photoRecords objectAtIndex:anIndexPath.row];
        [self startOperationsForPhotoRecord:recordToProcess atIndexPath:anIndexPath];
    }
    toBeStarted = nil;
    
}


#pragma mark - Public
- (void) setStoreItemInit:(StoreItem *)storeItem andImages:(NSArray *)unsavedUrls andCoreDataUse:(BOOL)coreDataUse
{
    self.storeItem  = storeItem;
    _savedUrlNames  = unsavedUrls;
    _coreDataUse    = coreDataUse;
}


#pragma mark - SocialConstraits
- (void) constraitControlView:(UIView *)constolView andPhoneButtonView:(UIView *)phoneView andInastaButtonView:(UIView *)instagramButtonView andVkButtonView:(UIView *)vkButtonView
{
    id topGuide = self.topLayoutGuide;
    NSDictionary *viewsDictionary = @{@"phoneView":     phoneView,
                                      @"instaView":     instagramButtonView,
                                      @"vkView":        vkButtonView,
                                      @"controlsView":  constolView,
                                      @"topGuide":      topGuide};
    
    NSDictionary *metrics = @{@"topSpacing":@60,
                              @"hSpacing":@5,
                              @"heightView":@36,
                              @"widthView":@103,
                              @"heightButton":@26};
    
    // **********
    // Control
    NSArray *constraint_main_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[controlsView(heightView)]|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewsDictionary];
    
    NSArray *constraint_main_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[controlsView]|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewsDictionary];
    
    [self.view addConstraints:constraint_main_POS_V];
    [self.view addConstraints:constraint_main_POS_H];
    // *********
    
    
    
    // *********
    // Phone
    NSArray *constraint_btn1_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[phoneView(heightButton)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewsDictionary];
    
    NSArray *constraint_btn1_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hSpacing-[phoneView(widthView)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewsDictionary];
    
    [self.view addConstraints:constraint_btn1_POS_V];
    [self.view addConstraints:constraint_btn1_POS_H];
    // ********
    
    
    
    // ********
    // VK
    NSArray *constraint_btn2_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[vkView(heightButton)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewsDictionary];
    
    NSArray *constraint_btn2_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[vkView(widthView)]-hSpacing-|"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewsDictionary];
    
    [self.view addConstraints:constraint_btn2_POS_V];
    [self.view addConstraints:constraint_btn2_POS_H];
    // *********
    
    
    
    
    
    // **********
    // Instagram
    NSArray *constraint_btn3_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[instaView(heightButton)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewsDictionary];
    
    NSArray *constraint_btn3_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[instaView(widthView)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:viewsDictionary];
    
    [self.view addConstraints:constraint_btn3_POS_V];
    [self.view addConstraints:constraint_btn3_POS_H];
    
    [constolView addConstraint:[NSLayoutConstraint constraintWithItem:instagramButtonView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:constolView
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:0.0]];
    
    [constolView addConstraint:[NSLayoutConstraint constraintWithItem:instagramButtonView
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:constolView
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:0.0]];
    // ***********

}



#pragma mark - Actions
- (void) actionScaleButton:(UIButton *)sender
{
    UIImage *imageButton;
    if (self.scaleStatus == ScaleBigImages) {
        self.scaleStatus = ScaleSmallImages;
        imageButton = [UIImage imageNamed:@"scaleUpButton"];
    } else {
        self.scaleStatus = ScaleBigImages;
        imageButton = [UIImage imageNamed:@"scaleDownButton"];
    }
    [sender setImage:imageButton forState:UIControlStateNormal];
    
    [self calculateFlowLayoutAndEdgeInsetsWithColletction:self.collectionView isFirstStart:NO];
}



- (void) actionSelectLibraryButton:(UIButton *)sender
{
    [self deSelectAllContolsButtonsWithView:self.controlsView andSelectButton:sender];
    NSLog(@"Select Lib");
    
    
    
    // Cancel All Downloads
    [self cancelAllOperations];
    
    
    // Hide
    [self hideProgressView];
    
    
    // !!!
    // Делаем прозрачность 0.5f, т.к при медленном интернете и долго показывается пустой экран
    UIWebView *webView = [self createWebViewAndAddToControllerView:self.view];
//    [webView setAlpha:0.5f];
    self.webView = webView;
    
    //
    [self.collectionView scrollsToTop];
    
    NSString *openLib;
    
    self.selectLibrary = (ImportLibrary)sender.tag;
    switch ((ImportLibrary)sender.tag) {
        case ImportLibraryPhone:
            [self.webView removeFromSuperview];
            [self startAutorizeWithDevice];
            openLib = @"Device Photos";
            break;
            
        case ImportLibraryInstagram:
            [self startAutorizationInstagram:webView];
            openLib = @"instagram Photos";
            break;
            
        case ImportLibraryVKontkte:
            [self startAutorizationVkontakte:webView];
            openLib = @"VKontakte Photos";
            break;
    }
    
    //
    if (self.selectLibrary != ImportLibraryPhone) {
        [self showProgressHud];
    }
    
    // Analitisc open Device
    [[AnaliticsModel sharedManager] sendEventCategory:@"SelectImage" andAction:@"OpenLib" andLabel:openLib withValue:nil];
}


- (void) actionOkButton:(UIBarButtonItem *)sender
{
    // Cancel All Downloads
    [self cancelAllOperations];
    
    
    
    /// Блок сравнения можно ли добавить, а так же сравнить с уже добавленными. Если не найдено, ответ придет NO, если есть, то ответ придет YES. Передаем массив "Старых имен", текущее имя которое проверяем, и новые добаленные элементы
    BOOL (^SearchImageBlock)(NSArray *, NSString *, NSMutableArray*) = ^(NSArray *savedNames, NSString *currentRecordName, NSMutableArray *alsoAddedPrintImages) {
        BOOL result = NO;
        
        // Сравниваем с выделенными
        for (NSString *url in savedNames) {
            if ([url isEqualToString:currentRecordName]) {
                result = YES;
            }
        }
        
        
        // Сравниваем с уже добавленными в массив
        for (PrintImage *printImage in alsoAddedPrintImages) {
            if ([printImage.urlLibrary isEqualToString:currentRecordName]) {
                return YES;
            }
        }
        
        return result;
    };

    
    
    /// Блок получения PrintImage из PhotoRecord
    PrintImage* (^GetPrintImageWithRecordBlock)(PhotoRecord*) = ^(PhotoRecord *record) {
        MDPhotoLibrary *lib = [[MDPhotoLibrary alloc] init];
        [lib getAssetWithURL:record.name withResultBlock:^(NSData *imageData, UIImageOrientation orientation) {
            NSLog(@"AssetOrientation: %i", (int)orientation);
        } failBlock:nil];
        
        PrintImage *printImage = [[PrintImage alloc] initWithPreviewImage:record.image withName:record.name andEditSetting:nil originalSize:record.imageSize andUploadUrl:nil];
        return printImage;
    };
    
    
    
    // Создаем PrintImage по выделенным PhotoRecord
    NSArray *selected = [self selectedRecords:_photoRecords];
    NSMutableArray *result = [NSMutableArray array];
    
    if (_savedUrlNames.count == 0) {
        // Массив ранее выбранных пустой, Просто добавляем
        for (PhotoRecord *record in selected) {
            PrintImage *printImage = GetPrintImageWithRecordBlock(record);
            [result addObject:printImage];
        }
    
    } else {
        //
        for (PhotoRecord *record in selected) {
            if (!SearchImageBlock(_savedUrlNames, record.name, result)) {
                PrintImage *printImage = GetPrintImageWithRecordBlock(record);
                [result addObject:printImage];

            }
        }
    }
    
    
    
    //
    [self dismissViewControllerAnimated:YES completion:^{
        NSDictionary *dictionary = @{SelectAllImagesKey: result, SelectAllRemoveImagesKey: @[]};
        NSNotification *notification = [NSNotification notificationWithName:SelectAllImagesSelectCompleteNotification object:nil userInfo:dictionary];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        //
        NSLog(@"Select Close");
    }];
}

- (void) actionCancelButton:(UIBarButtonItem *)sender
{
    // Cancel All Downloads
    [self cancelAllOperations];
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSNotification *notification = [NSNotification notificationWithName:SelectAllImagesSelectCancelNotification object:nil userInfo:@{}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
}

#pragma mark - Property
-(AssetPendingOperations *)pendingAsset {
    if (!_pendingAsset) {
        _pendingAsset = [[AssetPendingOperations alloc] init];
    }
    return _pendingAsset;
}
@end
