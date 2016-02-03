//
//  StoreTableViewController.m
//  RevealControllerStoryboardExample2
//
//  Created by Дмитрий Мартынов on 2/27/15.
//  Copyright (c) 2015 CoDeveloper. All rights reserved.
//

#import "StoreViewController.h"
#import "OthersPrintViewController.h"
#import "PhotoPrintTableViewController.h"
#import "MenuTableViewController.h"

#import "ShowCaseViewController.h"
#import "AlbumConfiguratorViewController.h"
#import "ConstructorViewController.h"

#import "UIViewController+ECSlidingViewController.h"
#import "ECSlidingViewController.h"

#import "SkinModel.h"
#import "AnaliticsModel.h"

#import "CartBadgeNumberView.h"

#import "NSTimer+TimerSupport.h"

#import "PhAppNotifications.h"

#import "Banner.h"
#import "BannerItemView.h"

#import "CoreDataStore.h"
#import "CoreDataStoreBanner.h"
#import "CoreDataShopCart.h"

#import "PrintData.h"
#import "StoreItem.h"
#import "PropType.h"
#import "StoreToolTheme.h"
#import "Template.h"


NSString *const PhotoPrint1 = @"Фотопечать";
NSString *const Special1 = @"Спец.предложения";


NSString *const SEGUE_PHOTO_PRINT = @"SeguePhotoPrint";
NSString *const SEGUE_OTHER_PRINT = @"SegueOtherPrint";
NSString *const SEGUE_CART = @"GoToCartSegue";

NSString *const SEGUE_CONFIGURATOR  = @"seque_configurator";
NSString *const SEGUE_SHOWCASE      = @"segue_store_showcase";
NSString *const SEGUE_CONSTRUCTOR   = @"segue_store_constructor";


CGFloat const BannerBarHeight = 150.f;
CGFloat const AlbumCellHeight = 122.f;

@interface StoreViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *chipBarButton;

@property (strong, nonatomic) NSArray *storeMenu;
@property (strong, nonatomic) NSArray *colorArray;
@property (strong, nonatomic) StoreItem *selectedStoreItem;

@property (weak, nonatomic) UIScrollView *bannerScrollView;
@property (strong, nonatomic) NSTimer *bannerSwichTimer;


@property (assign, nonatomic) MDMenuSlideType menuSlideSwitch;

@property (strong, nonatomic) NSArray *albumStoreItems;

/// Высота обычных ячеек кроме альбома
@property (assign, nonatomic) CGFloat cellCategoryHeight;

/// Высота NavigationBar + StatusBar
@property (assign, nonatomic) CGFloat navigationbarHeight;


/// Не сохраненная PrintData
@property (strong, nonatomic) PrintData *unsavedPrintData;
@end



