//
//  CartViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/3/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "CartViewController.h"
#import "CartTableViewCell.h"
#import "CartCountPickerView.h"
#import "CartDetailViewController.h"

#import "MenuTableViewController.h"

#import "UIViewController+ECSlidingViewController.h"
#import "ECSlidingViewController.h"

#import "ShippingDeliveryViewController.h"

#import "CoreDataprofile.h"
#import "CoreDataShopCart.h"

#import "PrintData.h"

#import "SkinModel.h"
#import "AnaliticsModel.h"

#import "ToolPhotoView.h"

#import "PhouseApi.h"

#import "RegistrationViewController.h"
#import "LogInViewController.h"

#import "MBProgressHUD.h"

//#import "SVPullTorefresh.h"


NSString *const SEGUE_AUTH = @"segue_auth";
NSString *const SEGUE_BOOKING = @"segue_booking";
NSString *const SEGUE_CART_DETAIL = @"segue_cart_detail";



@interface CartViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CartCountDelegate, PHouseApiDelegate, UIAlertViewDelegate>
@property (assign, nonatomic) MDMenuSlideType menuSlideType;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *removeOrdersButton;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;

//@property (strong, nonatomic) CartCountPickerView *countPicker;

@property (assign, nonatomic) NSInteger didSelectButtonTag;

@property (strong, nonatomic) NSArray *shopCartOrders;
@end



@implementation CartViewController


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
    
    
    // MainMenu Selector
    NSDictionary *userInfo = @{MainMenuSelectionKey: Cart_StoryboardID};
    NSNotification *notification = [NSNotification notificationWithName:MainMenuSelectionNotification object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    
    // Analitics
    [[AnaliticsModel sharedManager] setScreenName:@"Cart Screen"];
    
    
    // Slize Menu
    self.tableView.layer.shadowOpacity = 0.75f;
    self.tableView.layer.shadowRadius = 10.f;
    self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
    
    // Swipe
    UISwipeGestureRecognizer *swipeOpen = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureSwipe:)];
    [swipeOpen setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:swipeOpen];
    
    UISwipeGestureRecognizer *swipeClose = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureSwipe:)];
    [swipeClose setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:swipeClose];

    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuTableViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:Menu_StoryboardID];
    }

    
    
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    //[self.navigationController.navigationBar setTranslucent:NO];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(@"shop_cart_title", nil)];
    
    [self.menuBarButton setTintColor:[UIColor whiteColor]];
    [self.removeOrdersButton setTintColor:[UIColor whiteColor]];
    
    //
    
    
    // Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canceledNotification:) name:RegistrationCancelNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeNotification:) name:RegistrationCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canceledNotification:) name:AutorizationCancelNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeNotification:) name:AutorizationCompleteNotification object:nil];
    
    
    
    //
    [self.removeOrdersButton setTitle:NSLocalizedString(@"remove_all", nil)];
    [self.buyButton setTitle:NSLocalizedString(@"send_button", nil) forState:UIControlStateNormal];
    
    // Pull To Refresh
//    __weak CartViewController *weakSelf = self;
//    [self.tableView addInfiniteScrollingWithActionHandler:^{
//        [weakSelf insertRowAtBottom];
//    }];
//    
//    self.tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    

    /*
    dispatch_queue_t queue = dispatch_queue_create("com.photohouse.temperary.remove", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        TemporaryImageModel *tempModel = [[TemporaryImageModel alloc] init];
        [tempModel removeAllEditedObjects];
    });
*/
    
    
    
    // Check Enabled
    [self isEnabledBuyButton];
    
    
    // Analitics
    NSString *label = [NSString stringWithFormat:@"Open. Counts: %lu", (unsigned long)[self.shopCartOrders count]];
    [[AnaliticsModel sharedManager] sendEventCategory:@"Cart" andAction:@"Action" andLabel:label withValue:[NSNumber numberWithInteger:[self.shopCartOrders count]]];
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    
    //
    [self getAllShopCartItems];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // Analitics
    [[AnaliticsModel sharedManager] sendEventCategory:@"Warning" andAction:@"ReceiveMemoryWarning" andLabel:@"CartController" withValue:nil];
}



