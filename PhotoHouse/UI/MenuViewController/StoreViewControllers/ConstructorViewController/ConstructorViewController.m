//
//  ViewController.m
//  AlbumConstructor
//
//  Created by Дмитрий Мартынов on 4/9/15.
//  Copyright (c) 2015 Individual. All rights reserved.
//

#import "ConstructorViewController.h"
#import "LayoutsTableViewController.h"
#import "SelectNavigationViewController.h"
#import "EditPhotoViewController.h"
#import "EditPhotoConstructorViewController.h"
#import "SelectImagesNotification.h"

#import "UIImage+Crop.h"
#import "UIViewController+Size.h"
#import "UIView+Toast.h"

#import "BundleDefault.h"
#import "PhouseApi.h"

#import "PageView.h"

#import "Template.h"
#import "Layout.h"
#import "Layer.h"
#import "Image.h"

#import "LayoutToolView.h"

#import "PrintData.h"
#import "PrintImage.h"

#import "SaveImageManager.h"
#import "CoreDataShopCart.h"
#import "CoreDataStore.h"

#import "ToolIconTheme.h"

#import "DrawGridView.h"
#import "SelectAlbumImage.h"

#import "AnaliticsModel.h"
#import "SkinModel.h"

#import "StoreItem.h"
#import "PropType.h"
#import "PropUturn.h"
#import "PropSize.h"
#import "PropStyle.h"

#import "MBProgressHud.h"

#import "PHAppNotifications.h"


typedef enum{
    StatusImages,     // Открыт список картинок
    StatusLayouts     // Открыт список стилей
} StatusList;


NSString *const SEGUE_SHOOSE_STYLE = @"segue_choose_style";
NSString *const SEGUE_CHOOSE_IMAGE = @"segue_selectImage";
NSString *const SEGUE_EDIT_CONSTRUCTOR = @"segue_edit_constructor";


static CGFloat kAnimationTime = 0.3f;


@interface ConstructorViewController () <UIAlertViewDelegate, SaveImageManagerDelegate, SelectAlbumImageDelegate>
@property (weak, nonatomic) UIScrollView *layoutsScrollView; // Скролл для верстки
@property (weak, nonatomic) UIScrollView *imagesScrollView;  // Скролл для выбранных фотографий
@property (weak, nonatomic) PageView *pageView;

@property (assign, nonatomic) StatusList statusScrollOpened; // Какой из скроллов открыт
@property (assign, nonatomic) SaveProgressStatus saveProgress;      // Сохранение в фоне

@property (strong, nonatomic) NSArray *pages;               // Массив с PageView
@property (strong, nonatomic) PrintData *printData;

@property (strong, nonatomic) PrintImage *editPrintImage;   // Для редактора
@property (assign, nonatomic) CGFloat editAspectRatio;

@property (weak, nonatomic) UIButton *addImageToolBar;      // Кнопка рядом со imagesScrollView
@property (weak, nonatomic) MBProgressHUD *hud;             // ProgressBar

/// Количество разворотов, доступных послендний раз при нехватке памяти
@property (assign, nonatomic) NSInteger pagesCountMemoryWarning;

@property (strong, nonatomic) SaveImageManager *saveManager;    ///< Сохранение картинок в CoreData

@property (strong, nonatomic) NSArray *originalLayoutsPages;     ///< Массив стандартных layout для выбора стилей
@end


@implementation ConstructorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    // Analitics
    [[AnaliticsModel sharedManager] setScreenName:@"AlbumConstructor Screen"];
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    
    
    // BackGround
    [self createBlueBackground];
    [self.view setBackgroundColor:[model headerColorWithViewController]];
    
    
    // Notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationTemplateDownloadComplete:) name:TemplateDownloadComplateNotification object:nil];   // Успешно загруженны верска шаблона
    [nc addObserver:self selector:@selector(notificationTemplateProgressComplete:) name:TemplateDownloadProgressNotification object:nil];   // Прогресс загрузки верски
    [nc addObserver:self selector:@selector(notificationTemplateDownloadError:) name:TemplateDownloadErrorNotification object:nil];         // Ошибка загрузки верски
    [nc addObserver:self selector:@selector(notificationAddLayout:) name:LayoutChooseNotification object:nil];      // Выбран стиль из всех шаблонов
    [nc addObserver:self selector:@selector(notificationAddImages:) name:ImagesOpenNotification object:nil];        // Открыть список картинок для добавления
    [nc addObserver:self selector:@selector(notificationSelectImageOnPageView:) name:ImageSelectNotification object:nil];   // Выбрали картинку на развороте альбома
//    [nc addObserver:self selector:@selector(notificationRemoveImage:) name:ImageRemoveOnPageNotification object:nil];       // Удалить картинку из разворота
    [nc addObserver:self selector:@selector(notificationActionAddPage:) name:AddPageNotification object:nil];       // Добавляем страницу
    [nc addObserver:self selector:@selector(notificationRemovePage:) name:RemovePageNotification object:nil];       // Очищаем страницу
//    [nc addObserver:self selector:@selector(notificationEditPage:) name:ImagesEditNotification object:nil];               // Редактируем картинку
    [nc addObserver:self selector:@selector(notificationImagesDidSelected:) name:SelectAllImagesSelectCompleteNotification object:nil];   // Выбор картинок
    [nc addObserver:self selector:@selector(notificationPhotoEditorDidSave:) name:EditorDidSaveNotification object:nil];            // редактирование закончено
    
    [self createScrollViews];
    
    
    //CoreDataAlbumConstructor *coreConstructor = [[CoreDataAlbumConstructor alloc] init];
//    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
//    PrintData *unsaved = [coreShop getUnSavedPrintData];
//    if (unsaved) {
//        // Открываем сохраненное
//        _printData = unsaved;
//        Template *userTemplate = unsaved.storeItem.propType.userTemplate;
//        [self createSyncPagesWithUserTemplate:userTemplate andPrintData:self.printData];
//    } else {
//        // Новый шаблон
//        Template *template = self.printData.storeItem.propType.selectTemplate;
//        if ([template hasImageDesign]) {
//            // Картинки Верстки есть, поазываем пользователю
//            Layout *layoutCover = template.layoutCover;
//            [self createPageViewWithSelectLayout:layoutCover andTemplate:template andPageIndex:0];
//        } else {
//            // Картинок нету, ожидаем загрузки
//            if (!self.hud) {
//                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                [hud setProgress:0.f];
//                [hud setMode:MBProgressHUDModeAnnularDeterminate];
//                [hud setLabelText:NSLocalizedString(@"Loading", nil)];
//                self.hud = hud;
//            } else {
//                [self.hud setProgress:0.f];
//            }
//
//            
//            [template downloadImages];
//        }
//    }
    
    // Пробуем считать пользовательский шаблон
    Template *userTemplate = self.printData.storeItem.propType.userTemplate;
    if (userTemplate && userTemplate.layouts.count > 0) {
        // Значит продолжам не сохраненный шаблон
        [self createSyncPagesWithUserTemplate:userTemplate andPrintData:self.printData];
    } else {
        // Создаем новый
        Template *template = self.printData.storeItem.propType.selectTemplate;
        
        // Возможно не так сохранилось, сохраняем в CoreData по умолчанию и считываем снова
        if (template == nil) {
            PHouseApi *pApi = [[PHouseApi alloc] init];
            [pApi saveDefaultTemplates];
            template = self.printData.storeItem.propType.selectTemplate;
        }
        
        
        // Есть ли картинки
        if ([template hasImageDesign]) {
            // Картинки Верстки есть, поазываем пользователю
            Layout *layoutCover = template.layoutCover;
            [self createPageViewWithSelectLayout:layoutCover andTemplate:template andPageIndex:0];
            self.originalLayoutsPages = template.layoutPages;
        } else {
            // Картинок нету, ожидаем загрузки
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            [hud setProgress:0.f];
//            [hud setMode:MBProgressHUDModeAnnularDeterminate];
//            [hud setLabelText:NSLocalizedString(@"Loading", nil)];
//            self.hud = hud;
            [self showProgressHud];
            
            // Загружаем
            [template downloadImages];
        }
    }
    
    //
    self.statusScrollOpened = StatusLayouts;
    
    
    // Swipe
