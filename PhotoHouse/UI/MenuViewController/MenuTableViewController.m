//
//  MenuTableViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/5/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "MenuTableViewController.h"
#import "MenuTableViewCell.h"
#import "MenuStoreData.h"

#import "CoreDataShopCart.h"

#import "UIViewController+ECSlidingViewController.h"
#import "ECSlidingViewController.h"

#import "PHAppNotifications.h"


NSString *const Menu_StoryboardID       = @"MenuTop";
NSString *const Store_StoryboardID      = @"StoreNavigation";
NSString *const Orders_StoryboardID     = @"HistoryNavigation";
NSString *const Options_StoryBoardID    = @"OptionsNavigation";
NSString *const Support_StoryBoardID    = @"SupportNavigation";
NSString *const About_StoryboardID      = @"AboutNavigation";
NSString *const Cart_StoryboardID       = @"CartNavigation";
NSString *const Profile_StoryboardID    = @"ProfileNavigation";




NSString *const ShopCartItemsCountNotification  = @"ShopCartItemsCountNotification";
NSString *const MainMenuSelectionNotification   = @"MainMenuSelectionNotification";


NSString *const ShopCartItemsCountKey   = @"ShopCartItemsCountKey";
NSString *const MainMenuSelectionKey    = @"MainMenuSelectionKey";


@interface MenuTableViewController ()
/// Массив меню
@property (strong, nonatomic) NSArray *menu;

/// Выделенный элемент
@property (assign, nonatomic) NSInteger selectedCellIndex;

/// Количество элементов в корзине
@property (assign, nonatomic) NSInteger shopCartItemsCount;
@end



@implementation MenuTableViewController

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
    
    // Slize menu
    //[self.slidingViewController setAnchorRightPeekAmount:55.f];
    
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    self.shopCartItemsCount = [coreShop getAllItemsWithNeedAddImages:NO].count;
    
    
    //
    self.selectedCellIndex = 0;
    
    
    //
    NSMutableArray *menu = [NSMutableArray array];
    
    MenuStoreData *data;
    data = [[MenuStoreData alloc] init];
    data.title = NSLocalizedString(@"store", nil);
    data.imageIconName = @"store_icon";
    data.storyboardNavigatorID = Store_StoryboardID;
    [menu addObject:data];
    
    data = [[MenuStoreData alloc] init];
    data.title = NSLocalizedString(@"shopcart", nil);
    data.imageIconName = @"carts_icon";
    data.storyboardNavigatorID = Cart_StoryboardID;
    [menu addObject:data];
    
    
    data = [[MenuStoreData alloc] init];
    data.title = NSLocalizedString(@"historyorders", nil);
    data.imageIconName = @"purchase_icon";
    data.storyboardNavigatorID = Orders_StoryboardID;
//    [menu addObject:data];

    
    data = [[MenuStoreData alloc] init];
    data.title = NSLocalizedString(@"options", nil);
    data.imageIconName = @"options_icon";
    data.storyboardNavigatorID = Options_StoryBoardID;
//    [menu addObject:data];

    
    data = [[MenuStoreData alloc] init];
    data.title = NSLocalizedString(@"support", nil);
    data.imageIconName = @"support_icon";
    data.storyboardNavigatorID = Support_StoryBoardID;
    [menu addObject:data];
    
    data = [[MenuStoreData alloc] init];
    data.title = NSLocalizedString(@"about", nil);
    data.imageIconName = @"about_icon";
    data.storyboardNavigatorID = About_StoryboardID;
    [menu addObject:data];
    
    data = [[MenuStoreData alloc] init];
    data.title = NSLocalizedString(@"profile", nil);
    data.imageIconName = @"profile_icon";
    data.storyboardNavigatorID = Profile_StoryboardID;
    [menu addObject:data];

    //
    self.menu = menu;

    
    // Add Notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificationChangeShopCartItemsCount:) name:ShopCartItemsCountNotification object:nil];
    [nc addObserver:self selector:@selector(notificationMenuSelection:) name:MainMenuSelectionNotification object:nil];
    [nc addObserverForName:GoToCartSegueNotification object:nil queue:[NSOperationQueue mainQueue]usingBlock:^(NSNotification *note) {
        self.selectedCellIndex = 1;
        //[self performSegueWithIdentifier:CartSegue sender:self];
        [self openViewControllerWithIdentifer:Cart_StoryboardID];
    }];
    
    [nc addObserverForName:GoToHistorySegueNotification object:nil queue:[NSOperationQueue mainQueue]usingBlock:^(NSNotification *note) {
        self.selectedCellIndex = 2;
        [self openViewControllerWithIdentifer:Orders_StoryboardID];
    }];
    [nc addObserverForName:GoToStoreSegueNotification object:nil queue:[NSOperationQueue mainQueue]usingBlock:^(NSNotification *note) {
        self.selectedCellIndex = 0;
        //[self performSegueWithIdentifier:CartSegue sender:self];
        [self openViewControllerWithIdentifer:Store_StoryboardID];
    }];
    
    
