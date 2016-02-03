//
//  AlbumConfiguratorTableViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 11/27/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "AlbumConfiguratorViewController.h"
#import "AlbumListViewController.h"
#import "ShowCaseViewController.h"
#import "ConstructorViewController.h"

#import "CoreDataStore.h"
#import "CoreDataShopCart.h"

#import "SkinModel.h"

#import "PrintData.h"
#import "StoreItem.h"
#import "PropType.h"
#import "PropUturn.h"
#import "PropSize.h"
#import "PropCover.h"
#import "PropStyle.h"

#import "AlbumToolView.h"
#import "SliderUturn.h"
#import "ToolBarConfiguratorView.h"

#import "MBProgressHUD.h"


#import "SelectNavigationViewController.h"
#import "SelectImagesNotification.h"


/// Список для выбора типа сообщения UIAlertView
typedef enum {
    /// Сообщение о охзменении стиля
    AlertViewTypeStyle,
    /// Сообщение о изменении размера
    AlertViewTypeSize,
    /// Сообщение что альбом будет потерян в случае перейдем в магазин
    AlertViewTypeBackToStore
} AlertViewTypeTag;


static NSString *const SEGIE_LIST              = @"segue_list";
static NSString *const SEGUE_CONSTRUCTOR_CONF  = @"segue_constructor_conf";
static NSString *const SEGUE_SHOWCASE_CONF     = @"segue_showcase_conf";
static NSString *const SEGUE_SELECT_PHOTOs      = @"segue_select_images_photo";



static NSString *const COMMENTS_ALBUM_PREVIEW          = @"Ваш комментарий, Например: \nИмена, Названия, Даты и прочие подписи к фотографиям";
static NSString *const STYLE_CONFIGURATOR_DESCRIPTION  = @"style_configurator_description";


@interface AlbumConfiguratorViewController () <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, SliderUturnDelegate, ToolBarConfiguratorDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) ToolBarConfiguratorView *toolBarView;                 // ToolBarView
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (strong, nonatomic) PrintData *printData;

/// Позиция находящаяся в режиме редактирования, может быть == nil
@property (strong, nonatomic, readonly) PrintData *unsavedPrintData;

/// Выбранный объект, когда пользователь пытаем поменять размер альбома в конструкторе
@property (strong, nonatomic) id propObjectSelect;

///
@property (assign, nonatomic) NSInteger countData;


/// Массив выбранных фотографий [PrintImage] Только для Дизайнерского альбома
@property (strong, nonatomic) NSArray *printImages;
@end



@implementation AlbumConfiguratorViewController
@synthesize unsavedPrintData = _unsavedPrintData;

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
    
    // Header
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Header
    [[SkinModel sharedManager] headerForDetailViewWithNavigationBar:self.navigationController.navigationBar];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    //[self.navigationController.navigationBar setTranslucent:NO];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(@"configurator_title", nil)];
    
    
    //
    [self.commentTextView setTextColor:[UIColor grayColor]];
    [self.commentTextView setText:COMMENTS_ALBUM_PREVIEW];
    
    
    
    // Tool Bar
    ToolBarConfiguratorView *view = [[[NSBundle mainBundle] loadNibNamed:@"ToolBarConfiguratorView" owner:self options:nil] firstObject];
    [view setCenter:CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetHeight(self.view.frame) - 25.f)];
    [view setDelegate:self];
    [self.view addSubview:view];
    self.toolBarView = view;
    
    
    //
    [self updatePriceWithPrintData:self.printData];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    //
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc addObserver:self selector:@selector(keyboardWillShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
//    [nc addObserver:self selector:@selector(keyboardWillHideLeyboard:) name:UIKeyboardWillHideNotification object:nil];
    
}