@implementation StoreViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    //[self.navigationController.navigationBar setTranslucent:NO];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(@"Магазин", nil)];
    
    [self.menuBarButton setTintColor:[UIColor whiteColor]];
    [self.chipBarButton setTintColor:[UIColor whiteColor]];
    
    
    // Analitics
    [[AnaliticsModel sharedManager] setScreenName:@"Store Screen"];
    
    
    //
    //CoreDataStore *coreStore = [[CoreDataStore alloc] init];
    //NSArray *categories = [coreStore getStoreCategoryes];
    NSMutableArray *categores = [NSMutableArray array];
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    NSArray* (^ReadCoreStoreBlock)(StoreType) = ^(StoreType store){
        CoreDataStore *coreStore = [[CoreDataStore alloc] init];
//        BOOL hasData = [coreStore hasStoreData];
        NSString *name = [coreStore getCategoryTitleWithCategoryID:store];
        NSArray *array = [coreStore getStoreItemsWithCategoryName:name];
        
        // Проверяем, альбом это или нет.
        // Если альбом, но сохраняем в albumStoreItems
        StoreItem *item = [array firstObject];
        if (item.propType.sizes.count > 0 && item.propType.uturns.count > 0 && item.propType.covers.count > 0) {
            self.albumStoreItems = array;
        }
        
        return array;
    };
    
    
    
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        [categores addObject:ReadCoreStoreBlock(StoreTypePhotoPrint)];
//        NSLog(@"StoreTypePhotoPrint");
    });
    dispatch_group_async(group, queue, ^{
        [categores addObject:ReadCoreStoreBlock(StoreTypePhotoAlbum)];
//        NSLog(@"StoreTypePhotoAlbum");
    });
    dispatch_group_async(group, queue, ^{
        [categores addObject:ReadCoreStoreBlock(StoreTypeSovenir)];
//        NSLog(@"StoreTypeSovenir");
    });
    dispatch_group_async(group, queue, ^{
        [categores addObject:ReadCoreStoreBlock(StoreTypeCoverCase)];
//        NSLog(@"StoreTypeCoverCase");
    });

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //NSLog(@"All task are done: %@", categores);
        self.storeMenu = [categores copy];
        
        NSMutableArray *storeMenu = [NSMutableArray array];
        for (NSArray *array in categores) {
            StoreItem *item = [array firstObject];
            [storeMenu addObject:item];
        }
        StoreItem *special = [[StoreItem alloc] initStoreWithPurchaseID:@"" andTypeStore:@"" andDescriptionStory:@"" andNamePurchase:@"" andCategoryID:@"5" andCategoryName:@"Спец.предложения" andAvailable:YES andTypes:nil];
        [storeMenu addObject:special];
        
        
        // Sort
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryID" ascending:YES];
        NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray *final = [storeMenu sortedArrayUsingDescriptors:descriptors];
        
        //CoreDataStore *coreStore = [[CoreDataStore alloc] init];
        self.storeMenu = [final copy];
        
        
        // Вычисляем высоту ячейки категории
        // Высота NavigationBar + Высота Ячейки альбома + Высота Баннера и / все категории минус один(альбом)
        CGFloat heightView = CGRectGetHeight(self.view.frame) < 560.f ? 568.f : CGRectGetHeight(self.view.frame);
        self.cellCategoryHeight = (heightView - self.navigationbarHeight - AlbumCellHeight - BannerBarHeight) / (storeMenu.count - 1);
        
        [self.tableView reloadData];
        
        [self updateTableContentSizeWithCellHeight:self.cellCategoryHeight andCountCategoryCells:storeMenu.count andNavigationHeight:self.navigationbarHeight];
    });
    
    // Color
    self.colorArray = [NSArray arrayWithObjects:[UIColor colorWithRed:63/255.f green:129/255.f blue:187/255.f  alpha:1.f],
                       [UIColor colorWithRed:56/255.f green:146/255.f blue:198/255.f  alpha:1.f],
                       [UIColor colorWithRed:49/255.f green:162/255.f blue:208/255.f  alpha:1.f],
                       [UIColor colorWithRed:42/255.f green:178/255.f blue:218/255.f  alpha:1.f],
                       [UIColor colorWithRed:35/255.f green:195/255.f blue:229/255.f  alpha:1.f], nil];
    
    
    // Slider
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuTableViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:Menu_StoryboardID];
    }
    
    
    
    // Swipe
    UISwipeGestureRecognizer *swipeOpen = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureSwipe:)];
    [swipeOpen setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:swipeOpen];
    
    UISwipeGestureRecognizer *swipeClose = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureSwipe:)];
    [swipeClose setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:swipeClose];
    
    
    
    //
    [self addCartBarButton];
    
    
    
    
    // Dialog
    /// Показываем диалоговое окно по PrintData
    void (^ShowAlertWithPrintData)(PrintData*) = ^(PrintData *pData) {
        NSString *text = [NSString stringWithFormat:@"%@ %@(%@). %@",
                          NSLocalizedString(@"you_have_not_saved_the", nil),
                          NSLocalizedString(pData.storeItem.categoryName, nil),
                          NSLocalizedString(pData.storeItem.propType.name, nil),
                          NSLocalizedString(@"do_you_wnat_continue_editing?", nil)];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attention", nil)
                                                        message:text
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"delete", nil)
                                              otherButtonTitles:NSLocalizedString(@"continue", nil), nil];
        [alert show];
    };
    
    
    
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    PrintData *unsaved = [coreShop getUnSavedPrintData];
    self.unsavedPrintData = unsaved;
    // Альбом-Конструктор
    if (unsaved.purchaseID == PhotoHousePrintAlbum && [unsaved.storeItem.propType.name isEqualToString:TypeNameConstructor]) {
        Template *userTemplate = unsaved.storeItem.propType.userTemplate;
        if (userTemplate.layouts.count == 0) {
            // Разворотов сохраненных не найдено,
            [coreShop removeFromShopCartUnique:0 withBlock:^{
                [self addCartBarButton];
                self.unsavedPrintData = nil;
            }];
        } else {
            ShowAlertWithPrintData(unsaved);
        }
        
    // Альбом Дизайн
    } else if (unsaved.purchaseID == PhotoHousePrintAlbum && [unsaved.storeItem.propType.name isEqualToString:TypeNameDesign]) {
        if (unsaved.imagesPreview.count == 0) {
            // Картинок не найдено, удаляем
            [coreShop removeFromShopCartUnique:0 withBlock:^{
                [self addCartBarButton];
                self.unsavedPrintData = nil;
            }];
        } else {
            ShowAlertWithPrintData(unsaved);
        }
    } else {
        [coreShop removeFromShopCartUnique:0 withBlock:^{
            [self addCartBarButton];
            self.unsavedPrintData = nil;
        }];
    }
}