//    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToRemovePage:)];
//    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionUp];
//    [self.view addGestureRecognizer:swipeGesture];
//    
//    // Tap
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
//    [self.view addGestureRecognizer:tapGesture];
    
    //
    UIBarButtonItem *shopCartButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"add_to_cart", nil)
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(actionCartButton:)];
    [shopCartButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:shopCartButton];

}



- (void)viewDidAppear:(BOOL)animated
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    
    
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
    
    
    // Если есть картинки и не идет процесс сохранения, то готовим к синхронизации
    if (self.pages.count > 0 && (self.saveProgress == SaveProgressBackgroundFinish || self.saveProgress == SaveProgressFinish))
    {
        static BOOL inProgressSync = NO;
        
        if(inProgressSync || self.pagesCountMemoryWarning == self.pages.count){ return; }
        inProgressSync = YES;

        NSLog(@"Constructor.didReceiveMemoryWarning.Prepare To Sync");
        
        // Prepare
        [self prepareToSynchonizePages:self.pages afterSyncExecuteCompleteBlock:^{
            inProgressSync = NO;
            self.pagesCountMemoryWarning = self.pages.count;
        }];
    }
}






-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}


#pragma mark - Notification
- (void) notificationTemplateDownloadComplete:(NSNotification *)notification
{
    // Remove Notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TemplateDownloadComplateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TemplateDownloadProgressNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TemplateDownloadErrorNotification object:nil];
    
    // Read
    NSDictionary *userInfo = notification.userInfo;
    Template *template = [userInfo objectForKey:TemplateKey];
    Layout *layoutCover = template.layoutCover;
    [self createPageViewWithSelectLayout:layoutCover andTemplate:template andPageIndex:0];
    self.originalLayoutsPages = template.layoutPages;
    
    
    // Sync CoreData
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    [coreStore synchorizeTemplateAfterDowloadImages:template
                                      andPurchaseID:self.printData.storeItem.purchaseID
                                    andPropTypeName:self.printData.storeItem.propType.name
                                       TemplateSize:self.printData.storeItem.propType.selectTemplate.size
                                    andTemplateName:self.printData.storeItem.propType.selectTemplate.name];
    
    // Progress
    [self hideProgressView];
}


- (void) notificationTemplateProgressComplete:(NSNotification *)notification
{
    //
    NSDictionary *userInfo = notification.userInfo;
    CGFloat progress = [[userInfo objectForKey:TemplateProgressKey] floatValue];
    
    if (!self.hud) {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        [hud setProgress:progress];
//        [hud setMode:MBProgressHUDModeAnnularDeterminate];
//        [hud setLabelText:NSLocalizedString(@"Loading", nil)];
//        self.hud = hud;
        [self showProgressHud];
    } else {
        [self.hud setProgress:progress];
    }
}


- (void) notificationTemplateDownloadError:(NSNotification *)notification
{
    //
    NSDictionary *userInfo = notification.userInfo;
    NSString *text = [userInfo objectForKey:TemplateErrorKey];
    Template *template = [userInfo objectForKey:TemplateKey];
    
    
    // Hide Hub
    [self hideProgressView];
    
    
    // Sync CoreData
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    [coreStore synchorizeTemplateAfterDowloadImages:template
                                      andPurchaseID:self.printData.storeItem.purchaseID
                                    andPropTypeName:self.printData.storeItem.propType.name
                                       TemplateSize:self.printData.storeItem.propType.selectTemplate.size
                                    andTemplateName:self.printData.storeItem.propType.selectTemplate.name];
    
    
    // Aler
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"warning", nil)
                                                    message:text
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"continue", nil)
                                          otherButtonTitles:NSLocalizedString(@"try_else", nil), nil];
    [alert show];
}



- (void) notificationAddLayout:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    Layout *userInfoLayout = [userInfo objectForKey:LayoutChooseKey];
    Layout *layout = [self copyLayout:userInfoLayout];
    
    //
    [self animationHideScrollImages:self.imagesScrollView];
    
    // Блок для поиска оригинального Template
    Template* (^GetTemplateLayoutViewBlock)(NSArray *) = ^(NSArray *layoutsView) {
        Template *template;
        for (LayoutToolView *layoutView in layoutsView) {
            if ([layoutView isKindOfClass:[LayoutToolView class]]) {
                template = [layoutView getTepmpate];
                break;
            }
        }
        return template;
    };
    
    Template *template = GetTemplateLayoutViewBlock(self.layoutsScrollView.subviews);
    NSInteger pageIndex = self.pageView.pageIndex + 1;
    [self createPageViewWithSelectLayout:layout andTemplate:template andPageIndex:pageIndex];
}



- (void) notificationAddImages:(NSNotification *)notification
{
    // Блок поиска картинок в ScrollView
    BOOL (^IsEqualsImageInScrollBlock)(UIScrollView *imageScrollView) = ^(UIScrollView *imageScrollView) {
        
        for (ToolIconTheme *toolTheme in imageScrollView.subviews) {
            if ([toolTheme isKindOfClass:[ToolIconTheme class]]) {
                return YES;
            }
        }
        
        return NO;
    };
    
    
    // Open Select
    if (!IsEqualsImageInScrollBlock(self.imagesScrollView)) {
        [self performSegueWithIdentifier:SEGUE_CHOOSE_IMAGE sender:self];
    }
    
    
    // Animate Omages
    if (self.statusScrollOpened == StatusLayouts) {
        [self animationHideScrolllayouts:self.layoutsScrollView];
        self.statusScrollOpened = StatusImages;
    }
    
    
    // Синхронизируем картинки на разворотах и ToolBar, чтобы правильно проставить галочки выбранных, а то бывает сбиваются
    NSMutableArray *allUrls = [NSMutableArray array];
    for (PageView *pageView in self.pages) {
        for (NSString *url in pageView.imagesUrls) {
            [allUrls addObject:url];
        }
    }
    [self synchronizePagesImagesURLs:[allUrls copy] withToolImages:self.imagesScrollView.subviews];
}




- (void) notificationSelectImageOnPageView:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    PrintImage *printImage = [userInfo objectForKey:ImagePrintKey];
    self.editPrintImage = printImage;
    
    CGRect editRect = [[userInfo objectForKey:ImageRectKey] CGRectValue];
    self.editAspectRatio = CGRectGetWidth(editRect) / CGRectGetHeight(editRect);
    
    NSValue *value = [userInfo objectForKey:ImagesSelectKey];
    CGRect selectRectInPage = [value CGRectValue];  // Прямоугольник внизу
    
    CGRect rectInMain = CGRectMake(CGRectGetMinX(self.pageView.frame) + CGRectGetMinX(selectRectInPage),
                                   CGRectGetMinY(self.pageView.frame) + CGRectGetMinY(selectRectInPage),
                                   CGRectGetWidth(selectRectInPage),
                                   CGRectGetHeight(selectRectInPage));

    [self animateSelectImagePrintImage:printImage inStartRect:rectInMain];
}



//- (void) notificationRemoveImage:(NSNotification *)notification
//{
//    NSDictionary *userInfo = notification.userInfo;
//    NSString *urlLibrary = [userInfo objectForKey:ImageUrlLibraryKey];
//    
//    [self removeImageWithUrlLibrary:urlLibrary onImagesScrollView:self.imagesScrollView];
//    
    // Deselect
//    for (ToolIconTheme *imageTheme in self.imagesScrollView.subviews) {
//        if ([imageTheme isKindOfClass:[ToolIconTheme class]]) {
//            if ([imageTheme.printImage.urlLibrary isEqualToString:urlLibrary]) {
//                [imageTheme deselectedImage];
//            }
//        }
//    }
//}