-(void)viewDidAppear:(BOOL)animated
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    
    if (self.unsavedPrintData && self.unsavedPrintData.purchaseID == self.printData.purchaseID) {
        self.printData = self.unsavedPrintData;
    }
    
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        self.countData = 4;
        [self.tableView reloadData];
    }
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
//    [self.navigationItem.backBarButtonItem setTarget:self];
//    [self.navigationItem.backBarButtonItem setAction:@selector(actionBackBarButton:)];
//        [self.navigationController.navigationBar.backItem.backBarButtonItem setTarget:self];
//        [self.navigationController.navigationBar.backItem.backBarButtonItem setAction:@selector(actionBackBarButton:)];
//    });
    UIImage *image = [UIImage imageNamed:@"prevNavigation"];
    
    NSLog(@"size: %@", NSStringFromCGSize(image.size));
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionBackBarButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(actionBackBarButton:)];
    //if ([MDUserDefaultsParameters IOS7]) {
    [barButton setTintColor:[UIColor whiteColor]];
    //}
    [self.navigationItem setLeftBarButtonItem:barButton animated:NO];
    
    
    // Notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHideLeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}




-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Rotate
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        self.countData = 4;
        [self.tableView reloadData];
    }
}


-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}




#pragma mark - Notification
- (void)keyboardWillShowKeyboard:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(0.f, 0.f, CGRectGetHeight(rect), 0.f);
    [self.tableView setContentInset:inset];
    CGFloat animationTime = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions animationOption = (UIViewAnimationOptions)[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:animationTime delay:0.f options:animationOption animations:^{
        [self.toolBarView setCenter:CGPointMake(CGRectGetMidX(self.toolBarView.frame),
                                                CGRectGetHeight(self.view.frame) - CGRectGetHeight(rect) - CGRectGetMidY(self.toolBarView.bounds))];
    } completion:nil];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


- (void)keyboardWillHideLeyboard:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    
    CGFloat top = self.topLayoutGuide.length;
    UIEdgeInsets inset = UIEdgeInsetsMake(top, 0.f, 30.f, 0.f);
    [self.tableView setContentInset:inset];
    CGFloat animationTime = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions animationOption = (UIViewAnimationOptions)[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:animationTime delay:0.f options:animationOption animations:^{
        [self.toolBarView setCenter:CGPointMake(CGRectGetMidX(self.toolBarView.frame),
                                                CGRectGetHeight(self.view.frame) - CGRectGetMidY(self.toolBarView.bounds))];
    } completion:nil];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSUInteger count = self.interfaceOrientation == UIInterfaceOrientationPortrait ? 4 : 3;
    
    return self.countData;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self cellStyleTableView:tableView cellForRowAtIndexPath:indexPath];
    } else if(indexPath.row > 0 && indexPath.row < 3) {
        cell = [self cellOtherTableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        // Либо текстовое поле или выбор разворотов
        StoreItem *storeItem = self.printData.storeItem;
        NSString *propTypeName = storeItem.propType.name;
        if ([propTypeName isEqualToString:TypeNameDesign]) {
            cell = [self cellTextViewTableView:tableView cellForRowAtIndexPath:indexPath];
        } else {
            cell = [self cellSliderTableView:tableView cellForRowAtIndexPath:indexPath];
        }
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        // Проверяем есть ли сохраненный альбом в корзине
        PrintData *pData = self.unsavedPrintData;
        if (pData) {
            NSString *text = [NSString stringWithFormat:@"%@ %@(%@). %@ %@(%@) %@",
                              NSLocalizedString(@"You have not saved the", nil),
                              pData.storeItem.categoryName,
                              pData.storeItem.propType.name,
                              NSLocalizedString(@"If you change the style, your", nil),
                              pData.storeItem.categoryName,
                              pData.storeItem.propType.name,
                              NSLocalizedString(@"will be lost", nil)];
            [self showAlertTitle:NSLocalizedString(@"Attention", nil) andMessage:text andTypeAlertView:AlertViewTypeStyle];
            return;
        }
        
        [self performSegueWithIdentifier:SEGIE_LIST sender:self];
    }
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 148.f;
    } else if(indexPath.row > 0 && indexPath.row < 3) {
        return 126.f;
    } else {
        // Либо текстовое поле или выбор разворотов
        StoreItem *storeItem = self.printData.storeItem;
        NSString *propTypeName = storeItem.propType.name;
        if ([propTypeName isEqualToString:TypeNameDesign]) {
            return 126.f;
        } else {
            return 126.f;
        }
    }

}