-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Rotate
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
}


#pragma mark - Gesture
- (void)gestureSwipe:(UISwipeGestureRecognizer *)gesture {
    [self actionMenuButton:nil];
}






#pragma mark - Notification
- (void) completeNotification:(NSNotification*)notification {
    if ([self isEnabledBuyButton]) {
        [self actionBuyButton:nil];
    }
}





- (void) canceledNotification:(NSNotification*)notification {
    // wait
    [self isEnabledBuyButton];
}




//#pragma mark - PullToRefresh
//- (void)insertRowAtBottom {
//    __weak CartViewController *weakSelf = self;
//    
//    int64_t delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//    {
//        [weakSelf updateCartBottom];
//        [weakSelf.tableView.infiniteScrollingView stopAnimating];
//    });
//}




#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.shopCartOrders count];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PrintData *printData = [self.shopCartOrders objectAtIndex:indexPath.row];
    [cell.imageCartView setImage:printData.iconShopCart];
    [cell.countButton setTag:indexPath.row];
    [cell.pcsLabel setText:NSLocalizedString(@"pcs.", nil)];
    [cell.countButton setTitle:[NSString stringWithFormat:@"%li", (long)printData.count] forState:UIControlStateNormal];
    [cell.countButton addTarget:self action:@selector(actionShowCountPicker:) forControlEvents:UIControlEventTouchUpInside];
    [cell.sizeLabel setText:NSLocalizedString(printData.namePurchase, nil)];
    
    // localize Price
    NSString *priceText = NSLocalizedString(@"price", nil);
    NSString *valute = NSLocalizedString(@"RUB", nil);
    [cell.priceLabel setText:[NSString stringWithFormat:@"%@ %li %@.", priceText, (long)printData.price, valute]];
    
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return _menuSlideType == MDMenuSlideTypeClosed ? YES : NO;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        PrintData *printData = [self.shopCartOrders objectAtIndex:indexPath.row];
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        __weak CartViewController *weakSelf = self;
        [coreShop removeFromShopCartUnique:printData.unique_print withBlock:^{
            [weakSelf getAllShopCartItems];
        }];
        
        self.didSelectButtonTag = 258;
     }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Check Menu Opened
    if (self.menuSlideType == MDMenuSlideTypeOpened) {
        [self actionMenuButton:self.menuBarButton];
        return;
    }
    
    // Select
   [self performSegueWithIdentifier:SEGUE_CART_DETAIL sender:self];
}






#pragma mark - CartCountDelegate
-(void)cartCountCancel:(CartCountPickerView *)picker {
    [self closeCartCountView:picker];
}




-(void)cartPicker:(CartCountPickerView *)picker countOk:(NSInteger)count {
    [self closeCartCountView:picker];
    
    if (self.shopCartOrders.count == 0) {
        return;
    }
    
    PrintData *printData = [self.shopCartOrders objectAtIndex:self.didSelectButtonTag];
    [printData changeCount:count];
    
    // Save To CoreData
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop updateCountPrintData:printData];
    
    //
    [self.tableView reloadData];
    
    
    [self calculatePrice:self.shopCartOrders];
}



#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self removeAll];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
    
}



#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didAuthReceiveData:(PHResponse *)response
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //
    [self.buyButton setEnabled:YES];
    
    [self performSegueWithIdentifier:SEGUE_BOOKING sender:self];
}

