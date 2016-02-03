//
//  PhotoTableViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/6/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "HistoryMainTableViewController.h"
#import "MenuTableViewController.h"
#import "HistoryDetailViewController.h"

#import "UIViewController+ECSlidingViewController.h"
#import "ECSlidingViewController.h"

#import "LogInViewController.h"
#import "RegistrationViewController.h"

#import "HistoryOrderTableViewCell.h"

#import "SkinModel.h"
#import "PHouseApi.h"
#import "AnaliticsModel.h"

#import "PHouseApi.h"

#import "MBProgressHUD.h"
#import "SVPullToRefresh.h"

#import "CoreDataProfile.h"


#import "NSArray+Reverse.h"

#import "HistoryOrder.h"
#import "PersonOrderInfo.h"


NSString *const SEGUE_AUTH_ORDER = @"segue_auth_order";


@interface HistoryMainTableViewController () <PHouseApiDelegate, UIAlertViewDelegate>
@property (assign, nonatomic) MDMenuSlideType menuSlideType;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;

@property (strong, nonatomic) NSArray *orders;
@property (assign, nonatomic) BOOL isUpdatePull;
@end



@implementation HistoryMainTableViewController

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
    
    // Analitics
    [[AnaliticsModel sharedManager] setScreenName:@"HistoryAllOrders Screen"];
    
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:@"История заказов"];
    
    [self.menuBarButton setTintColor:[UIColor whiteColor]];
    
    
    
    // Slize Menu
    self.tableView.layer.shadowOpacity = 0.75f;
    self.tableView.layer.shadowRadius = 10.f;
    self.tableView.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuTableViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:Menu_StoryboardID];
    }
    
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    /*SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.menuBarButton setTarget: revealViewController];
        [self.menuBarButton setAction: @selector( revealToggle: )];
        //[self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }*/
    
    
    // Swipe
    UISwipeGestureRecognizer *swipeOpen = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureSwipe:)];
    [swipeOpen setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.tableView addGestureRecognizer:swipeOpen];
    
    UISwipeGestureRecognizer *swipeClose = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureSwipe:)];
    [swipeClose setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:swipeClose];
    
    
    
    
    
    // Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeNotification:) name:RegistrationCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeNotification:) name:AutorizationCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotification:) name:HistoryMainReloadNotification object:nil];
    
    
    // Pull To Refresh
    //
    __weak HistoryMainTableViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
    
    
    self.tableView.pullToRefreshView.textColor = [UIColor whiteColor];
    self.tableView.pullToRefreshView.arrowColor = [UIColor whiteColor];
    self.tableView.pullToRefreshView.activityIndicatorViewColor = [UIColor whiteColor];
    
    [self.tableView.pullToRefreshView setTitle:@"Загрузка" forState:SVInfiniteScrollingStateLoading];
    [self.tableView.pullToRefreshView setTitle:@"Потяните" forState:SVInfiniteScrollingStateStopped];
    [self.tableView.pullToRefreshView setTitle:@"Отпустите" forState:SVPullToRefreshStateTriggered];
    
    
    self.tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    //
    [self refreshDataWthPullToRefresh:NO];
    
    
    // Sleep Time
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    // Analitics
    [[AnaliticsModel sharedManager] sendEventCategory:@"Warning" andAction:@"ReceiveMemoryWarning" andLabel:@"HistoryOrders" withValue:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}






#pragma mark - Gesture
- (void)gestureSwipe:(UISwipeGestureRecognizer *)gesture {
    //[self.revealViewController revealToggle:self];
    [self actionMenuBarButton:nil];
}








#pragma mark - Notification
- (void) completeNotification:(NSNotification*)notification {
    [self refreshDataWthPullToRefresh:NO];
}

- (void) reloadNotification:(NSNotification*)notification {
    NSArray *allOrders = notification.object;
    self.orders = allOrders;
    [self.tableView reloadData];
}



#pragma mark - Pull To Refresh
- (void)insertRowAtTop {
    __weak HistoryMainTableViewController *weakSelf = self;
    
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf refreshDataWthPullToRefresh:YES];
    });
}