- (void) notificationActionAddPage:(NSNotification *)notification
{
//    NSDictionary *userInfo = notification.userInfo;
//    NSInteger pageIndex = [[userInfo objectForKey:RemovePageKey] integerValue];
//    [self removeAlbumPageWithIndex:pageIndex];
    
    
    // Блок для подсчета кол-ва разворотов в конструкторе, если > uturn, то возвращаем NO
    BOOL (^CompareUturnBlock)(PrintData *, NSArray *) = ^(PrintData *printData, NSArray *layoutViews) {
        
        NSUInteger count = 0;
        for (LayoutToolView *layoutView in layoutViews) {
            if ([layoutView isKindOfClass:[LayoutToolView class]]) {
                count++;
            }
        }
        
        NSInteger coverCount = 1; // доп. стараница, обложка
        NSInteger uturn = [printData.storeItem.propType.selectPropUturn.uturn integerValue];
        if (count >= uturn + coverCount) {
            return NO;
        } else {
            return YES;
        }
    };
    
    
    if (CompareUturnBlock(self.printData, self.layoutsScrollView.subviews)) {
        [self performSegueWithIdentifier:SEGUE_SHOOSE_STYLE sender:self];
    }
}



- (void) notificationRemovePage:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSInteger pageIndex = [[userInfo objectForKey:RemovePageKey] integerValue];
    [self removeAlbumPageWithIndex:pageIndex];
}



//- (void) notificationEditPage:(NSNotification *)notification
//{
//    NSDictionary *userInfo = notification.userInfo;
//    CGRect rect =  [[userInfo objectForKey:ImageRectKey] CGRectValue];
//    PrintImage *printImage = [userInfo objectForKey:ImagePrintKey];
//    self.editPrintImage = printImage;
//    self.editAspectRatio = (float)CGRectGetWidth(rect) / (float)CGRectGetHeight(rect);
//    
//    [self performSegueWithIdentifier:SEGUE_EDIT_CONSTRUCTOR sender:self];
//}



- (void) notificationImagesDidSelected:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SelectAllImagesSelectCompleteNotification object:nil];
    
    
    NSDictionary *info = notification.userInfo;
    NSArray *printImages = [info objectForKey:SelectAllImagesKey];
    
    // Add Images
    //BOOL addElseImage = printData.imagesPreview.count == 0 ? NO : YES;
    [self.printData addPrintImagesFromPhotoLibrary:printImages];
    
//    PrintData *printData = self.printData;
    //
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop savePrintData:self.printData];
    
    //
    self.saveProgress = SaveProgressBackgroundActive;
    
    
    //
    __weak ConstructorViewController *wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Save Images
        wSelf.saveProgress = SaveProgressBackgroundActive;
        SaveImageManager *manager = [[SaveImageManager alloc] initManagerWithPrintData:self.printData andDelegate:self orPrintImages:nil];
        [manager startSave];
        
        wSelf.saveManager = manager;
    });
}


- (void) notificationPhotoEditorDidSave:(NSNotification *)notofication
{
    // Альбомы
    PrintImage *printImage;
    NSDictionary *userInfo = notofication.object;
    NSString *urlLibrary = [userInfo objectForKey:EditorDidSaveUserInfoKey];
    for (PrintImage *image in self.printData.imagesPreview) {
        if ([image.urlLibrary isEqualToString:urlLibrary]) {
            printImage = image;
        }
    }
    
    if (!printImage) {
        return;
    }
    
    [self.pageView importImage:printImage];
    
    
    
    // Sync
    [self synchronizePreviewPagesView:self.pages andLayoutTools:self.layoutsScrollView.subviews];
}





#pragma mark - Rotate
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //
    CGFloat heightScroll = CGRectGetHeight(self.layoutsScrollView.frame);
    CGSize sizeController = [self sizeViewController];
    // Layout
    CGRect layoutRect = CGRectMake(4.f,
                                   sizeController.height + ((self.statusScrollOpened == StatusLayouts) ? -heightScroll : +heightScroll),
                                   sizeController.width - 8.f,
                                   heightScroll);
    [self.layoutsScrollView setFrame:layoutRect];
    
    
    
    // Images
    CGRect imagesRect = CGRectMake(CGRectGetMinX(layoutRect),
                                   sizeController.height + ((self.statusScrollOpened == StatusLayouts) ? +heightScroll : -heightScroll),
                                   sizeController.width - heightScroll - 8.f,
                                   heightScroll);
    [self.imagesScrollView setFrame:imagesRect];
    
    
    CGRect rectAddImageButton = CGRectMake(sizeController.width - heightScroll,
                                           CGRectGetMinY(imagesRect) + 2.f,
                                           heightScroll - 4.f,
                                           heightScroll - 4.f);
    [self.addImageToolBar setFrame:rectAddImageButton];
    
    
    //
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    }
}



/*#pragma mark - Gesture
- (void) handleSwipeToRemovePage:(UISwipeGestureRecognizer *)swipeGesture
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Предупреждение" message:@"Вы действительно хотите очистить данный разворот?" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Очистить", nil];
    [alert show];
}


- (void) handleTapGesture:(UITapGestureRecognizer *)gesture
{
    for (LayoutToolView *layoutView in self.layoutsScrollView.subviews) {
        if ([layoutView isKindOfClass:[LayoutToolView class]]) {
            [layoutView hideRemovePageButtons];
        }
    }
}*/




#pragma mark - Methods
- (void) createSyncPagesWithUserTemplate:(Template *)userTemplate andPrintData:(PrintData *)printData
{
    // Создаем страницы с ToolBar
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    PropSize *size = printData.storeItem.propType.selectPropSize;
    PropStyle *style = printData.storeItem.propType.selectPropStyle;
    Template *originalTemplate = [coreStore getTemplateWithPurchaseID:[NSString stringWithFormat:@"%li", (long)printData.purchaseID]
                                                      andPropTypeName:TypeNameConstructor
                                                         TemplateSize:size.sizeName
                                                      andTemplateName:style.styleName];
    for (Layout *layout in userTemplate.layouts) {
        [self createPageViewWithSelectLayout:layout andTemplate:originalTemplate andPageIndex:layout.pageIndex];
    }
    
    
    // Создаем картинки, если есть
    //[self animationShowScrollImages:self.imagesScrollView];
    //[self performSelector:@selector(animationShowScrollLayouts:) withObject:self.layoutsScrollView afterDelay:0.5f];
    for (PrintImage *printImage in printData.imagesPreview) {
        [self addPrintImage:printImage inScrollView:self.imagesScrollView];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
    // После добавление картинок в ImageToolScrollView, помечаем добавленные картинки на развороты
    // Блок поиска urlLibrary во всех активных страницах
    BOOL (^SearchImagesInPages)(NSArray *, PrintImage *) = ^(NSArray *pages, PrintImage *printImage){
        for (PageView *pageView in pages) {
            BOOL search = [pageView compaseSyncPrintImage:printImage];
            if (search) {
                return search;
            }
        }
        
        return NO;
    };
    
    // Перебирвем
    for (ToolIconTheme *icon in self.imagesScrollView.subviews) {
        if ([icon isKindOfClass:[ToolIconTheme class]]) {
            if (SearchImagesInPages(self.pages, icon.printImage)) {
                [icon selectedImage];
            }
        }
    }
    });
}



- (void) createBlueBackground
{
    UIView *blueBackground = [[UIView alloc] initWithFrame:CGRectMake(4.f, 4.f, CGRectGetWidth(self.view.frame) - 8.f, CGRectGetHeight(self.view.frame) - 8.f)];
    [blueBackground setBackgroundColor:[UIColor colorWithRed:49.f/255.f green:162.f/255.f blue:208.f/255.f alpha:1.f]];
    blueBackground.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:blueBackground];
    NSDictionary *viewsDictionary = @{@"blueBackground":blueBackground};
    NSDictionary *metrics = @{@"vSpacing":@4, @"hSpacing":@4};
    
    // 2. Define the view Position and automatically the Size
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vSpacing-[blueBackground]-vSpacing-|"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:viewsDictionary];
    
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hSpacing-[blueBackground]-hSpacing-|"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:viewsDictionary];
    
    [self.view addConstraints:constraint_POS_V];
    [self.view addConstraints:constraint_POS_H];
}