#pragma mark - Custom Cell
- (UITableViewCell *) cellStyleTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *iconView;
    UIView *backgroundView;
	UILabel *storelabel;
    UILabel *styleNameLabel;
    UILabel *descriptionLabel;
    
    UIFont *storeFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.f];
    UIFont *styleFont = [UIFont fontWithName:@"Helvetica" size:14.f];
    UIFont *desctFont = [UIFont fontWithName:@"Helvetica" size:11.f];
    
    NSString *const CellIdentifier = @"StoreCell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor blackColor]];
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.tag = 1;
		
		backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
		backgroundView.backgroundColor = [UIColor clearColor];
		backgroundView.tag = 2;
        
        storelabel = [[UILabel alloc] initWithFrame:CGRectZero];
		storelabel.backgroundColor = [UIColor clearColor];
		storelabel.tag = 3;
		storelabel.numberOfLines = 1;
		storelabel.lineBreakMode = NSLineBreakByCharWrapping;
		storelabel.font = storeFont;
        storelabel.textColor = [UIColor whiteColor];
        storelabel.textAlignment = NSTextAlignmentCenter;
        
        styleNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		styleNameLabel.backgroundColor = [UIColor clearColor];
		styleNameLabel.tag = 4;
		styleNameLabel.numberOfLines = 2;
		styleNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
		styleNameLabel.font = styleFont;
        styleNameLabel.textColor = [UIColor whiteColor];
        styleNameLabel.textAlignment = NSTextAlignmentLeft;
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.tag = 4;
		descriptionLabel.numberOfLines = 2;
		descriptionLabel.lineBreakMode = NSLineBreakByCharWrapping;
		descriptionLabel.font = desctFont;
        descriptionLabel.textColor = [UIColor whiteColor];
        descriptionLabel.textAlignment = NSTextAlignmentLeft;
        
        //NSLog(@"fons: %@", [UIFont fontNamesForFamilyName:@"Helvetica"]);
        
		UIView *contentStle = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(cell.frame), 148.f)];
		[contentStle setTag:0];
		[contentStle addSubview:backgroundView];
		[contentStle addSubview:storelabel];
        [contentStle addSubview:styleNameLabel];
        [contentStle addSubview:descriptionLabel];
        [contentStle addSubview:iconView];
		[cell.contentView addSubview:contentStle];
    } else {
        iconView        = (UIImageView *)[[cell.contentView viewWithTag:0] viewWithTag:1];
		backgroundView  = (UIView *)[[cell.contentView viewWithTag:0] viewWithTag:2];
        storelabel      = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:3];
        styleNameLabel  = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:4];
        descriptionLabel= (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:5];
    }
    
    
    
    // Data
    PropStyle *selectPropStyle = self.printData.storeItem.propType.selectPropStyle;
    NSString *styleName = selectPropStyle.styleName == nil ? @"undefined" : selectPropStyle.styleName;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"style_%@", styleName]];
    [styleNameLabel setText:NSLocalizedString(styleName, nil)];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:63/255.f green:129/255.f blue:187/255.f alpha:1.f]];
    [iconView setImage:image];
    [storelabel setText:NSLocalizedString(@"configurator_style", nil)];
    [descriptionLabel setText:NSLocalizedString(STYLE_CONFIGURATOR_DESCRIPTION, nil)];
    
    
