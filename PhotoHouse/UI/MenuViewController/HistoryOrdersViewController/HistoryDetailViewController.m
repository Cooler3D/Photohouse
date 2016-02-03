//
//  HistoryOrderDetailTableViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/22/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "HistoryDetailViewController.h"
#import "CartTableViewCell.h"
#import "HistoryDetailPhotoViewController.h"
#import "headerDetailView.h"

#import "AnaliticsModel.h"

#import "HistoryOrder.h"
#import "PersonOrderInfo.h"
#import "PrintData.h"

#import "SkinModel.h"

#import "PhouseApi.h"

#import "CoreDataProfile.h"


NSString *const HistoryMainReloadNotification = @"HistoryMainReloadNotification";


@interface HistoryDetailViewController () <PHouseApiDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) HistoryOrder *order;
@end



@implementation HistoryDetailViewController

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
    
    // Navigation Bar
    SkinModel *photomodel = [SkinModel sharedManager];
    
    
    // Название
    PersonOrderInfo *orderInfo = self.order.personInfo;
    NSString *title = [NSString stringWithFormat:@"Заказ №%@", orderInfo.order_id];
    self.navigationItem.titleView = [photomodel headerForViewControllerWithTitle:title];
    
    
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[photomodel headerColorWithViewController]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    // Analitics
    [[AnaliticsModel sharedManager] setScreenName:@"HistoryOrder Screen"];
    
    
    //
    [self createHeaderWithOrder:self.order];
    
    
    // Проверяем статус и показываем кнопки удалить
    if ((StatusOrderType)[orderInfo.status_id integerValue] == StatusOrderTypeWait) {
        [self createToolBarWithPayAndDeleteOrder];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    // Analitics
    [[AnaliticsModel sharedManager] sendEventCategory:@"Warning" andAction:@"ReceiveMemoryWarning" andLabel:@"HistoryOrderDelail" withValue:nil];
}



#pragma mark - Methods(Private)
- (void) createToolBarWithPayAndDeleteOrder
{
    SkinModel *model = [SkinModel sharedManager];
    
    UIToolbar *toolbar = [[UIToolbar alloc]
                          initWithFrame:CGRectMake(0, 0, 100, 45)];
    [toolbar setBarTintColor:[model headerColorWithViewController]];
    [toolbar setTranslucent:NO];
    
    
    //
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:2];
    
    // Payment
    UIBarButtonItem *pay = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"payment_icon"]
                                                            style:UIBarButtonItemStyleBordered
                                                           target:self
                                                           action:@selector(actionPaymentOrderButton:)];
    [buttons addObject:pay];
    
    
    // Delete
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                            target:self
                                                                            action:@selector(actionCancelOrderButton:)];
    [buttons addObject:delete];
    
    
    // put the buttons in the toolbar and release them
    [toolbar setItems:buttons animated:NO];
     
     // place the toolbar into the navigation bar
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
}


- (void) createToolBarWihEmpty
{
    self.navigationItem.rightBarButtonItem = nil;
}


- (void) cancelOrder
{
    PersonOrderInfo *orderInfo = self.order.personInfo;
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    
    PHouseApi *apiModel = [[PHouseApi alloc] init];
    [apiModel cancelOrderID:orderInfo.order_id andUserID:[coreProfile profileID] andDelegate:self];
}



- (void) createHeaderWithOrder:(HistoryOrder *)order
{
    headerDetailView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"headerDetailView" owner:self options:nil] objectAtIndex:0];
    [headerView initWithHistoryOrder:order];
    self.tableView.tableHeaderView = headerView;
}



#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.order.prints count];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PrintData *printData = [self.order.prints objectAtIndex:indexPath.row];
    [cell.sizeLabel setText:printData.namePurchase];
    [cell.priceLabel setText:[NSString stringWithFormat:@"%li RUB", (unsigned long)printData.price]];
    [cell.imageCartView setImage:[printData iconShopCart]];
    [cell.countButton setTitle:[NSString stringWithFormat:@"%li", (unsigned long)[printData count]] forState:UIControlStateNormal];
    
    return cell;
}






#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[HistoryDetailPhotoViewController class]]) {
        NSInteger index = [[self.tableView indexPathForSelectedRow] row];
        PrintData *printData = [self.order.prints objectAtIndex:index];
        [segue.destinationViewController setPrintDataOrder:printData];
    }
}



#pragma mark - PHouseApiDelegate
- (void) pHouseApi:(PHouseApi *)phApi didCanceledOrder:(PHResponse *)response
{
    [phApi getHistoryAllOrders:self];
}


-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error
{
    
}




#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self cancelOrder];
    }
}



#pragma mark - Action
- (void) actionPaymentOrderButton:(UIBarButtonItem *)sender
{
    PersonOrderInfo *orderInfo = self.order.personInfo;
    PHouseApi *api = [[PHouseApi alloc] init];
    [api payOrderID:orderInfo.order_id andDelegate:self];
}

- (void) actionCancelOrderButton:(UIBarButtonItem *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Внимание"
                                                    message:@"Вы действительно хотите отменить заказ ?"
                                                   delegate:self
                                          cancelButtonTitle:@"Нет"
                                          otherButtonTitles:@"Отменить заказ", nil];
    [alert show];
}

-(void)pHouseApi:(PHouseApi *)phApi didHistoryOrdersData:(NSArray *)allOrders
{
    //
    for (HistoryOrder *order in allOrders) {
        if ([order.personInfo.order_id isEqualToString:self.order.personInfo.order_id]) {
            self.order = order;
        }
    }
    
    //
    [self createHeaderWithOrder:self.order];
    
    // Reload
    [self.tableView reloadData];
    
    // Remove Pay And RemoveButtons
    [self createToolBarWihEmpty];
    
    
    //
    NSNotification *notification = [NSNotification notificationWithName:HistoryMainReloadNotification object:allOrders userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


-(void)pHouseApi:(PHouseApi *)phApi didPayURL:(NSURL *)payURL
{
    [[UIApplication sharedApplication] openURL:payURL];
}


#pragma mark - Public
- (void) setHistoryOrder:(HistoryOrder *) order {
    self.order = order;
}

@end