- (void) createScrollViews
{
    // BackGround
    CGFloat scrollHeight = 50.f;
    UIColor *color = [UIColor colorWithRed:6.f/255.f green:28.f/255.f blue:45.f/255.f alpha:1];
    [self createToolBarForScrollViewColor:color andHeightView:scrollHeight];
    
    
    
    // Images Scroll
    CGSize sizeController = [self sizeViewController];
    UIScrollView *imagesScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f,
                                                                                sizeController.height - scrollHeight,
                                                                                sizeController.width,
                                                                                scrollHeight)];
    [self.view addSubview:imagesScroll];
    self.imagesScrollView = imagesScroll;
    
    
    
    // Layout Scroll
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, sizeController.height - scrollHeight,
                                                                          sizeController.width,
                                                                          scrollHeight)];
    [self.view addSubview:scroll];
    self.layoutsScrollView = scroll;
    
    
    
    // Add Button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"addImageTool"];
    [button setFrame:CGRectMake(CGRectGetWidth(self.view.frame) - scrollHeight, CGRectGetHeight(self.view.frame) - scrollHeight, scrollHeight, scrollHeight)];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionAddImages:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.addImageToolBar = button;
}



- (void)createToolBarForScrollViewColor:(UIColor *)color andHeightView:(CGFloat)height
{
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 70.f, 100.f, 50.f, 50.f)];
    [redView setBackgroundColor:color];
    [redView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:redView];

    
    // 1. Create a dictionary of views and metrics
    NSDictionary *viewsDictionary = @{@"redView":redView};
    NSDictionary *metrics = @{@"vSpacing":@0,
                              @"hSpacing":@0,
                              @"redHeight": [NSNumber numberWithFloat:height]
                              };
    
    // 2. Define the view Position and automatically the Size
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[redView(redHeight)]-vSpacing-|"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:viewsDictionary];
    
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hSpacing-[redView]-hSpacing-|"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:viewsDictionary];
    
    [self.view addConstraints:constraint_POS_V];
    [self.view addConstraints:constraint_POS_H];
}


- (void) createPageViewWithSelectLayout:(Layout *)selectLayout andTemplate:(Template *)template andPageIndex:(NSUInteger)pageIndex
{
    // Меняем значения месталми, т.к Контроллер еще не перевернулся,
    // Проверяем, ширина всегда должна быть больше выстоты, т.к устройство перевернуто влево
    CGSize controllerSize = CGRectGetWidth(self.view.frame) > CGRectGetHeight(self.view.frame) ? self.view.frame.size : CGSizeMake(CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame));
    
    // Высота шапки StatusBar + NavigationBar
    CGFloat navigationBarHeight = 64.f;
    
    //CGFloat offset = 42.f + 14.f + 7.f; // Ширина кнопки + отступ кнопки + отступ от кнопки на начала разворота(Дизайн)
    CGSize mainViewSize = CGSizeMake(controllerSize.width/* - (offset * 2)*/,
                                     controllerSize.height - navigationBarHeight - CGRectGetHeight(self.layoutsScrollView.frame) - 2.f);
    
    CGRect mainViewRect = CGRectMake((controllerSize.width - mainViewSize.width) / 2,
                                     navigationBarHeight,
                                     mainViewSize.width,
                                     mainViewSize.height - 7.f);
    PageView *pageView = [[PageView alloc] initWithFrame:mainViewRect andLayout:selectLayout andPageIndex:pageIndex];
    [self addPageView:pageView andTemplate:template andPageIndex:pageIndex];
    
    
    // Обновляем Title
    [self updateTitleControllerWithPageIndex:pageIndex];
    
    
    // Sync Layouts and Pages
    [self synchronizePreviewPagesView:self.pages andLayoutTools:self.layoutsScrollView.subviews];
}




- (void) addPageView:(PageView *)pageView andTemplate:(Template *)template andPageIndex:(NSUInteger)pageIndex
{
    // Блок для смещения всех LayoutToolView
    // Начинаем смещать после PageIndex на величину offsetX
    void (^OffsetLayoutToolViewsBlock)(NSArray *, NSInteger, CGFloat) = ^(NSArray *layoutToolViews, NSInteger pageIndex, CGFloat offsetX) {
        
        NSInteger numPage = pageIndex + 1;
        
        for (LayoutToolView *layoutTool in self.layoutsScrollView.subviews) {
            if ([layoutTool isKindOfClass:[LayoutToolView class]]) {
                if (layoutTool.pageIndex >= pageIndex) {
                    [layoutTool updatePageIndex:numPage];
                    [layoutTool setFrame:CGRectMake(CGRectGetMinX(layoutTool.frame) + offsetX,
                                                    CGRectGetMinY(layoutTool.frame),
                                                    CGRectGetWidth(layoutTool.frame),
                                                    CGRectGetHeight(layoutTool.frame))];
                    numPage++;
                }
            }
        }
    };
    
    
    // Add To Scroll
    UIScrollView *scroll = self.layoutsScrollView;
    CGFloat contentWidth = scroll.contentSize.width;    // Ширина контента
    CGSize layoutFinalSize = CGSizeMake(128.f + 44.f, 50.f);   // Финальные размеры LayoutToolView
    CGFloat delta = 5.f;                                // Отступ
    CGFloat offsetContent = contentWidth + delta;       // Следующая картинка будет на 5 пикс. больше
    CGFloat offsetOneContent = layoutFinalSize.width + delta; // Ширина одной Layout +  отступ
    
    
    CGRect rect = CGRectMake(pageIndex == 0 ? 0 : contentWidth, 0.f, layoutFinalSize.width, layoutFinalSize.height);
    
    
    // Если мы пытаемся вставить страницу между двух
    if (pageIndex < self.pages.count) {
        // Смещаем все LayoutToolView
        OffsetLayoutToolViewsBlock(scroll.subviews, pageIndex, offsetOneContent);
        
        // Обновляем значения rect
        rect = CGRectMake(offsetOneContent * pageIndex, CGRectGetMinY(rect), CGRectGetWidth(rect), CGRectGetHeight(rect));
    }
    
    
    // Создаем
    LayoutToolView *tool = [[LayoutToolView alloc] initWithFrame:rect
                                                  andTapSelector:@selector(tappedLayout:)
                                                       andtarget:self
                                                     andTemplate:template
                                                 andSelectLayout:pageView.layout
                                                    andPageIndex:pageIndex];
    [scroll addSubview:tool];
    
    [scroll setContentSize:CGSizeMake(offsetContent/*CGRectGetMinX(tool.frame)*/ + CGRectGetWidth(tool.frame),
                                      CGRectGetHeight(tool.frame))];
    
    
    
    
    // Добавляем в массив Pages
    NSMutableArray *pagesCopy = !self.pages ? [NSMutableArray array] : [self.pages mutableCopy];
    if (pagesCopy.count == 0) {
        [pagesCopy addObject:pageView];
    } else {
        [pagesCopy insertObject:pageView atIndex:pageIndex];
    }
    self.pages = [pagesCopy copy];
    
    
    
    // Обновляем страницы, чтобы соответствовало массиву pages
    NSInteger pageNum = 0;
    for (PageView *pageView in self.pages) {
        [pageView updatePageIndex:pageNum];
        pageNum++;
    }
    
//    NSArray *pags = self.pages;
//    NSArray *lays = self.layoutsScrollView.subviews;
    
    
    // Add In View
    [self addPageView:pageView inControllerView:self.view];
}



- (void) addPrintImage:(PrintImage *)printImage inScrollView:(UIScrollView *)imagesScrollView
{
//#warning ToDo: Проверять на добавление фотографии
    // Icon Theme
    if (!imagesScrollView) {
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.layoutsScrollView.frame];
        [scroll setBackgroundColor:[UIColor grayColor]];
        [self.view addSubview:scroll];
        self.imagesScrollView = scroll;
        
        [self animationShowScrollImages:scroll];
    }
    //PrintData *printData = self.printData;
    
    
    
    // Icon
    CGFloat contentWidth = imagesScrollView.contentSize.width;
    CGRect rect = CGRectMake(contentWidth == 0 ? 0 : contentWidth + 5.f, 0.f, 46.f, 46.f);
    //NSLog(@"rect: %@", NSStringFromCGRect(rect));
    ToolIconTheme *tool = [[ToolIconTheme alloc] initWithFrame:rect
                                                        target:self
                                                        action:@selector(tappedImageToolBar:)
                                                    printImage:printImage];
    //if (!found) {
        [imagesScrollView addSubview:tool];
    //}
    [imagesScrollView setContentSize:CGSizeMake(CGRectGetMinX(tool.frame) + CGRectGetWidth(tool.frame),
                                                CGRectGetHeight(tool.frame))];
    //NSLog(@"Size: %@", NSStringFromCGSize(imagesScrollView.contentSize));
    
}



