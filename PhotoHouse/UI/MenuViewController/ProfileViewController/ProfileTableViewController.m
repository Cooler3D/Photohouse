//
//  ProfileTableViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 10/7/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "MenuTableViewController.h"

#import "UIViewController+ECSlidingViewController.h"
#import "ECSlidingViewController.h"

#import "SkinModel.h"
#import "AnaliticsModel.h"

#import "MBProgressHUD.h"

#import "PHouseApi.h"
#import "ResponseAuth.h"

#import "CoreDataProfile.h"

#import "NSDate+ServerTime.h"


NSString *const SEGUE_GO_AUTH = @"segue_goAuth";

typedef enum {
    StatusAuthAutorize,
    StatusAuthExit
} StatusAuth;


@interface ProfileTableViewController () <PHouseApiDelegate>
@property (assign, nonatomic) MDMenuSlideType menuSlideType;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateRegLabel;
@property (weak, nonatomic) IBOutlet UIButton *authExitButton;

@property (weak, nonatomic) IBOutlet UILabel *firstNameConstLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastNameConstLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailNameConstLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateNameConstLabel;

@property (assign, nonatomic) StatusAuth statusAuth;
@property (strong, nonatomic) ResponseAuth *response;
@end



@implementation ProfileTableViewController

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
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(@"profile_title", nil)];
    
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
    
    
    
    // Default
    [self clearProfileinputs];
    
    
    //
    /*MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Авторизация";*/
    
    //CheckAuth
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    if (!coreProfile.profileID) {
        self.statusAuth = StatusAuthExit;
        // Go Auth
        [self performSegueWithIdentifier:SEGUE_GO_AUTH sender:self];
    } else {
        
        self.statusAuth = StatusAuthAutorize;
        ResponseAuth *responseAuth = [coreProfile profile];
        [self pHouseApi:nil didAuthReceiveData:responseAuth];
    }
    
    
    // Localization
    [self.firstNameConstLabel setText:NSLocalizedString(@"profile_firstname:", nil)];
    [self.lastNameConstLabel setText:NSLocalizedString(@"profile_lastname:", nil)];
    [self.emailNameConstLabel setText:NSLocalizedString(@"profile_email:", nil)];
    [self.dateNameConstLabel setText:NSLocalizedString(@"profile_date_reg:", nil)];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    if (coreProfile.profileID) {
        ResponseAuth *responseAuth = [coreProfile profile];
        [self pHouseApi:nil didAuthReceiveData:responseAuth];
    } else {
        [self clearProfileinputs];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) clearProfileinputs {
    [self.firstNameLabel setText:@""];
    [self.secondNameLabel setText:@""];
    [self.emailLabel setText:@""];
    [self.dateRegLabel setText:@""];

    self.statusAuth = StatusAuthAutorize;
}





#pragma mark - Gesture
- (void)gestureSwipe:(UISwipeGestureRecognizer *)gesture {
    [self actionMenuBarButton:nil];
}





#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didAuthReceiveData:(PHResponse *)response
{
    ResponseAuth *resp = (ResponseAuth *)response;
    _response = resp;
    [self.firstNameLabel setText:resp.firstname];
    [self.secondNameLabel setText:resp.lastname];
    [self.emailLabel setText:resp.email];
    [self.dateRegLabel setText:[NSDate convertFromServerTime:resp.regdate]];
    
    //
    self.statusAuth = StatusAuthAutorize;
    
    
    //
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error
{
    switch ((ErrorCodeTypes)error.code) {
        case ErrorCodeTypeAutorizationFaled:
        case ErrorCodeTypeNotLoginAndPassword:
            [self.authExitButton setTitle:NSLocalizedString(@"signin_title", nil) forState:UIControlStateNormal];
            self.statusAuth = StatusAuthExit;
            break;
            
        case ErrorCodeTypeInternalParse:
        case ErrorCodeTypeNotConnectToInternet:
            [self showAlertText:[error localizedDescription]];
            break;
            
        default:
            break;
    }
    
    //
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - Methods
- (void) showAlertText:(NSString*)stringText {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:stringText delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
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


- (IBAction)actionExitButton:(UIButton *)sender {
    // Analitics
    NSInteger id_user = [_response.id_user integerValue];
    NSString *stringLabel = [NSString stringWithFormat:@"Logout. UserID: %@", _response.id_user];
    [[AnaliticsModel sharedManager] sendEventCategory:@"Profile" andAction:@"Action" andLabel:stringLabel withValue:[NSNumber numberWithInteger:id_user]];
    
    
    //
    if (self.statusAuth == StatusAuthExit) {
        // Logout
        [[[PHouseApi alloc] init] logout];
        [self clearProfileinputs];
        self.statusAuth = StatusAuthExit;
        
    } else {
        // Go Auth
        [self performSegueWithIdentifier:SEGUE_GO_AUTH sender:self];
    }
}

-(void)setStatusAuth:(StatusAuth)statusAuth {
    _statusAuth = statusAuth;
    
    if (statusAuth == StatusAuthAutorize) {
        [self.authExitButton setTitle:NSLocalizedString(@"signin_title", nil) forState:UIControlStateNormal];
    } else {
        [self.authExitButton setTitle:NSLocalizedString(@"profile_logount", nil) forState:UIControlStateNormal];
    }
}

@end