-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error
{
    //
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //
    [self.buyButton setEnabled:YES];
    
    //
    switch ((ErrorCodeTypes)error.code) {
        case ErrorCodeTypeAutorizationFaled:
        case ErrorCodeTypeNotLoginAndPassword:
        case ErrorCodeTypeMakeOrder:
        case ErrorCodeTypeInternalParse:
        case ErrorCodeTypeRegistrationFaled:
            [self performSegueWithIdentifier:SEGUE_AUTH sender:self];
            break;
            
        case ErrorCodeTypeNotConnectToInternet:
        case ErrorCodeTypeTimeOut:
            [self showAlertTitle:NSLocalizedString(@"error", nil) andText:NSLocalizedString(@"internet_not_found", nil)];
            break;
            
        
    }
}









#pragma mark - Methods
- (void) getAllShopCartItems
{
    CGFloat startTime = CACurrentMediaTime();
    __weak CartViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        NSArray *items = [coreShop getAllItemsWithNeedAddImages:NO];
        weakSelf.shopCartOrders = items;
        [weakSelf.tableView reloadData];
        [weakSelf calculatePrice:weakSelf.shopCartOrders];
        
        
        NSLog(@"Count Time: %f", CACurrentMediaTime() - startTime);
        // Check Enabled
        [weakSelf isEnabledBuyButton];
        
        // Post
        [weakSelf postNotificationWithShopCartItemsCount:weakSelf.shopCartOrders.count];
    });

}


- (void) removeAll
{
    // Remove
//    __weak CartViewController *weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
//        [coreShop removeAll];
//        
//        weakSelf.shopCartOrders = [NSArray array];
//        [weakSelf.tableView reloadData];
//        
//        //
//        [weakSelf calculatePrice:self.shopCartOrders];
//    });
    
    /// Блок удаления одной позиции
    void (^RemoveInique)(NSInteger) = ^(NSInteger unique) {
        NSLog(@"Remove Start: %li", (long)unique);
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        [coreShop removeFromShopCartUnique:unique withBlock:nil];
        NSLog(@"Remove Finish: %li", (long)unique);
    };
    
    
    //
    dispatch_queue_t queue = dispatch_get_main_queue();//dispatch_queue_create("com.photohouse.cart.remove.all", DISPATCH_QUEUE_SERIAL);dispatch_get_main_queue()
    dispatch_group_t group = dispatch_group_create();
    
    for (PrintData *printData in self.shopCartOrders) {
        dispatch_group_async(group, queue, ^{
            RemoveInique(printData.unique_print);
        });
    }
    
    __weak CartViewController *weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"All tasks are done!");
        weakSelf.shopCartOrders = [NSArray array];
        [weakSelf.tableView reloadData];
        
        //
        [weakSelf calculatePrice:self.shopCartOrders];
        
        // Hud
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        // Post
        [weakSelf postNotificationWithShopCartItemsCount:weakSelf.shopCartOrders.count];
    });
    
    
}


//- (void) updateCartBottom {
//    NSArray *newOrders = [[CoreDataModel sharedManager] allOrdersToCart:OrdersListTypeNext];
//    NSMutableArray *mutableSelected =  [self.selectedArray mutableCopy];
//    [mutableSelected addObjectsFromArray:newOrders];
//    
//    self.selectedArray = [mutableSelected copy];
//    [self.tableView reloadData];
//}


- (void) closeCartCountView:(CartCountPickerView*)picker {
//    [UIView animateWithDuration:0.3f animations:^{
//        picker.center = CGPointMake(CGRectGetMidX(self.view.frame),
//                                    CGRectGetMaxY(self.view.frame) + 145);
//    }];
    
    [UIView animateWithDuration:0.3f animations:^{
        picker.center = CGPointMake(CGRectGetMidX(self.view.frame),
                                    CGRectGetMaxY(self.view.frame) + 145);
    } completion:^(BOOL finished) {
        [picker removeFromSuperview];
    }];
}



- (void) calculatePrice:(NSArray*)items {
    NSInteger symm = 0;
    
    for (PrintData *printData in items) {
        symm = symm + printData.price;
    }
    
    //NSLog(@"cost: %li", (long)symm);
    NSString *valute = NSLocalizedString(@"RUB", nil);
    [self.costLabel setText:[NSString stringWithFormat:@"%li %@", (unsigned long)symm, valute]];
    [self.totalPrice setText:NSLocalizedString(@"total_price", nil)];
}