- (void)viewDidLayoutSubviews
{
    if ([self respondsToSelector:@selector(topLayoutGuide)]) // iOS 7 or above
    {
        CGFloat top = self.topLayoutGuide.length;
        self.navigationbarHeight = top;
    }
}


-(void)viewDidDisappear:(BOOL)animated {
    [_bannerSwichTimer invalidate];
    _bannerSwichTimer = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    
    
    // Костыль, изменяем размер contentSize через 1 сек
    __weak StoreViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf updateTableContentSizeWithCellHeight:weakSelf.cellCategoryHeight andCountCategoryCells:weakSelf.storeMenu.count andNavigationHeight:weakSelf.navigationbarHeight];
    });
    
}


-(void)viewWillAppear:(BOOL)animated {
    CoreDataStoreBanner *corebanner = [[CoreDataStoreBanner alloc] init];
    NSInteger interval = 0;
    NSArray *banners = [corebanner getBannersSetInterval:&interval];
    if (banners.count > 0) {
        [self addBannersInHeader:banners andIntervalTimeSwitch:interval];
    } else {
        [self addSimpleBannerInHeader];
    }

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    if (_bannerSwichTimer.isValid) {
        [_bannerSwichTimer invalidate];
        _bannerSwichTimer = nil;
    }
    
    if (_bannerScrollView) {
        [_bannerScrollView setDelegate:nil];
        [_bannerScrollView removeFromSuperview];
        _bannerScrollView = nil;
    }
}


-(BOOL)shouldAutorotate {
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}



#pragma mark - Rotate
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
}




#pragma mark - Gesture
- (void)gestureSwipe:(UISwipeGestureRecognizer *)gesture {
    //[self.revealViewController revealToggle:self];
    [self actionMenuBar:nil];
}