/*! Считаем и отображем Progress замолняемости фотографиями разворота
 *@param layoutView массив LayoutToolView на палени разворотов, нужно проверить в массиве могкт быть не все элементы типа LayoutToolView
 */
- (void) calculateProgessWithLayouts:(NSArray *)layoutViews
{
    // Блок поиска PageView по номеру страницы
    PageView* (^FindPageViewBlock)(NSInteger pageIndex, NSArray *pages) = ^(NSInteger pageIndex, NSArray *pages) {
        for (PageView *pageView in pages) {
            if (pageView.pageIndex == pageIndex) {
                return pageView;
            }
        }
        return [[PageView alloc] initWithFrame:CGRectZero];
    };
    
    
    // Проходим по списку
    for (LayoutToolView *layoutView in layoutViews) {
        if ([layoutView isKindOfClass:[LayoutToolView class]]) {
            
            PageView *pageView = FindPageViewBlock(layoutView.pageIndex, self.pages);
            
            CGFloat progress = pageView.progress;
            [layoutView setProgressImportImages:progress];
        }
    }
}



/*! Получаем выделенный(активный) layoutTool с которым последний раз взаимодействовал пользователь
 *@param layoutViews массив layoutToolView, может содержать и другие объекты
 *@return возвращаем последний выбранный элемент
 */
- (LayoutToolView *) getSelectedLayoutToolViewWithArray:(NSArray *)layoutViews
{
    LayoutToolView *selectLayoutToolView;
    
    for (LayoutToolView *layoutView in layoutViews) {
        if ([layoutView isKindOfClass:[LayoutToolView class]]) {
            if (layoutView.hasSelected) {
                selectLayoutToolView = layoutView;
                break;
            }
        }
    }
    
    return selectLayoutToolView;
}



/// Делаем копию Layout
- (Layout *)copyLayout:(Layout *)layout {
    
    NSMutableArray *imageBack = [NSMutableArray array];
    for (Image *image in layout.backLayer.images) {
        Image *ig = [[Image alloc] initWithPixelsMin:image.pixelsMin
                                      andPixelsLimit:image.pixelsLimit
                                                andZ:image.z
                                         andUrlImage:image.url_image
                                        andUrlUpload:image.url_upload
                                        andPermanent:image.permanent
                                             andRect:image.rect
                                             andCrop:image.crop
                                            andImage:image.image andImageOrientation:image.orientation andImageOrientationDefault:image.orientationDefault];
        [imageBack addObject:ig];
    }
    
    
    Layer *layerBack = [[Layer alloc] initWithImage:layout.backLayer.image andImages:[imageBack copy]];
    Layer *layerFront = [[Layer alloc] initWithImage:layout.frontLayer.image andImages:nil];
    Layer *layerClear = [[Layer alloc] initWithImage:layout.clearLayer.image andImages:nil];
    Layout *result = [[Layout alloc] initLayoutWithID:layout.id_layout
                                     andLayoutType:layout.layoutType
                                    andtemplatePSD:layout.template_psd
                                      andBackLayer:layerBack
                                     andFlontLayer:layerFront
                                     andClearLayer:layerClear
                                      andPageIndex:layout.pageIndex
                                  andCombinedLayer:layout.combinedLayer
                           andNoscaleCombinedLayer:layout.noscaleCombinedLayer];
    
    return result;
}




- (void) addPageView:(PageView *)pageView inControllerView:(UIView *)controllerView
{
    // Remove
    if (self.pageView) {
        [self.pageView removeFromSuperview];
    }
    
    // Add
    [controllerView addSubview:pageView];
    self.pageView = pageView;
}




- (void) removeAlbumPageWithIndex:(NSInteger)pageIndex
{
    // Блок для смещения всех LayoutToolView
    // Начинаем смещать в сторону уменьшения после PageIndex на величину offsetX
    void (^OffsetLayoutToolViewsBlock)(NSArray *, NSInteger, CGFloat) = ^(NSArray *layoutToolViews, NSInteger pageIndex, CGFloat offsetX) {
        
        NSInteger numPage = pageIndex;
        
        for (LayoutToolView *layoutTool in self.layoutsScrollView.subviews) {
            if ([layoutTool isKindOfClass:[LayoutToolView class]]) {
                if (layoutTool.pageIndex >= pageIndex) {
                    [layoutTool updatePageIndex:numPage];
                    [layoutTool setFrame:CGRectMake(CGRectGetMinX(layoutTool.frame) - offsetX,
                                                    CGRectGetMinY(layoutTool.frame),
                                                    CGRectGetWidth(layoutTool.frame),
                                                    CGRectGetHeight(layoutTool.frame))];
                    numPage++;
                }
            }
        }
    };
    
    
    
    
    // Блок поиска LayoutToolView по PageIndex
    LayoutToolView* (^SearchLayoutToolViewWithPageImadexBlock)(NSArray *, NSInteger) = ^(NSArray *layoutToolViews, NSInteger pageIndex) {
        LayoutToolView *layoutToolView;
        
        for (LayoutToolView *layoutView in layoutToolViews) {
            if ([layoutView isKindOfClass:[LayoutToolView class]]) {
                if (layoutView.pageIndex == pageIndex) {
                    layoutToolView = layoutView;
                    break;
                }
            }
        }
        
        return layoutToolView;
    };
    
    
    // Блок, удаления встроенных картинок по urlLibary из удалаемой страницы
    void (^RemoveUrlLibraryBlock)(NSArray*) = ^(NSArray *urlLibrarys) {
        for (NSString *url in urlLibrarys) {
            [self removeImageWithUrlLibrary:url onImagesScrollView:self.imagesScrollView];
        }
    };
    
    
    // Удаляем
    LayoutToolView *tool = SearchLayoutToolViewWithPageImadexBlock(self.layoutsScrollView.subviews, pageIndex);
    [tool clearLayout];
    //[tool removeFromSuperview];
    
    
    
    // Удаляем в массиве Pages
    PageView *currentPageView = [self.pages objectAtIndex:pageIndex];
    NSArray *removeUrls = [currentPageView removePage];
    RemoveUrlLibraryBlock(removeUrls);
    
    NSMutableArray *pagesCopy = [self.pages mutableCopy];
    [pagesCopy removeObjectAtIndex:pageIndex];
    self.pages = [pagesCopy copy];
    
    [self.pageView removeFromSuperview];
    
    // Открываем предыдущую страницу
    PageView *pageView = [self.pages objectAtIndex:pageIndex - 1];
    [self addPageView:pageView inControllerView:self.view];
    
    
    
    // Обновляем страницы, чтобы соответствовало массиву pages
    NSInteger pageNum = 0;
    for (PageView *pageView in self.pages) {
        [pageView updatePageIndex:pageNum];
        pageNum++;
    }


    
    // Add To Scroll
    UIScrollView *scroll = self.layoutsScrollView;
    CGFloat contentWidth = scroll.contentSize.width;    // Ширина контента
    CGSize layoutFinalSize = CGSizeMake(128.f + 44.f, 50.f);   // Финальные размеры LayoutToolView
    CGFloat delta = 5.f;                                // Отступ
    CGFloat offsetContent = contentWidth + delta;       // Следующая картинка будет на 5 пикс. больше
    CGFloat offsetOneContent = layoutFinalSize.width + delta; // Ширина одной Layout +  отступ
    OffsetLayoutToolViewsBlock(scroll.subviews, pageIndex, offsetOneContent);
    
        
    
    //NSLog(@"ContentSize: %@", NSStringFromCGSize(scroll.contentSize));
    [scroll setContentSize:CGSizeMake(offsetContent/*CGRectGetMinX(tool.frame)*/ - offsetOneContent,
                                      layoutFinalSize.height)];
}