//    [styleNameLabel setBackgroundColor:[UIColor redColor]];
//    [storelabel setBackgroundColor:[UIColor yellowColor]];
//    [iconView setBackgroundColor:[UIColor greenColor]];
    
    
    // Size
    CGSize styleSize = [styleNameLabel.text sizeWithAttributes:@{NSFontAttributeName: styleFont}];
    CGSize storeSize = [storelabel.text sizeWithAttributes:@{NSFontAttributeName: storeFont}];
    CGSize imageSize = image.size;
    
    // Position
    [backgroundView setFrame:CGRectMake(4.f, 4.f, CGRectGetWidth(cell.frame) - 8.f, 96.f)];
    [storelabel setFrame:CGRectMake(CGRectGetMinX(backgroundView.frame),
                                    CGRectGetMinY(backgroundView.frame)+10.f,
                                    CGRectGetWidth(backgroundView.frame),
                                    storeSize.height)];
    [styleNameLabel setFrame:CGRectMake(CGRectGetMinX(backgroundView.frame) + 16.f,
                                        CGRectGetMaxY(storelabel.frame) + 14.f,
                                        CGRectGetMidX(backgroundView.bounds),
                                        styleSize.height)];
    CGFloat width = CGRectGetWidth(backgroundView.bounds) - CGRectGetMidX(backgroundView.bounds);
    CGRect iconRect = CGRectMake(CGRectGetMidX(backgroundView.frame),
                                 CGRectGetMaxY(storelabel.frame),
                                 width,
                                 imageSize.height / imageSize.width * width);
    [iconView setFrame:iconRect];
    [descriptionLabel setFrame:CGRectMake(CGRectGetMinX(backgroundView.frame),
                                         CGRectGetMaxY(backgroundView.frame),
                                         CGRectGetWidth(backgroundView.frame),
                                         148.f - CGRectGetMaxY(backgroundView.frame))];
    
    return cell;
}







- (UITableViewCell *) cellOtherTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
		
		UIView *contentStle = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(cell.frame), 122.f)];
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
    
    StoreItem *storeItem = self.printData.storeItem;
	
    
    NSArray *arrayTypes;
    NSString *title;
    id selectedObject;
    switch (indexPath.row) {
        case TypeConfiguratorStyle:
            break;
            
        case TypeConfiguratorSize:
            arrayTypes = storeItem.propType.sizes;
            title = NSLocalizedString(@"configurator_size", nil);
            selectedObject = storeItem.propType.selectPropSize;
            break;
            
        case TypeConfiguratorCover:
            arrayTypes = storeItem.propType.covers;
            title = NSLocalizedString(@"configurator_cover", nil);
            selectedObject = storeItem.propType.selectPropCover;
            break;
            
        case TypeConfiguratorPage:
            //arrayTypes = storeItem.propType.covers;
            break;
    }
    
    [storelabel setText:title];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:63/255.f green:129/255.f blue:187/255.f alpha:1.f]];
    
    // Add Items
    // Icon
    BOOL isNeedAdd = YES;
    for (UIView *view in scrollView.subviews) {
       if ([view isKindOfClass:[AlbumToolView class]]) {
           isNeedAdd = NO;
           //[view removeFromSuperview];
       }
    }
    for (id item in arrayTypes) {
        CGFloat contentWidth = scrollView.contentSize.width;
        AlbumToolView *tool = [[AlbumToolView alloc] initWithFrame:CGRectMake(contentWidth/* == 0 ? 0 : contentWidth + 5*/, 0, CGRectGetWidth(backgroundView.frame) / 2, 90)
                                                            target:self
                                                            action:@selector(tappedSelectItem:)
                                                        propObject:item
                                                       andSelected:[item isEqual:selectedObject]];
        if (isNeedAdd) {
            [scrollView addSubview:tool];
            [scrollView setContentSize:CGSizeMake(CGRectGetMinX(tool.frame) + CGRectGetWidth(tool.frame),
                                                  100.f)];
        }
    }
    
    
    // Если элементы уже есть, то нужно просто обновить выделение
    // И проверить AlbumToolView ли это
    if (!isNeedAdd) {
        for (AlbumToolView *tool in scrollView.subviews) {
            if ([tool isKindOfClass:[AlbumToolView class]]) {
                // Убираем выделение
                [tool comparePropObject:selectedObject];
//                [tool deselect];
//                
//                // Проверяем
//                if ([tool.propObject isEqual:selectedObject]) {
//#warning ToDo: Stop Here
//                    [tool selectTool];
//                }
            }
        }
    }
    
    return cell;
}