#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _storeMenu.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    StoreItem *item = [self.storeMenu objectAtIndex:indexPath.row];
    StoreItem *albumStoreItem = [self.albumStoreItems firstObject];
    
    if ([item.categoryName isEqualToString:albumStoreItem.categoryName]) {
        cell = [self getAlbumCellTableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        cell = [self getCategoryCellTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Check Menu Opened
    if (self.menuSlideSwitch == MDMenuSlideTypeOpened) {
        [self actionMenuBar:self.menuBarButton];
        return;
    }
    
    // Select
    StoreItem *item = [self.storeMenu objectAtIndex:indexPath.row];
    if ([item.categoryName isEqualToString:PhotoPrint1]) {
        [self performSegueWithIdentifier:SEGUE_PHOTO_PRINT sender:self];
    } else {
        [self performSegueWithIdentifier:SEGUE_OTHER_PRINT sender:self];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return 146.f;
    StoreItem *item = [self.storeMenu objectAtIndex:indexPath.row];
    StoreItem *albumStoreItem = [self.albumStoreItems firstObject];
    
    if ([item.categoryName isEqualToString:albumStoreItem.categoryName]) {
        return AlbumCellHeight;//122.f;
    } else {
        return self.cellCategoryHeight;//68.f;
    }

}



#pragma mark - CustomTableCell
- (UITableViewCell *) getCategoryCellTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *iconView;
    UIView *backgroundView;
	UILabel *storelabel;
    UIView *contentStle;
    
    NSString *const CellIdentifier = @"StoreCell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor blackColor]];
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [iconView setContentMode:UIViewContentModeScaleAspectFit];
        iconView.tag = 1;
		
		backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
		backgroundView.backgroundColor = [UIColor clearColor];
		backgroundView.tag = 2;
        
        storelabel = [[UILabel alloc] initWithFrame:CGRectZero];
		storelabel.backgroundColor = [UIColor clearColor];
		storelabel.tag = 3;
		storelabel.numberOfLines = 1;
		storelabel.lineBreakMode = NSLineBreakByCharWrapping;
		//storelabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.f];
        storelabel.textColor = [UIColor whiteColor];
        
		contentStle = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(cell.frame), self.cellCategoryHeight)];
		contentStle.tag = 0;
		[contentStle addSubview:backgroundView];
        [contentStle addSubview:iconView];
		[contentStle addSubview:storelabel];
		[cell.contentView addSubview:contentStle];
    } else {
        contentStle     = [(UIView *)[cell.contentView viewWithTag:0] viewWithTag:0];
        iconView        = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:1];
		backgroundView  = (UIView *)[[cell.contentView viewWithTag:0] viewWithTag:2];
        storelabel      = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:3];
    }
    
    
    // Data
    UIFont *labelFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.f];
    StoreItem *item = [self.storeMenu objectAtIndex:indexPath.row];
    UIImage *iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"icon_category_%li", (long)item.categoryID]];
    [storelabel setFont:labelFont];
	[storelabel setText:[NSLocalizedString(item.categoryName, nil) uppercaseString]];
    [backgroundView setBackgroundColor:[self.colorArray objectAtIndex:indexPath.row]];
    [iconView setImage:iconImage];
    [iconView setContentMode:UIViewContentModeScaleAspectFit];
    
    // Position
    CGFloat heightCell = self.cellCategoryHeight;
    
    [contentStle setFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(cell.frame), heightCell)];
    [backgroundView setFrame:CGRectMake(4.f, 2.f, CGRectGetWidth(cell.frame) - 8.f, CGRectGetHeight(contentStle.frame) - 4.f)];
    [iconView setFrame:CGRectMake(CGRectGetMinX(backgroundView.frame) + 20.f,
                                  2.f,
                                  33.f,
                                  heightCell - 4.f)];
    [storelabel setFrame:CGRectMake(CGRectGetMaxX(iconView.frame) + 20.f,
                                    2.f,
                                    200.f,
                                    heightCell - 4.f)];
    
    [cell setBackgroundColor:[UIColor colorWithRed:6.f/255.f green:28.f/255.f blue:45.f/255.f alpha:1]];
    return cell;
}


