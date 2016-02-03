//
//  RecoveryPasswordViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 2/6/15.
//  Copyright (c) 2015 Дмитрий Мартынов. All rights reserved.
//

#import "RecoveryPasswordViewController.h"

#import "PHouseApi.h"

#import "UITextField+Email.h"

#import "MBProgressHUD.h"

#import "AnaliticsModel.h"
#import "SkinModel.h"


@interface RecoveryPasswordViewController () <UITextFieldDelegate, PHouseApiDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@end



@implementation RecoveryPasswordViewController

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
    [[AnaliticsModel sharedManager] setScreenName:@"Restore Screen"];
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(@"forgot_password_title", nil)];
    
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    
    
    // Localizaton
    [self.textField setPlaceholder:NSLocalizedString(@"input_email", nil)];
    [self.sendButton setTitle:NSLocalizedString(@"send_button", nil) forState:UIControlStateNormal];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendRecoveryEmail:textField.text];
    return YES;
}



-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [textField emailShouldChangeCharactersInRange:range replacementString:string];
}



#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error
{
    [self showAlertTitle:NSLocalizedString(@"error", nil) andMessage:[error.userInfo objectForKey:@"ErrorKey"]];
}


-(void)pHouseApi:(PHouseApi *)phApi didRestorePassData:(PHResponse *)response
{
    [self showAlertTitle:NSLocalizedString(@"complete", nil) andMessage:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"message_is_did_sended_to", nil), self.textField.text]];
}




#pragma mark - Action
- (IBAction)actionrecoveryButton:(UIButton *)sender
{
    if (self.textField.text.length < 4) {
        [self showAlertTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"email_is_too_short", nil)];
        return;
    }
    
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    [hud setLabelText:NSLocalizedString(@"sending", nil)];
    
    
    [self sendRecoveryEmail:self.textField.text];
}



#pragma mark - Method
- (void) showAlertTitle:(NSString *)title andMessage:(NSString *)message
{
    //
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    //
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



- (void) sendRecoveryEmail:(NSString *)email {
    PHouseApi *api = [[PHouseApi alloc] init];
    [api restorePassWithEmail:self.textField.text andDelegate:self];
}
@end