- (UITableViewCell *) cellSliderTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *backgroundView;
	UILabel *storelabel;
    SliderUturn *slider;
    
    UIFont *storeFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.f];
    
    NSString *const CellIdentifier = @"StoreCell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor blackColor]];
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
//        iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        iconView.contentMode = UIViewContentModeScaleAspectFit;
//        iconView.tag = 1;
		
		backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
		backgroundView.backgroundColor = [UIColor clearColor];
		backgroundView.tag = 2;
        
        storelabel = [[UILabel alloc] initWithFrame:CGRectZero];
		storelabel.backgroundColor = [UIColor clearColor];
		storelabel.tag = 3;
		storelabel.numberOfLines = 1;
		storelabel.lineBreakMode = NSLineBreakByCharWrapping;
		storelabel.font = storeFont;
        storelabel.textColor = [UIColor whiteColor];
        storelabel.textAlignment = NSTextAlignmentCenter;
        
        NSArray *uturns = self.printData.storeItem.propType.uturns;
        SliderUturn *slider = [[SliderUturn alloc] initWithFrame:CGRectMake(10.f, 40.f, CGRectGetWidth(self.view.frame) - 20.f, 50.f) andUturns:uturns andDelegate:self];
        [slider setMinimumTrackTintColor:[UIColor colorWithRed:94/255.f green:193/255.f blue:225/255.f alpha:1.f]];
        [slider setTag:4];
        [slider setValue:0.1f];
        [slider setMaximumValue:0.3f];
        [slider setMinimumValue:0.f];
		
        UIView *contentStle = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(cell.frame), 126.f)];
		[contentStle setTag:0];
		[contentStle addSubview:backgroundView];
		[contentStle addSubview:storelabel];
        [contentStle addSubview:slider];
		[cell.contentView addSubview:contentStle];
    } else {
		backgroundView  = (UIView *)[[cell.contentView viewWithTag:0] viewWithTag:2];
        storelabel      = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:3];
        slider          = (SliderUturn *)[[cell.contentView viewWithTag:0] viewWithTag:4];
    }
    
    [backgroundView setBackgroundColor:[UIColor colorWithRed:63/255.f green:129/255.f blue:187/255.f alpha:1.f]];
    [storelabel setText:NSLocalizedString(@"configurator_uturns", nil)];
    
    CGSize storeSize = [storelabel.text sizeWithAttributes:@{NSFontAttributeName: storeFont}];
    
    // Position
    [backgroundView setFrame:CGRectMake(4.f, 4.f, CGRectGetWidth(cell.frame) - 8.f, 118.f)];
    [storelabel setFrame:CGRectMake(CGRectGetMinX(backgroundView.frame),
                                    CGRectGetMinY(backgroundView.frame)+10.f,
                                    CGRectGetWidth(backgroundView.frame),
                                    storeSize.height)];
    return cell;
}



- (UITableViewCell *) cellTextViewTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *backgroundView;
	UILabel *storelabel;
    UITextView *textView;
    
    UIFont *storeFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.f];
    
    NSString *const CellIdentifier = @"StoreCell1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor blackColor]];
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //        iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        //        iconView.contentMode = UIViewContentModeScaleAspectFit;
        //        iconView.tag = 1;
		
		backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
		backgroundView.backgroundColor = [UIColor clearColor];
		backgroundView.tag = 2;
        
        storelabel = [[UILabel alloc] initWithFrame:CGRectZero];
		storelabel.backgroundColor = [UIColor clearColor];
		storelabel.tag = 3;
		storelabel.numberOfLines = 1;
		storelabel.lineBreakMode = NSLineBreakByCharWrapping;
		storelabel.font = storeFont;
        storelabel.textColor = [UIColor whiteColor];
        storelabel.textAlignment = NSTextAlignmentCenter;
        
        textView = [[UITextView alloc] initWithFrame:CGRectZero];
        [textView setDelegate:self];
        [textView setTag:4];
		
        UIView *contentStle = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(cell.frame), 126.f)];
		[contentStle setTag:0];
		[contentStle addSubview:backgroundView];
		[contentStle addSubview:storelabel];
        [contentStle addSubview:textView];
		[cell.contentView addSubview:contentStle];
    } else {
		backgroundView  = (UIView *)[[cell.contentView viewWithTag:0] viewWithTag:2];
        storelabel      = (UILabel *)[[cell.contentView viewWithTag:0] viewWithTag:3];
        textView        = (UITextView *)[[cell.contentView viewWithTag:0] viewWithTag:4];
    }
    
    
    [backgroundView setBackgroundColor:[UIColor colorWithRed:63/255.f green:129/255.f blue:187/255.f alpha:1.f]];
    [storelabel setText:NSLocalizedString(@"configurator_comment", nil)];
    [textView setText:COMMENTS_ALBUM_PREVIEW];
    
    CGSize storeSize = [storelabel.text sizeWithAttributes:@{NSFontAttributeName: storeFont}];
    
    // Position
    [backgroundView setFrame:CGRectMake(4.f,
                                        4.f,
                                        CGRectGetWidth(cell.frame) - 8.f,
                                        118.f)];
    [storelabel setFrame:CGRectMake(CGRectGetMinX(backgroundView.frame),
                                    CGRectGetMinY(backgroundView.frame)+10.f,
                                    CGRectGetWidth(backgroundView.frame),
                                    storeSize.height)];
    [textView setFrame:CGRectMake(CGRectGetMinX(backgroundView.frame),
                                  CGRectGetMaxY(storelabel.frame),
                                  CGRectGetWidth(backgroundView.frame),
                                  CGRectGetHeight(backgroundView.frame))];
    self.commentTextView = textView;
    return cell;
}