- (UITableViewCell *) getAlbumCellTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UIImageView *iconView;
    UIView *backgroundView;
	UILabel *storelabel;
    UIScrollView *scrollView;
    
    NSString *const CellIdentifier = @"StoreCell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor blackColor]];
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //      iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        //		iconView.tag = 1;
		
		backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
		backgroundView.backgroundColor = [UIColor clearColor];
		backgroundView.tag = 2;
        
        storelabel = [[UILabel alloc] initWithFrame:CGRectZero];
		storelabel.backgroundColor = [UIColor clearColor];
		storelabel.tag = 3;
		storelabel.numberOfLines = 1;
		storelabel.lineBreakMode = NSLineBreakByCharWrapping;
		storelabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.f];
        storelabel.textColor = [UIColor whiteColor];
        storelabel.textAlignment = NSTextAlignmentCenter;
        
        scrollView = [[UIScrollView alloc] initWithFrame:backgroundView.frame];
        [scrollView setTag:4];
        //[scrollView setBackgroundColor:[UIColor redColor]];
		
		UIView *contentStle = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(cell.frame), AlbumCellHeight)];
		contentStle.tag = 0;
		[contentStle addSubview:backgroundView];
        //[contentStle addSubview:iconView];
		[contentStle addSubview:storelabel];
        [contentStle addSubview:scrollView];
		[cell.contentView addSubview:contentStle];
    } else {
        //iconView        = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:1];
		backgroundView  = (UIView *)[[cell.contentView viewWithTag:0] viewWithTag:2];
        storelabel      = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:3];
        scrollView      = (UIScrollView *)[[cell.contentView viewWithTag:0] viewWithTag:4];
    }
    
    
    //[iconView setFrame:CGRectMake(20, 20, 32, 32)];
    [backgroundView setFrame:CGRectMake(4.f, 2.f, CGRectGetWidth(cell.frame) - 8.f, 118.f)];
    [storelabel setFrame:CGRectMake(CGRectGetMinX(backgroundView.frame), CGRectGetMinY(backgroundView.frame)- 14.f, CGRectGetWidth(backgroundView.frame), 50.f)];
    [scrollView setFrame:CGRectMake(CGRectGetMinX(backgroundView.frame), 17.f, CGRectGetWidth(backgroundView.frame), CGRectGetHeight(backgroundView.frame) - 17.f)];
    scrollView.showsHorizontalScrollIndicator = NO;
    
    StoreItem *storeItem = [self.albumStoreItems firstObject];
	[storelabel setText:[NSLocalizedString(storeItem.categoryName, nil) uppercaseString]];
    [backgroundView setBackgroundColor:[self.colorArray objectAtIndex:indexPath.row]];
    
    
    // Add Items
    // Icon
    BOOL isNeedAdd = YES;
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[StoreToolTheme class]]) {
            isNeedAdd = NO;
        }
    }
    for (StoreItem *item in self.albumStoreItems) {
        CGFloat contentWidth = scrollView.contentSize.width;
        StoreToolTheme *tool = [[StoreToolTheme alloc] initWithFrame:CGRectMake(contentWidth/* == 0 ? 0 : contentWidth + 1*/, 0, CGRectGetWidth(backgroundView.frame) / 2, 90)
                                                              target:self
                                                              action:@selector(tappedSelectItem:)
                                                           storeItem:item];
        if (isNeedAdd) {
            [scrollView addSubview:tool];
        }
        [scrollView setContentSize:CGSizeMake(CGRectGetMinX(tool.frame) + CGRectGetWidth(tool.frame),
                                              100.f)];
    }
    [cell setBackgroundColor:[UIColor colorWithRed:6.f/255.f green:28.f/255.f blue:45.f/255.f alpha:1]];
    return cell;
}


#pragma mark - Select StoreItem
- (void) tappedSelectItem:(UITapGestureRecognizer*)gesture
{
    // Check Menu Opened
    if (self.menuSlideSwitch == MDMenuSlideTypeOpened) {
        [self actionMenuBar:self.menuBarButton];
        return;
    }
    
    
    static BOOL inProgress = NO;
    
    if(inProgress){ return; }
    inProgress = YES;
    
    UIView *view = gesture.view;
    
    if ([view isKindOfClass:[StoreToolTheme class]]) {
        // Select
        StoreToolTheme *tool = (StoreToolTheme *)view;
        [self selectedChangeStoreItem:tool.getSelectStoreItem];
        inProgress = NO;
    }
}


#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Objects
    if ([segue.destinationViewController isKindOfClass:[OthersPrintViewController class]] ||
        [segue.destinationViewController isKindOfClass:[PhotoPrintTableViewController class]])
    {
        //MenuStoreData *data = [self.storeMenu objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        StoreItem *item = [self.storeMenu objectAtIndex:indexPath.row];
        [segue.destinationViewController setCategoryTitleStore:item.categoryName];
    }
    
    
    // ShowCase
    if ([segue.destinationViewController isKindOfClass:[ShowCaseViewController class]]) {
        [segue.destinationViewController setUnsavedPrintDataStore:self.unsavedPrintData];
    }
    
    // AlbumConfigurator
    if ([segue.destinationViewController isKindOfClass:[AlbumConfiguratorViewController class]]) {
        [segue.destinationViewController setStoreItemInit:self.selectedStoreItem];
    }
    
    
    // AlbumConstructor
    if ([segue.destinationViewController isKindOfClass:[ConstructorViewController class]]) {
        [segue.destinationViewController setPrintDataConstructor:self.unsavedPrintData];
    }
}



