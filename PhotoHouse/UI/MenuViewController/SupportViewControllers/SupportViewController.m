//
//  SupportViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 12/8/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "SupportViewController.h"

#import "MenuTableViewController.h"

#import "UIViewController+ECSlidingViewController.h"
#import "ECSlidingViewController.h"


#import "SkinModel.h"
#import "PHouseApi.h"
#import "AnaliticsModel.h"

#import "PHouseApi.h"
#import "ResponseAuth.h"

#import "MBProgressHUD.h"


NSString *const MESSAGE_DEFAULT_TEXT = @"support_default_message";


@interface SupportViewController () <PHouseApiDelegate, PHouseApiDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (assign, nonatomic) MDMenuSlideType menuSlideType;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) ResponseAuth *response;
@end



@implementation SupportViewController

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
    
    //
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(@"support_title", nil)];
    
    [self.menuBarButton setTintColor:[UIColor whiteColor]];

    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuTableViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:Menu_StoryboardID];
    }
    
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
    
    
    //
    [self.messageTextView setText:MESSAGE_DEFAULT_TEXT];
    
    //
    //
    /*PhotoHouseAccountUser *user = [[PhotoHouseAPIModel sharedManager] photoHouseUser];
    if (user) {
        [self.nameTextField setText:user.firstname];
        [self.emailTextField setText:user.email];
    } else {*/
        PHouseApi *apiModel = [[PHouseApi alloc] init];
        [apiModel authWithDelegate:self];
    
    //}
    
    
    // Localization
    [self.nameTextField setPlaceholder:NSLocalizedString(@"input_firstname", nil)];
    [self.emailTextField setPlaceholder:NSLocalizedString(@"input_email", nil)];
    [self.messageTextView setText:NSLocalizedString(MESSAGE_DEFAULT_TEXT, nil)];
    [self.sendButton setTitle:NSLocalizedString(@"send_button", nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)shouldAutorotate {
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}




#pragma mark - Gesture
- (void)gestureSwipe:(UISwipeGestureRecognizer *)gesture {
    //[self.revealViewController revealToggle:self];
    [self actionMenuBarButton:nil];
}








#pragma mark - Private
- (void) showAlertTitle:(NSString*)title andText:(NSString*)text {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}


/*#pragma mark - PhotoHouseAPIDelegate
-(void)photoHouseFeedBackComplete {
    [self showAlertTitle:@"Выполненно" andText:@"Успешно выполненно"];
}*/



/*-(void)photoHouseError:(NSString *)errorText withErrorCode:(ErrorCodeTypes)errorCode {
    if (errorCode == ErrorCodeTypeNotLoginAndPassword) {
        return;
    }
    [self showAlertTitle:@"Ошибка" andText:errorText];
}

-(void)photoHouseAPIModel:(PhotoHouseAPIModel *)model autorizationComplete:(PhotoHouseAccountUser *)photoHouseUser {
    [self.nameTextField setText:photoHouseUser.firstname];
    [self.emailTextField setText:photoHouseUser.email];
}*/

#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didAuthReceiveData:(PHResponse *)response
{
    ResponseAuth *respAuth = (ResponseAuth *)response;
    [self.nameTextField setText:respAuth.firstname];
    [self.emailTextField setText:respAuth.email];
}

-(void)pHouseApi:(PHouseApi *)phApi didFeedBackData:(PHResponse *)response
{
    [self showAlertTitle:NSLocalizedString(@"complete", nil) andText:NSLocalizedString(@"your_message_is_did_delivered", nil)];
}

-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error {
    if (error.code == ErrorCodeTypeNotLoginAndPassword || error.code == ErrorCodeTypeAutorizationFaled) {
        return;
    }
    [self showAlertTitle:NSLocalizedString(@"error", nil) andText:[error localizedDescription]];
}



#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    // Check Menu Opened
    if (self.menuSlideType == MDMenuSlideTypeOpened) {
        [self actionMenuBarButton:self.menuBarButton];
        return NO;
    }
    
    if ([textView.text isEqualToString:NSLocalizedString(MESSAGE_DEFAULT_TEXT, nil)]) {
        [textView setText:@""];
    }
    
    return YES;
}


#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Check Menu Opened
    if (self.menuSlideType == MDMenuSlideTypeOpened) {
        [self actionMenuBarButton:self.menuBarButton];
        return;
    }
}



#pragma mark - Actions
- (IBAction) actionSendButton:(UIButton*)sender {
    // Check Menu Opened
    if (self.menuSlideType == MDMenuSlideTypeOpened) {
        [self actionMenuBarButton:self.menuBarButton];
        return;
    }
    
    
    if ([self.nameTextField.text length] < 2) {
        [self showAlertTitle:NSLocalizedString(@"error", nil) andText:NSLocalizedString(@"input_firstname", nil)];
        return;
    }
    
    if ([self.emailTextField.text length] < 2) {
        [self showAlertTitle:NSLocalizedString(@"error", nil) andText:NSLocalizedString(@"input_email", nil)];
        return;
    }
    
    
    /*NSString *title;
    switch (self.inputType) {
        case FeedBackError:
            title = @"Обратная связь.Мобильное приложение.Ошибка";
            break;
            
        case FeedBackUpdate:
            title = @"Обратная связь.Мобильное приложение.Другое";
            break;
            
        case FeedBackOther:
            title = @"Обратная связь.Мобильное приложение.Улучшение";
            break;
    }*/
    
    
    NSString *messageText = [NSString stringWithFormat:@"Письмо от %@(%@)\n\n%@", self.nameTextField.text, self.emailTextField.text, self.messageTextView.text];
    
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"sending_message", nil);
    
    //
    /*PhotoHouseAPIModel *apiModel = [PhotoHouseAPIModel sharedManager];
    [apiModel setDelegate:self];
    [apiModel sendFeedBackType:FeedBackError andTitle:@"FeedBack" andMessageText:messageText andEmail:self.emailTextField.text];*/
    PHouseApi *phouseApi = [[PHouseApi alloc] init];
    [phouseApi feedbackType:1 andTitle:@"FeedBack" andMessage:messageText andEmail:self.emailTextField.text andDelegate:self];
    
    
    
    // Analitics
    NSString *label = [NSString stringWithFormat:@"E-mail: %@; UserID: %@", self.emailTextField.text, _response.id_user];
    [[AnaliticsModel sharedManager] sendEventCategory:@"Support" andAction:@"Send Message" andLabel:label withValue:nil];
}


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