#pragma mark - UITextViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:COMMENTS_ALBUM_PREVIEW]) {
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        [textView setText:COMMENTS_ALBUM_PREVIEW];
        [textView setTextColor:[UIColor grayColor]];
    }
    return YES;
}



#pragma mark - UIScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.commentTextView isFirstResponder]) {
        [self.commentTextView resignFirstResponder];
    }
}



#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == AlertViewTypeStyle) {
            [self performSegueWithIdentifier:SEGIE_LIST sender:self];
        } else if (alertView.tag == AlertViewTypeSize) {
            [self.printData changeProp:self.propObjectSelect];
        } else if (alertView.tag == AlertViewTypeBackToStore) {
            [self backToStore];
        }
        
        // Remove Unsaved
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        [coreShop removeFromShopCartUnique:0 withBlock:nil];
        
        // Reload
        [self.printData removeAllImages];
        _unsavedPrintData = nil;
        [self.tableView reloadData];
    }
}



#pragma mark - SliderUturnDelegate
-(void)sliderUrurn:(SliderUturn *)slider didChangeUturn:(PropUturn *)uturn
{
    [self.printData changeProp:uturn];
    
    [self updatePriceWithPrintData:self.printData];
}



#pragma mark - ToolBarConfiguratorDelegate
-(void)toolBarConfigurator:(ToolBarConfiguratorView *)toolBar didActionNextButton:(NSString *)status
{
    // Либо текстовое поле или выбор разворотов
//    StoreItem *storeItem = self.printData.storeItem;
//    NSString *propTypeName = storeItem.propType.name;
//    if ([propTypeName isEqualToString:TypeNameDesign]) {
//        [self performSegueWithIdentifier:SEGUE_SHOWCASE_CONF sender:self];
//    } else {
//        [self performSegueWithIdentifier:SEGUE_CONSTRUCTOR_CONF sender:self];
//    }
    [self actionButton:nil];
}



#pragma mark - Tapped
- (void) tappedSelectItem:(UITapGestureRecognizer *)gesture {
    AlbumToolView *toolView = (AlbumToolView *)gesture.view;
    
    if ([self.commentTextView isFirstResponder]) {
        return;
    }
    
    PrintData *pData = self.unsavedPrintData;
    if (pData && toolView.typeConfigutator == TypeConfiguratorSize) {
        NSString *text = [NSString stringWithFormat:@"%@ %@(%@). %@ %@(%@) %@",
                          NSLocalizedString(@"you_have_not_saved_the", nil),
                          pData.storeItem.categoryName,
                          pData.storeItem.propType.name,
                          NSLocalizedString(@"If you change the size, your", nil),
                          pData.storeItem.categoryName,
                          pData.storeItem.propType.name,
                          NSLocalizedString(@"will be lost", nil)];
        [self showAlertTitle:NSLocalizedString(@"Attention", nil) andMessage:text andTypeAlertView:AlertViewTypeSize];
        return;
    }
    
    NSObject *propObject = toolView.propObject;
    [self.printData changeProp:propObject];
    [self updatePriceWithPrintData:self.printData];
    
    [self.tableView reloadData];
}