- (void) removeImageWithUrlLibrary:(NSString *)urlLibrary onImagesScrollView:(UIScrollView *)imagesScrollView {
    if (!urlLibrary || [urlLibrary isEqualToString:@""]) {
        return;
    }
    
    for (ToolIconTheme *imageTheme in imagesScrollView.subviews) {
        if ([imageTheme isKindOfClass:[ToolIconTheme class]]) {
            if ([imageTheme.printImage.urlLibrary isEqualToString:urlLibrary]) {
                [imageTheme deselectedImage];
                [imageTheme.printImage.editedImageSetting clearEdited];
            }
        }
    }
}


/** Синхронизируем Pages и layoutToolView для предпросмотра
 *@param pages массив PageView для сбора всех PreviweImage
 *@param layoutTools массив LayoutToolView от маленьких на ToolBar
 */
- (void) synchronizePreviewPagesView:(NSArray *)pages andLayoutTools:(NSArray *)layoutTools
{
    /// Блок поиска PageView по PageIndex
    PageView* (^GetPageViewBlock)(NSArray*, NSInteger) = ^(NSArray *pagesView, NSInteger pageIndex) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pageIndex == %li", (long)pageIndex];
        PageView *page = [[[pagesView mutableCopy] filteredArrayUsingPredicate:predicate] firstObject];
        return page;
    };
    
    // Make Screen
    for (LayoutToolView *layoutTool in layoutTools) {
        if ([layoutTool isKindOfClass:[LayoutToolView class]]) {
            PageView *currentPage = GetPageViewBlock(pages, layoutTool.pageIndex);
            [layoutTool updatePreviewImage:currentPage.previewLayout];
        }
    }
}



- (void) synchronizePagesToShopCart:(NSArray *)pages
{
    NSMutableArray *layouts = [NSMutableArray array];

    for (PageView *pageView in pages) {
        Layout *selectLayout = [[Layout alloc] initLayoutWithID:pageView.layout.id_layout
                                                  andLayoutType:pageView.layout.layoutType
                                                 andtemplatePSD:pageView.layout.template_psd
                                                   andBackLayer:pageView.layout.backLayer
                                                  andFlontLayer:pageView.layout.frontLayer
                                                  andClearLayer:pageView.layout.clearLayer
                                                   andPageIndex:pageView.pageIndex
                                               andCombinedLayer:pageView.layout.combinedLayer
                                        andNoscaleCombinedLayer:pageView.layout.noscaleCombinedLayer];//pageView.layout;
        [layouts addObject:selectLayout];
    }
    
    
    Template *template = [self template];
    Template *userTemplate = [[Template alloc] initTemplateName:template.name
                                                    andFontName:template.fontName
                                                  andIdTemplate:template.id_template
                                                        andSize:template.size
                                                     andLayouts:[layouts copy]];
    
    [self.printData updateUserTemplate:userTemplate];
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop updateTemplateOrPropsPrintData:self.printData];
}



/** Синхронизируем картинки на страницах и картинки в ToolBar
 *@param urls массив строк зартинок страниц
 *@param imageTools массив объектов (Метод будет проверять на соответствие классу ToolIconTheme
 */
- (void) synchronizePagesImagesURLs:(NSArray *)urls withToolImages:(NSArray *)imageTools
{
    /// Блок поиска картинки(ToolIconImage) в списке адресов на странице
    BOOL (^SearchSearchToolImageInPagegesUrls)(NSString*, NSArray*) = ^(NSString *toolImageUrl, NSArray *pagesUrls) {
        for (NSString *pageImageUrl in pagesUrls) {
            if ([pageImageUrl isEqualToString:toolImageUrl]) {
                return YES;
            }
        }
        return NO;
    };
    
    
    // Ищем сравнения
    for (ToolIconTheme *imageTool in imageTools) {
        if ([imageTool isKindOfClass:[ToolIconTheme class]]) {
            if (SearchSearchToolImageInPagegesUrls(imageTool.printImage.urlLibrary, urls)) {
                [imageTool selectedImage];
            }
        }
    }
}





- (void) updateTitleControllerWithPageIndex:(NSInteger)pageIndex {
    if (pageIndex == 0) {
        self.navigationItem.titleView = [[SkinModel sharedManager] headerForViewControllerWithTitle:NSLocalizedString(@"CoverMagazine", nil)];
    } else {
        NSString *flipper = NSLocalizedString(@"flip", nil);
        PropUturn *uturn = self.printData.storeItem.propType.selectPropUturn;
        NSString *title = [NSString stringWithFormat:@"%@ %li %@ %@", flipper, (long)pageIndex, NSLocalizedString(@"of", nil), uturn.uturn];
        self.navigationItem.titleView = [[SkinModel sharedManager] headerForViewControllerWithTitle:title];
    }
}


- (void) showAlertTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
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
    [hud setMode:MBProgressHUDModeAnnularDeterminate];
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

- (void) backToStore
{
    [self.navigationController popViewControllerAnimated:YES];
}


/** Подготовка к синхронизации, после завершения вызовется Блок
 *@param pages массив pageView
 *@param completeBlock блок исполнения после синхронизации
 */
- (void) prepareToSynchonizePages:(NSArray *)pages afterSyncExecuteCompleteBlock:(void(^)())completeBlock
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:NSLocalizedString(@"synchonize_to_cart", nil)];
    self.hud = hud;
    
    __weak ConstructorViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf synchronizePagesToShopCart:weakSelf.pages];
        [weakSelf.hud hide:YES];
        
        if (completeBlock) {
            completeBlock();
        }
    });
}


#pragma mark - Animation
- (void) animationHideScrollImages:(UIScrollView *)imagesScrollView
{
    [UIView animateWithDuration:kAnimationTime
                     animations:^{
                         
                         //
                         CGPoint pointStyleList = CGPointMake(CGRectGetMidX(imagesScrollView.frame),
                                                              CGRectGetMidY(imagesScrollView.frame) + CGRectGetHeight(imagesScrollView.frame));
                         [imagesScrollView setCenter:pointStyleList];
                         
                         CGPoint buttonCenter = CGPointMake(CGRectGetWidth(self.view.frame) - CGRectGetMidX(self.addImageToolBar.bounds) - 4.f, pointStyleList.y);
                         [self.addImageToolBar setCenter:buttonCenter];
                     }
                     completion:^(BOOL finished) {
                         
                         //
                         [self animationShowScrollLayouts:self.layoutsScrollView];
                     }];

}



- (void) animationHideScrolllayouts:(UIScrollView *)layoutsScrollView
{
    // Прячем layout
    [UIView animateWithDuration:kAnimationTime
                     animations:^{
                         
                         //
                         CGPoint pointStyleList = CGPointMake(CGRectGetMidX(layoutsScrollView.frame),
                                                              CGRectGetMidY(layoutsScrollView.frame) + CGRectGetHeight(layoutsScrollView.frame));
                         [layoutsScrollView setCenter:pointStyleList];
                     }
                     completion:^(BOOL finished) {
                         
                         //
                         [self animationShowScrollImages:self.imagesScrollView];
                     }];

}



- (void) animationShowScrollImages:(UIScrollView *)imagesScrollView {
    [UIView animateWithDuration:kAnimationTime animations:^{
        CGFloat height = CGRectGetHeight(imagesScrollView.frame) / 2;
        CGPoint pointStyleList = CGPointMake(CGRectGetMidX(imagesScrollView.frame),
                                             CGRectGetHeight(self.view.frame) - height);
        [imagesScrollView setCenter:pointStyleList];
        
        CGPoint buttonCenter = CGPointMake(CGRectGetWidth(self.view.frame) - CGRectGetMidX(self.addImageToolBar.bounds) - 4.f, pointStyleList.y);
        [self.addImageToolBar setCenter:buttonCenter];
    }];
    
    
    self.statusScrollOpened = StatusImages;
}



- (void) animationShowScrollLayouts:(UIScrollView *)layoutScrollView {
    [UIView animateWithDuration:kAnimationTime animations:^{
        CGSize sizeController = [self sizeViewController];
        CGPoint pointStyleList = CGPointMake(CGRectGetMidX(layoutScrollView.frame),
                                             sizeController.height - (CGRectGetHeight(layoutScrollView.frame) / 2));
        [layoutScrollView setCenter:pointStyleList];
    }];
    
    self.statusScrollOpened = StatusLayouts;
}