#pragma mark - Actions
- (IBAction)actionCart:(id)sender {
    [self performSegueWithIdentifier:SEGUE_CART sender:self];
}

/*- (IBAction)actionMenuBar:(UIBarButtonItem *)sender {
    [self.revealViewController revealToggle:self];
}*/

- (IBAction)actionMenuBar:(UIBarButtonItem *)sender {
    if (self.menuSlideSwitch == MDMenuSlideTypeClosed)
    {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
        self.menuSlideSwitch = MDMenuSlideTypeOpened;
     }
    else
    {
         [self.slidingViewController resetTopViewAnimated:YES];
         self.menuSlideSwitch = MDMenuSlideTypeClosed;
    }
}


/*- (IBAction)actionCartButton:(UIBarButtonItem *)sender {
    //[[NSNotificationCenter defaultCenter] postNotificationName:CartDidChangeNotification object:nil];
}*/

- (void) actionBannerSelect:(UITapGestureRecognizer*)sender {
    // Check Menu Opened
    if (self.menuSlideSwitch == MDMenuSlideTypeOpened) {
        [self actionMenuBar:self.menuBarButton];
        return;
    }
    
    //
    if (![sender.view isKindOfClass:[BannerItemView class]]) {
        return;
    }
    
    // Banner
//    BannerItemView *bannerView = (BannerItemView *)sender.view;
//    Banner *banner = bannerView.banner;
//    NSInteger count = 0;
//    for (MenuStoreData *data in _storeMenu) {
//        if (data.storeType == banner.getInternalID) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
//            [self.tableView selectRowAtIndexPath:indexPath
//                                        animated:YES
//                                  scrollPosition:UITableViewScrollPositionNone];
//            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
//        }
//        count++;
//    }
}



#pragma mark - Methods

- (void) addCartBarButton {
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    NSInteger countCartItems = [coreShop getAllItemsWithNeedAddImages:NO].count;

    if (countCartItems > 0) {
        CartBadgeNumberView *badgeNumberView = [[CartBadgeNumberView alloc] initWithFrame:CGRectMake(14, 0, 20, 20)];
        [badgeNumberView setUserInteractionEnabled:NO];
        [badgeNumberView setOpaque:NO];
        badgeNumberView.number = countCartItems;
        
        // Create Button and add Badge
        UIButton *btn = [UIButton  buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 0, 32, 32)];
        [btn setBackgroundImage:[UIImage imageNamed:@"carts_icon"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(actionCart:) forControlEvents:UIControlEventTouchUpInside];
        [btn addSubview:badgeNumberView];
        
        // Initialize UIBarbuttonitem...
        UIBarButtonItem *proe = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = proe;
    } else {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"carts_icon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(actionCart:)];
        [button setTintColor:[UIColor whiteColor]];
        
        [self.navigationItem setRightBarButtonItem:button animated:YES];
    }
}


- (void) selectedChangeStoreItem:(StoreItem *)storeItem
{
    self.selectedStoreItem = storeItem;
    
//    if ((PhotoHousePrint)[storeItem.purchaseID integerValue] == PhotoHousePrintAlbum) {
        [self performSegueWithIdentifier:SEGUE_CONFIGURATOR sender:self];
//    } else {
//        [self performSegueWithIdentifier:SEGUE_SHOWCASE sender:self];
//    }
}


- (void) updateTableContentSizeWithCellHeight:(CGFloat)cellCategoryHeight andCountCategoryCells:(NSInteger)cellsCount andNavigationHeight:(CGFloat)navigationbarHeight
{
    CGFloat height = navigationbarHeight + BannerBarHeight + AlbumCellHeight + (cellCategoryHeight * (cellsCount - 2)) - 4.f;
    self.tableView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame),
                                            height);
}