#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Auth
        [self performSegueWithIdentifier:SEGUE_AUTH_ORDER sender:self];
    }
}

#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didAuthReceiveData:(PHResponse *)response
{
    [phApi getHistoryAllOrders:self];
}

-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error
{
    NSLog(@"API.Error: %@; code: %li", [error localizedDescription], (long)error.code);
    if (self.isUpdatePull) {
        [self.tableView.pullToRefreshView stopAnimating];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
    
    //
    if (error.code == ErrorCodeTypeNotLoginAndPassword) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Авторизация"
                                                        message:@"Для просмотра истории заказов, вам требуется авторизоваться"
                                                       delegate:self
                                              cancelButtonTitle:@"Нет"
                                              otherButtonTitles:@"Авторизоваться", nil];
        [alert show];
    }
    
    if(error.code == ErrorCodeTypeNotConnectToInternet) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Интернет"
                                                        message:@"Нет соединения с интернетом"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)pHouseApi:(PHouseApi *)phApi didHistoryOrdersData:(NSArray *)allOrders
{
    if (self.isUpdatePull) {
        [self.tableView.pullToRefreshView stopAnimating];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
    //NSLog(@"count: %li", (unsigned long)[allOrders count]);
    
    //
    if ([allOrders count] > 0) {
        self.orders = [allOrders reverseArray];
        [self.tableView reloadData];
    }

}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.orders count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *const indefiner = @"Cell";
    HistoryOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indefiner forIndexPath:indexPath];
    
    // Configure the cell...
    HistoryOrder *order = [self.orders objectAtIndex:indexPath.row];
    PersonOrderInfo *orderInfo = order.personInfo;
    
    [cell.statusImageView setImage:[order statusOrderImage]];
    [cell.statusTitleLabel setText:orderInfo.status];
    [cell.imageAvatarView setImage:[order iconOrderImage]];
    [cell.idLabel setText:[NSString stringWithFormat:@"Заказ № %@", orderInfo.order_id]];
    
    // День заказа
    NSString *dateString;
    
    NSDate *todayDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:orderInfo.dateString];
    NSLog(@"date: %@", date);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay | NSCalendarUnitHour fromDate:date toDate:todayDate options:NSCalendarWrapComponents];

    
    NSInteger day = [components day];
    if (day < 1) {
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"];
        dateString = [timeFormatter stringFromDate:date];
    } else if (day == 1) {
        dateString = @"Вчера";
    } else {
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"dd.MM.yyyy"];
        dateString = [timeFormatter stringFromDate:date];
    }
    
    
    [cell.dateLabel setText:[NSString stringWithFormat:@"%li RUR / %@", (long)[order priceOrder], dateString]];
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[HistoryDetailViewController class]]) {
        NSInteger selected = [[self.tableView indexPathForSelectedRow] row];
        HistoryOrder *order = [self.orders objectAtIndex:selected];
        [segue.destinationViewController setHistoryOrder:order];
    }
}




#pragma mark - Methods
- (void) refreshDataWthPullToRefresh:(BOOL)isPull {
    // Loading
    if (!isPull) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Авторизация";
    }
    
    //
    self.isUpdatePull = isPull;
    
    
    //
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    PHouseApi *model = [[PHouseApi alloc] init];
    if (!coreProfile.profileID)
    {
        // Требуется авторизоваться
        [model authWithDelegate:self];
    }
    else
    {
        // Уже авторизовывались
        [model getHistoryAllOrders:self];
    }
}



#pragma mark - Action
- (IBAction)actionMenuBarButton:(UIBarButtonItem *)sender {
    if (self.menuSlideType == MDMenuSlideTypeClosed) {
        [self.slidingViewController anchorTopViewToRightAnimated:YES];
        self.menuSlideType = MDMenuSlideTypeOpened;
    } else {
        [self.slidingViewController resetTopViewAnimated:YES];
        self.menuSlideType = MDMenuSlideTypeClosed;
    }
}

@end