- (void) animateSelectImagePrintImage:(PrintImage *)printImage inStartRect:(CGRect)startRect
{
    // Делаем скриншот экрана
//    extern UIImage *_UICreateScreenUIImage();
    UIImage *screenshot = [UIImage imageNamed:@"screenshotConstructor"];//_UICreateScreenUIImage();
    
    // Рисуем ImageView для анимации
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:startRect];
    UIImage *preview = [printImage cropImageWithCropSize:startRect.size];
    [imageView setImage:preview];
    [self.view addSubview:imageView];
    
    
    
    // Определяем область, чтобы туда полностью поместилась картинка с максимальными значениями
    DrawGridView *gridView = [[DrawGridView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(startRect), CGRectGetHeight(startRect))];
    UIImage *gridImage = gridView.gridImage;
    
    CGFloat navagationbarHeight = 64.f; // Высота NaviBar + StatusBar
    CGFloat delta = 10.f;               // Отступ
    CGRect animateRect = [gridImage insertToCenterRect:CGRectMake(delta / 2,
                                                                  navagationbarHeight + (delta / 2),
                                                                  CGRectGetWidth(self.view.frame) - delta,
                                                                  CGRectGetHeight(self.view.frame) - delta - navagationbarHeight)];
    
    
    
    // Final Image (Edit, Remove, ImageButton)
    NSLog(@"Rect: %@", NSStringFromCGRect(self.view.frame));
    SelectAlbumImage *selectImageView = [[SelectAlbumImage alloc] initWithFrame:self.view.frame
                                                              andSelecViewFrame:animateRect
                                                                    andMainSize:self.view.frame.size
                                                                 andScreenImage:screenshot
                                                                 andSelectImage:preview
                                                                      andTarget:self
                                                                    andSelector:@selector(tappedHideSelectImage:)
                                                                    andDelegate:self];
    [selectImageView setHidden:YES];
    [self.view addSubview:selectImageView];
    

    
    // Animate
    [UIView animateWithDuration:kAnimationTime animations:^{
        [imageView setFrame:animateRect];
    } completion:^(BOOL finished) {
        [selectImageView setHidden:NO];
        
        [imageView removeFromSuperview];
    }];
}



#pragma mark - TappedMenu
- (void) tappedLayout:(UITapGestureRecognizer *)gesture
{
    
    // Блок для убирания выделения во всех LayoutToolView
    void (^DeselectedLayoutBlock)(LayoutToolView *, NSArray *) = ^(LayoutToolView *selectlayoutTool, NSArray *layoutViews) {
        // Cancel All Select
        for (LayoutToolView *layoutView in layoutViews) {
            if ([layoutView isKindOfClass:[LayoutToolView class]]) {
                [layoutView setSelected:NO];
            }
        }
        
        [selectlayoutTool setSelected:YES];
    };
    
    
    // Select
    UIView *view = gesture.view;
    LayoutToolView *layoutView = (LayoutToolView*)view;
    DeselectedLayoutBlock(layoutView, self.layoutsScrollView.subviews);
    
    
    // Определяем выбирался ли разворот
    NSUInteger pageIndex = layoutView.pageIndex;
    PageView *pageView = [self.pages objectAtIndex:pageIndex];
    if (pageView.layout) {
        [self addPageView:pageView inControllerView:self.view];
    } else {
        [self performSegueWithIdentifier:SEGUE_SHOOSE_STYLE sender:self];
    }
    

    // Progress
    [self calculateProgessWithLayouts:self.layoutsScrollView.subviews];
    
    // Title
    [self updateTitleControllerWithPageIndex:pageIndex];
}



- (void) tappedHideSelectImage:(UITapGestureRecognizer *)tapgesture
{
    UIView *view = tapgesture.view;
    [view removeFromSuperview];
}



- (void) tappedImageToolBar:(UITapGestureRecognizer *)gesture
{
    //
    ToolIconTheme *toolTheme = (ToolIconTheme *)gesture.view;
    if ([toolTheme isSelected]) { return; }
    [toolTheme selectedImage];
    
    // Import Image on PageView
    [self.pageView importImage:toolTheme.printImage];
    
    // Animation Hide
    [self animationHideScrollImages:self.imagesScrollView];
    
    // CalculateProgress
    [self calculateProgessWithLayouts:self.layoutsScrollView.subviews];
    
    
    // Для тестов
    NSMutableArray *allUrls = [NSMutableArray array];
    for (PageView *pageView in self.pages) {
        for (NSString *url in pageView.imagesUrls) {
            [allUrls addObject:url];
        }
    }
    
    NSInteger selectedToolImageCount = 0;
    for (ToolIconTheme *icon in self.imagesScrollView.subviews) {
        if ([icon isKindOfClass:[ToolIconTheme class]]) {
            if ([icon isSelected]) {
                selectedToolImageCount++;
            }
        }
    }
    NSLog(@"Count.AllPages.Count: %li", (long)allUrls.count);
    if (selectedToolImageCount != allUrls.count) {
        NSLog(@"Fail selecteds");
    }
    [self synchronizePagesImagesURLs:allUrls withToolImages:self.imagesScrollView.subviews];
    
    // Synchonize
//#warning ToDo: Test Perfomance
//    if (self.saveProgress == SaveProgressBackgroundFinish) {
//        [self synchronizePagesToShopCart:self.pages];
//    }
    
//#warning ToDo: Test Perfomance
    // Sync Layouts and Pages
//    [self synchronizePreviewPagesView:self.pages andLayoutTools:self.layoutsScrollView.subviews];
}



#pragma mark - SaveImageManagerDelegate
-(void)saveImageManager:(SaveImageManager *)manager didSaveAllToPrepareFinalSave:(PrintData *)printData
{
    // Все подготовили к сохранению
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop finalCompletePrintData:self.printData];
    
    // GoTo Cart
    //[[NSNotificationCenter defaultCenter] postNotificationName:GoToCartSegueNotification object:nil];
}


-(void)saveImageManager:(SaveImageManager *)manager didBigImagesSaved:(PrintImage *)printImage withPrintData:(PrintData *)printData
{
    NSLog(@"saveImage: %@", printImage.urlLibrary);
    [self addPrintImage:printImage inScrollView:self.imagesScrollView];
}


-(void)saveImageManager:(SaveImageManager *)manager didAllBigImagesSaved:(PrintData *)printData
{
    //
    NSLog(@"saveAllImage");
    
    
    // Sync
//#warning ToDo: Test Perfomance
//    [self synchronizePagesToShopCart:self.pages];
    
    
    switch (self.saveProgress) {
        case SaveProgressBackgroundActive:
            // Сохранение в фоне закончилось
            self.saveProgress = SaveProgressBackgroundFinish;
            break;
            
        case SaveProgressActive:
            // Переходим в корзину и ничего не показываем
            //[self actionCartButton:nil];
            //return;
            break;
            
        case SaveProgressWait:
        case SaveProgressBackgroundFinish:
        case SaveProgressFinish:
            break;
    }
}



-(void)saveImageManager:(SaveImageManager *)manager didSavedToProgress:(CGFloat)progress
{
    //[self.hud setProgress:progress];
}


-(void)saveImageManager:(SaveImageManager *)manager didCancelSave:(PrintData *)printData
{
//    __weak ConstructorViewController *weakSelf = self;
//    CoreDataShopCart *coreShopCart = [[CoreDataShopCart alloc] init];
//    [coreShopCart removeFromShopCartUnique:printData.unique_print withBlock:^{
//        [weakSelf backToStore];
//    }];
    
    self.saveProgress = SaveProgressBackgroundFinish;
    [self actionCartButton:nil];
}


#pragma mark - SelectAlbumImageDelegate
- (void)selectAlbumUmage:(SelectAlbumImage *)selectAlbumImage didRemoveImage:(UIImage *)image
{
    [selectAlbumImage removeFromSuperview];
    
    NSString *urlLibrary = [self.pageView removeImage];
    [self removeImageWithUrlLibrary:urlLibrary onImagesScrollView:self.imagesScrollView];
    
    
    //
    [self synchronizePreviewPagesView:self.pages andLayoutTools:self.layoutsScrollView.subviews];
}