#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // Delete Unsaved
        __weak StoreViewController *weakSelf = self;
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        [coreShop removeFromShopCartUnique:0 withBlock:^{
            [weakSelf addCartBarButton];
            weakSelf.unsavedPrintData = nil;
        }];
    } else {
        // Continue Unsaved
        if (self.unsavedPrintData.purchaseID == PhotoHousePrintAlbum && [self.unsavedPrintData.storeItem.propType.name isEqualToString:TypeNameConstructor]) {
            [self performSegueWithIdentifier:SEGUE_CONSTRUCTOR sender:self];
        } else {
            [self performSegueWithIdentifier:SEGUE_SHOWCASE sender:self];
        }
    }
}



#pragma mark - Banner
- (void) addSimpleBannerInHeader
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, BannerBarHeight)];
    [headerView setBackgroundColor:[UIColor colorWithRed:6.f/255.f green:28.f/255.f blue:45.f/255.f alpha:1]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 0, 312, 148)];
    [imageView setImage:[UIImage imageNamed:@"banner"]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [headerView addSubview:imageView];
    
    self.tableView.tableHeaderView = headerView;
}



- (void) addBannersInHeader:(NSArray *)banners andIntervalTimeSwitch:(NSInteger)interval {
    // View
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, BannerBarHeight)];
    [headerView setBackgroundColor:[UIColor colorWithRed:6.f/255.f green:28.f/255.f blue:45.f/255.f alpha:1]];
    
    CGRect rect = CGRectMake(4, 0, 312, 148);
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:rect];
    [scroll setDelegate:self];
    [scroll setPagingEnabled:YES];
    [scroll setContentSize:CGSizeMake(CGRectGetWidth(rect) * [banners count], CGRectGetHeight(rect))];
    [headerView addSubview:scroll];
    self.bannerScrollView = scroll;
    
    self.tableView.tableHeaderView = headerView;
    
    
    
    
    // ScrollSize
    CGRect viewSize = scroll.bounds;
    
    //
    NSInteger count = 1;
    for (Banner *banner in banners)
    {
        if (count != 1) {
            viewSize = CGRectOffset(viewSize, scroll.bounds.size.width, 0);
        }
        BannerItemView *item = [[BannerItemView alloc] initWithFrame:viewSize target:self action:@selector(actionBannerSelect:) setBanner:banner];
        [scroll addSubview:item];
        
        count++;
    }
    
    
    // Timer
    //[self scrollViewDidEndScrollingAnimation:scroll];
    
    [self createTimerWithInterval:interval];
    //self.bannerSwichTimer = timer;
}



- (void) moveBannerScroll {
    //NSLog(@"scroll Animation");
     UIScrollView *scrollView = _bannerScrollView;
     CGPoint offset = [scrollView contentOffset];
     CGSize contentSize = scrollView.contentSize;
     if (offset.x + 312 >= contentSize.width) {
        [scrollView scrollRectToVisible:CGRectMake(0, offset.y, 312, 148) animated:YES];
     } else {
         CGRect rect = CGRectMake(offset.x + 312, offset.y, 312, 148);
         //NSLog(@"rect: %@", NSStringFromCGRect(rect));
        [scrollView scrollRectToVisible:rect animated:YES];
     }
}


- (void) createTimerWithInterval:(NSInteger)interval {
    __weak StoreViewController *weakSelf = self;
    _bannerSwichTimer = [NSTimer md_scheduledTimerWithTimeInterval:interval block:^{
        [weakSelf moveBannerScroll];
    } repeats:YES];
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.bannerSwichTimer invalidate];
    self.bannerSwichTimer = nil;
//    NSLog(@"Pause");
    NSInteger interval = 0;
    CoreDataStoreBanner *coreBanner = [[CoreDataStoreBanner alloc] init];
    [coreBanner getBannersSetInterval:&interval];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!_bannerSwichTimer.isValid) {
            [self createTimerWithInterval:interval];
//            NSLog(@"Resume");
        }
    });
}



@end