//    [nc addObserver:self selector:@selector(notificationDidChangeBadge:) name:BadjeDidChangeCartCountNotification object:nil];
    
    
    
    
    
    
    // Header
    CGSize windowSize = [[UIScreen mainScreen] applicationFrame].size;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, windowSize.width, 201)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    imageView.center = CGPointMake(CGRectGetMidX(headerView.frame) - 27, CGRectGetMidY(headerView.frame));
    [headerView addSubview:imageView];
    
    self.tableView.tableHeaderView = headerView;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


//#pragma mark - Notification
//- (void) notificationDidChangeBadge:(NSNotification*)notification {
//    [self.tableView reloadData];
//}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.menu count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    MenuStoreData *data = [self.menu objectAtIndex:indexPath.row];
    [cell.titleLabel setText:data.title];
    [cell.selectedCellView setHidden:NO];
    [cell.iconImageView setImage:[UIImage imageNamed:data.imageIconName]];
    [cell.selectedCellView setHidden:(self.selectedCellIndex == indexPath.row ? NO : YES)];
    
//    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    NSInteger itemsCount = self.shopCartItemsCount;//[coreShop getAllItemsWithNeedAddImages:NO].count;
    if (itemsCount > 0 && [data.storyboardNavigatorID isEqualToString:Cart_StoryboardID]) {
        NSInteger badje = itemsCount;
        [cell.cartView setHidden:NO];
        [cell.cartCount setText:[NSString stringWithFormat:@"%lu", (unsigned long)badje]];
        [cell.cartBadjeImageView setImage:badje > 9 ? [UIImage imageNamed:@"badje"] : [UIImage imageNamed:@"badje2"]];
    } else {
        [cell.cartView setHidden:YES];
    }
    
    return cell;
}



#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuStoreData *data = [self.menu objectAtIndex:indexPath.row];
    NSString *indentifer = data.storyboardNavigatorID;
    
    UIViewController *navigator = [self.storyboard instantiateViewControllerWithIdentifier:indentifer];
    
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = navigator;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopViewAnimated:YES];
    
    //[self performSegueWithIdentifier:indentifer sender:self];
    
    //
    self.selectedCellIndex = indexPath.row;
    [self.tableView reloadData];
}


#pragma mark - Methods
- (void) openViewControllerWithIdentifer:(NSString*)identifer {
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifer];
    
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = newTopViewController;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopViewAnimated:YES];
}



#pragma mark - Notification
- (void) notificationChangeShopCartItemsCount:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSInteger itemsCount = [[userInfo objectForKey:ShopCartItemsCountKey] integerValue];
    self.shopCartItemsCount = itemsCount;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) notificationMenuSelection:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *menuStoryboardId = [userInfo objectForKey:MainMenuSelectionKey];
    
    for (MenuStoreData *data in self.menu) {
        if ([data.storyboardNavigatorID isEqualToString:menuStoryboardId]) {
            self.selectedCellIndex = [self.menu indexOfObject:data];
        }
    }
    
    
    // Reload
    NSIndexPath *indexPath0 = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
    NSArray *indexPaths = @[indexPath0, indexPath1];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

@end