#pragma mark - Private
- (void) updatePriceWithPrintData:(PrintData *)printData
{
    NSInteger price = printData.price;
    [self.toolBarView changePrice:price];
}


/*! Проверяем есть ли не сохраненные данные в Корзине */
- (PrintData *) unsavedPrintData
{
    // Открываем сохраненное
    if (!_unsavedPrintData) {
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        _unsavedPrintData = [coreShop getUnSavedPrintData];
    }
    
    return _unsavedPrintData;
}


- (void) showAlertTitle:(NSString *)title andMessage:(NSString *)message andTypeAlertView:(AlertViewTypeTag)alertType
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"continue", nil), nil];
    [alert setTag:alertType];
    [alert show];
}


- (void) backToStore
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Public
- (void) setStoreItemInit:(StoreItem *)storeItem {
    self.printData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // ShowCase
    if ([segue.destinationViewController isKindOfClass:[ShowCaseViewController class]]) {
        StoreItem *item = self.printData.storeItem;
        [segue.destinationViewController setPhotoPrintItem:item andSelectedImages:self.printImages];
    }
    
    
    // Select Photo
    if ([segue.destinationViewController isKindOfClass:[SelectNavigationViewController class]]) {
        StoreItem *item = self.printData.storeItem;
        [segue.destinationViewController setRootStoreItem:item andImages:@[] andCoreDataUse:NO];
    }
    
    
    // Album Constructor
    if ([segue.destinationViewController isKindOfClass:[ConstructorViewController class]]) {
        self.countData = 3;
        [self.tableView reloadData];
        [segue.destinationViewController setPrintDataConstructor:self.printData];
    }

    
    
    // List
    if ([segue.destinationViewController isKindOfClass:[AlbumListViewController class]]) {
        [segue.destinationViewController showStyleListPrintData:self.printData];
    }
}



#pragma mark - Action
- (IBAction)actionButton:(UIButton *)sender {
    if ([self.printData.storeItem.propType.name isEqualToString:TypeNameConstructor]) {
        [self performSegueWithIdentifier:SEGUE_CONSTRUCTOR_CONF sender:self];
        
    } else {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(notificationImagesDidSelected:) name:SelectAllImagesSelectCompleteNotification object:nil];
        [nc addObserver:self selector:@selector(notificationImagesDidSelectedCancel:) name:SelectAllImagesSelectCancelNotification object:nil];
        
        //
        [self performSegueWithIdentifier:SEGUE_SELECT_PHOTOs sender:self];
    }
}



- (void) actionBackBarButton:(UIBarButtonItem *)sender
{
    // Проверяем есть ли сохраненный альбом в корзине
    PrintData *pData = self.unsavedPrintData;
    if (pData) {
        NSString *text = [NSString stringWithFormat:@"%@ %@(%@). %@ %@(%@) %@",
                          NSLocalizedString(@"you_have_not_saved_the", nil),
                          NSLocalizedString(pData.storeItem.categoryName, nil),
                          NSLocalizedString(pData.storeItem.propType.name, nil),
                          NSLocalizedString(@"If you want back to store, your", nil),
                          NSLocalizedString(pData.storeItem.categoryName, nil),
                          NSLocalizedString(pData.storeItem.propType.name, nil),
                          NSLocalizedString(@"will be lost", nil)];
        [self showAlertTitle:NSLocalizedString(@"Attention", nil) andMessage:text andTypeAlertView:AlertViewTypeBackToStore];
        return;
    }
    
    [self backToStore];
}

#pragma mark - Notification
- (void) notificationImagesDidSelected:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SelectAllImagesSelectCompleteNotification object:nil];
    
    
    NSDictionary *info = notification.userInfo;
    NSArray *printImages = [info objectForKey:SelectAllImagesKey];
    self.printImages = printImages;
    
    [self performSegueWithIdentifier:SEGUE_SHOWCASE_CONF sender:self];
}

- (void) notificationImagesDidSelectedCancel:(NSNotification *)notification {
}


@end