- (BOOL) isEnabledBuyButton {
    if ([self.shopCartOrders count] == 0) {
        [self.buyButton setEnabled:NO];
    } else {
        [self.buyButton setEnabled:YES];
    }
    
    
    return self.buyButton.enabled;
}



- (void) showAlertTitle:(NSString *)title andText:(NSString *)text
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void) postNotificationWithShopCartItemsCount:(NSInteger)itemsCount
{
    NSDictionary *userInfo = @{ShopCartItemsCountKey: [NSNumber numberWithInteger:itemsCount]};
    NSNotification *notification = [NSNotification notificationWithName:ShopCartItemsCountNotification object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void) showPickerWithNumCount:(NSInteger)count {
    CartCountPickerView *picker = [[[NSBundle mainBundle] loadNibNamed:@"CartCountPriceView" owner:self options:nil] objectAtIndex:0];
    picker.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.view.frame) + 145);
    picker.delegate = self;
    [self.view addSubview:picker];
    
    
    [picker showActualNumber:count];
    
    [UIView animateWithDuration:0.3f animations:^{
        picker.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.view.frame) - 86/*152*/);
    }];

}





#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Detail
    if ([segue.destinationViewController isKindOfClass:[CartDetailViewController class]]) {
        NSInteger index = [[self.tableView indexPathForSelectedRow] row];
        PrintData *printData = [self.shopCartOrders objectAtIndex:index];
        [segue.destinationViewController setDetailPrintData:printData];
    }
}




#pragma mark - Actions
- (IBAction)actionBuyButton:(UIButton *)sender {
    
    if ([self.shopCartOrders count] == 1) {
        PrintData *printData = [self.shopCartOrders firstObject];
        if (printData.purchaseID == PhotoHousePrintDelivery) {
            return;
        }
    }
    
    if ([self.shopCartOrders count] == 0) {
        return;
    }
    
    //
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"signin_title", nil);
    
//#warning ToDo: Uncomment
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    if (!coreProfile.profileID)
    {
        // Требуется авторизоваться
        PHouseApi *model = [[PHouseApi alloc] init];
        [model authWithDelegate:self];
        [self.buyButton setEnabled:NO];
    }
    else
    {
        // Goto Delivery
        [self pHouseApi:nil didAuthReceiveData:nil];
        [self.buyButton setEnabled:YES];
    }
}




- (IBAction)actionRemoveAll:(UIBarButtonItem *)sender
{
    //
    if (self.shopCartOrders.count == 0) return;
    
    
    // Hud
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    
    // Alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attention", nil)
                                                    message:NSLocalizedString(@"remove_all_message", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"remove_all", nil), nil];
    [alert show];
}



- (IBAction)actionMenuButton:(UIBarButtonItem *)sender {
    if (self.menuSlideType == MDMenuSlideTypeClosed) {
//        self.shopCartOrders = [NSArray array];
//        [self.tableView reloadData];
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
        self.menuSlideType = MDMenuSlideTypeOpened;
    } else {
        [self.slidingViewController resetTopViewAnimated:YES];
        self.menuSlideType = MDMenuSlideTypeClosed;
    }
}


- (void) actionShowCountPicker:(UIButton*)button {
    self.didSelectButtonTag = button.tag;
    
    //
    PrintData *printData = [self.shopCartOrders objectAtIndex:self.didSelectButtonTag];
    if (printData.purchaseID == PhotoHousePrintDelivery) {
        return;
    }
//    [self.countPicker showActualNumber:printData.count];
//    
//    [UIView animateWithDuration:0.3f animations:^{
//        self.countPicker.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMaxY(self.view.frame) - 152);
//    }];
    
    [self showPickerWithNumCount:printData.count];
}

@end
