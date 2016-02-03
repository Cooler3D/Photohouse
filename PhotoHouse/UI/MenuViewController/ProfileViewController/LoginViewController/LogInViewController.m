//
//  LogInViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/11/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "LogInViewController.h"

#import "SkinModel.h"
#import "AnaliticsModel.h"

#import "PHouseApi.h"
#import "ResponseAuth.h"

#import "MBProgressHUD.h"

#import "NSString+MD5.h"
#import "UITextField+Email.h"

#import "UIView+Toast.h"


NSString *AutorizationCompleteNotification = @"AutorizationCompleteNotification";
NSString *AutorizationCancelNotification = @"AutorizationCancelNotification";

typedef enum {
    TextFieldEmail,
    TextFieldPassword
}TextFieldType;



@interface LogInViewController () <PHouseApiDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@end




@implementation LogInViewController

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
    
    // Analitics
    [[AnaliticsModel sharedManager] setScreenName:@"LogIn Screen"];
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(@"signin_title", nil)];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.closeButton setTintColor:[UIColor whiteColor]];
    
    
    //
    // Single Click
    UITapGestureRecognizer *gestureTab =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleTab:)];
    
    [self.view addGestureRecognizer:gestureTab];

    
    // Localization
    [self.emailTextField setPlaceholder:NSLocalizedString(@"input_email", nil)];
    [self.passwordTextField setPlaceholder:NSLocalizedString(@"input_password", nil)];
    [self.closeButton setTitle:NSLocalizedString(@"Cancel", nil)];
    [self.signInButton setTitle:NSLocalizedString(@"signin_btn", nil) forState:UIControlStateNormal];
    [self.forgotButton setTitle:NSLocalizedString(@"signin_forgot_btn", nil) forState:UIControlStateNormal];
    [self.signUpButton setTitle:NSLocalizedString(@"singup_title", nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Gestures
- (void) handleTab:(UIGestureRecognizer*)gestureTab {
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //
    if (textField.tag == TextFieldEmail) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField.tag == TextFieldPassword) {
        [self.passwordTextField resignFirstResponder];
        
        [self autorization];
    }
    
    
    return YES;
}



// Начали редактирование
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (CGRectGetHeight(self.view.frame) > 500) {
        return;
    }
    
    if (textField == self.passwordTextField) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y - 50), self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }
}

// Закончили редактирование
-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (CGRectGetHeight(self.view.frame) > 500) {
        return;
    }
    
    if (textField == self.passwordTextField) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y + 50), self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }
    
}

#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didAuthReceiveData:(PHResponse *)response
{
    // Analitics
    ResponseAuth *resp = (ResponseAuth *)response;
    NSInteger id_user = [resp.id_user integerValue];
    NSString *stringLabel = [NSString stringWithFormat:@"Complete. UserID: %@", resp.id_user];
    [[AnaliticsModel sharedManager] sendEventCategory:@"LogIn" andAction:@"Action" andLabel:stringLabel withValue:[NSNumber numberWithInteger:id_user]];
    

    //[self statusText:@"autorization complete"];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AutorizationCompleteNotification object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error
{
    // Analitics
    NSString *stringLabel = [NSString stringWithFormat:@"Error. Code: %li", (long)error.code];
    [[AnaliticsModel sharedManager] sendEventCategory:@"LogIn" andAction:@"Action" andLabel:stringLabel withValue:[NSNumber numberWithInteger:error.code]];
    
    
    [self statusText:NSLocalizedString([error.userInfo objectForKey:@"ErrorKey"], nil)];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


#pragma mark - Methods
- (void) statusText:(NSString*)status {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:status delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}


#pragma mark - Actions
- (IBAction)actionLogInButton:(UIButton *)sender {
    [self autorization];
}
- (IBAction)actionCloseButton:(UIBarButtonItem *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:AutorizationCancelNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Methods
- (void) autorization {
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if ([email length] < 3) {
        [self statusText:NSLocalizedString(@"input_email", nil)];
        return;
    }
    
    if ([password length] < 1) {
        [self statusText:NSLocalizedString(@"input_password", nil)];
        return;
    }
    
    //
    PHouseApi *model = [[PHouseApi alloc] init];
    NSString *salt = [NSString stringWithFormat:@"%@%@", model.salt, password];
    NSString *pass = [salt MD5];
    [model authLogin:email andPasswordHash:pass andDelegate:self];
    
    //
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"signin_title", nil);
}

@end