-(void)selectAlbumUmage:(SelectAlbumImage *)selectAlbumImage didEditImage:(UIImage *)image
{
    [selectAlbumImage removeFromSuperview];
    
//    [self performSegueWithIdentifier:SEGUE_EDIT_CONSTRUCTOR sender:self];
    PrintImage *selectImage = self.editPrintImage;
    CGFloat aspect_ratio = self.editAspectRatio;
    EditPhotoConstructorViewController *editor = [[EditPhotoConstructorViewController alloc] initPrintImage:selectImage andAspect_ratio:aspect_ratio andCompleteBlock:^(PrintImage *printImage, EditImageSetting *imageSetting) {
//        NSString *urlLibrary = printImage.urlLibrary;
//        for (PrintImage *image in self.printData.imagesPreview) {
//            if ([image.urlLibrary isEqualToString:urlLibrary]) {
//                printImage = image;
//            }
//        }
//        
//        if (!printImage) {
//            return;
//        }
        
        [self.pageView importImage:printImage];
        
        
        
        // Sync
        [self synchronizePreviewPagesView:self.pages andLayoutTools:self.layoutsScrollView.subviews];
        [self.navigationController popViewControllerAnimated:NO];
    }];
    [self.navigationController pushViewController:editor animated:YES];
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    Template *template = [coreStore getTemplateWithPurchaseID:self.printData.storeItem.purchaseID
                                              andPropTypeName:self.printData.storeItem.propType.name
                                                 TemplateSize:self.printData.storeItem.propType.selectTemplate.size
                                              andTemplateName:self.printData.storeItem.propType.selectTemplate.name];
    
    // Button Index
    if (buttonIndex == 1) {
        if ([template hasImageDesign]) {
            // Картинки Верстки есть, поазываем пользователю
            Layout *layoutCover = template.layoutCover;
            [self createPageViewWithSelectLayout:layoutCover andTemplate:template andPageIndex:0];
        } else {
            // Картинок нету, ожидаем загрузки
            [template downloadImages];
        }
    } else if(buttonIndex == 0) {
        Layout *layoutCover = template.layoutCover;
        // Если нету обложки или картинки в обложке
        if (![layoutCover.frontLayer.image hasImage]) {
            for (Layout *layout in template.layouts) {
                if ([layout.frontLayer.image hasImage]) {
                    layoutCover = layout;
                }
            }
        }
        
        if (![layoutCover.frontLayer.image hasImage]) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        [self createPageViewWithSelectLayout:layoutCover andTemplate:template andPageIndex:0];
    }
}



#pragma mark - Action
- (void) actionAddImages:(UIButton *)sender
{
    if (self.saveProgress == SaveProgressBackgroundActive) {
        [self showAlertToashWithText:NSLocalizedString(@"You can add images, after all photos will be saved", nil)];
        return;
    }

    
    [self performSegueWithIdentifier:SEGUE_CHOOSE_IMAGE sender:self];
}


- (void)actionCartButton:(UIBarButtonItem *)sender {
    
    // Проверяем все ли страницы есть
//    PropUturn *propUturn = self.printData.storeItem.propType.selectPropUturn;
//    if (self.pages.count < [propUturn.uturn integerValue] + 1) {
//        [self showAlertTitle:NSLocalizedString(@"Attention", nil) andMessage:NSLocalizedString(@"Create else pages, is to few pages", nil)];
//        return;
//    }
    
    
    // Проверяем все ли развороты заполнены
    BOOL hasAllPagesFill = YES; // Все развороты заполнены
//    for (PageView *pageView in self.pages) {
//        if (pageView.progress < 0.8f) {
//            NSString *locString = NSLocalizedString(@"Please fill page", nil);
//            NSString *text = [NSString stringWithFormat:@"%@ %li",locString, (long)pageView.pageIndex];
//            [self showAlertTitle:NSLocalizedString(@"Attention", nil) andMessage:text];
//            return;
//        }
//    }
    
    
    // Проверяем активно ли сохранение
    if ((self.saveProgress == SaveProgressActive || self.saveProgress == SaveProgressBackgroundActive) && !hasAllPagesFill) {
        [self showAlertToashWithText:NSLocalizedString(@"please_wait_when_selected_images_will_be_saved", nil)];
        return;
    }
    
    
    // Если идет процесс сохранения и все развороты заполнены останавливаем
    if ((self.saveProgress == SaveProgressActive || self.saveProgress == SaveProgressBackgroundActive) && hasAllPagesFill) {
        [self.saveManager stopSave];
        return;
    }

    
    
    // Все проверки пройдены
    /// Блок выполнения остальных операций по переходу в корзину
    void (^ContinueExecuteCartBlock)(PrintData*) = ^(PrintData *printData) {
        // Если какие то картинки не были добавлены, удалаяем из заказа
        NSMutableArray *removeUrlLibraryImages = [NSMutableArray array];
        for (ToolIconTheme *icon in self.imagesScrollView.subviews) {
            if ([icon isKindOfClass:[ToolIconTheme class]]) {
                // Если не выделен, то можно удалять
                if (!icon.isSelected) {
                    [removeUrlLibraryImages addObject:icon.printImage.urlLibrary];
                }
            }
        }


        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        [coreShop removeImages:[removeUrlLibraryImages copy]];
        [coreShop finalCompletePrintData:self.printData];

        // GoTo Cart
        [[NSNotificationCenter defaultCenter] postNotificationName:GoToCartSegueNotification object:nil];
    };

    
    // Синхронизируем страницы
    __weak ConstructorViewController *weakSelf = self;
    [self prepareToSynchonizePages:self.pages afterSyncExecuteCompleteBlock:^{
        ContinueExecuteCartBlock(weakSelf.printData);
    }];
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
        // Возвращаем назад, после синхронизации
        if (pData.imagesPreview.count == 0) {
            [self backToStore];
        } else {
            __weak ConstructorViewController *wealSelf = self;
            [self prepareToSynchonizePages:self.pages afterSyncExecuteCompleteBlock:^{
                [wealSelf backToStore];
            }];
        }
    }
}




#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Style
    if ([segue.destinationViewController isKindOfClass:[LayoutsTableViewController class]]) {
        Template *template;
        for (LayoutToolView *toolView in self.layoutsScrollView.subviews) {
            if ([toolView isKindOfClass:[LayoutToolView class]]) {
                template = [toolView getTepmpate];
                break;
            }
        }
        [segue.destinationViewController setLayoutsTemplate:self.originalLayoutsPages];
    }
    
    
    
    // Select Photo
    if ([segue.identifier isEqualToString:SEGUE_CHOOSE_IMAGE]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationImagesDidSelected:) name:SelectAllImagesSelectCompleteNotification object:nil];
        BOOL coreDataUse = self.saveProgress == SaveProgressBackgroundActive ? YES : NO;
        [segue.destinationViewController setRootStoreItem:self.printData.storeItem andImages:self.printData.imagesNames andCoreDataUse:coreDataUse];
    }

    
    // Edit
    if ([segue.destinationViewController isKindOfClass:[EditPhotoViewController class]]) {
        PrintImage *selectImage = self.editPrintImage;
        // Если активный процесс сохранения, то берем PhotoPrint
        if (self.saveProgress == SaveProgressBackgroundActive) {
            [selectImage updatePreviewImage:selectImage.photoPrintImage];
        } else {
            CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
            selectImage = [coreShop getPreviewImageWithPrintDataUnique:self.printData.unique_print andPrintImage:selectImage];
        }

        [segue.destinationViewController printData:self.printData andEditenImage:selectImage andGridAspectRatio:self.editAspectRatio];
    }
}


#pragma mark - Public
-(void)setPrintDataConstructor:(PrintData *)printData
{
    self.printData = printData;
}

#pragma mark - Get template
- (Template *) template
{
    if (self.layoutsScrollView && self.layoutsScrollView.subviews.count > 0) {
        for (LayoutToolView *layoutTool in self.layoutsScrollView.subviews) {
            if ([layoutTool isKindOfClass:[LayoutToolView class]]) {
                return layoutTool.getTepmpate;
            }
        }
    }
    
    return nil;
}

@end
