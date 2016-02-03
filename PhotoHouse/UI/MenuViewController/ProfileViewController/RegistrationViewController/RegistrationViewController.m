//
//  RegistrationViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/11/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "RegistrationViewController.h"

#import "SkinModel.h"

#import "PHouseApi.h"

#import "AnaliticsModel.h"

#import "MBProgressHUD.h"

#import "CoreDataProfile.h"

#import "UITextField+Email.h"

#import "UIView+Toast.h"

NSString *RegistrationCompleteNotification = @"RegistrationCompleteNotification";
NSString *RegistrationCancelNotification = @"RegistrationCancelNotification";


typedef enum {
    TextFieldFirstName,
    TextFieldLastName,
    TextFieldEmail,
    TextFieldPassword,
    TextFieldRetryPassword
}TextFieldType;



@interface RegistrationViewController () <PHouseApiDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UILabel *statusTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *registrationButton;
@end



@implementation RegistrationViewController

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
    
    //
    [[AnaliticsModel sharedManager] setScreenName:@"Registration Screen"];
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(@"singup_title", nil)];
    
    [self.closeButton setTintColor:[UIColor whiteColor]];
    
    
    
    //
    // Tap
    UITapGestureRecognizer *gestureTab =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleTab:)];
    [self.view addGestureRecognizer:gestureTab];
    
    // Swipes
    UISwipeGestureRecognizer *gestureVericalSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleVerticalSwipe:)];
    gestureVericalSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    gestureVericalSwipe.delegate = self;
    [self.view addGestureRecognizer:gestureVericalSwipe];
    
    

    // Localization
    UITextField *firstName = [self.textFields objectAtIndex:TextFieldFirstName];
    UITextField *lastName = [self.textFields objectAtIndex:TextFieldLastName];
    UITextField *emailName = [self.textFields objectAtIndex:TextFieldEmail];
    UITextField *passwordName = [self.textFields objectAtIndex:TextFieldPassword];
    UITextField *passwordRepeatName = [self.textFields objectAtIndex:TextFieldRetryPassword];
    [firstName setPlaceholder:NSLocalizedString(@"input_firstname", nil)];
    [lastName setPlaceholder:NSLocalizedString(@"input_lastname", nil)];
    [emailName setPlaceholder:NSLocalizedString(@"input_email", nil)];
    [passwordName setPlaceholder:NSLocalizedString(@"input_password", nil)];
    [passwordRepeatName setPlaceholder:NSLocalizedString(@"input_password", nil)];
    [self.closeButton setTitle:NSLocalizedString(@"Cancel", nil)];
    [self.registrationButton setTitle:NSLocalizedString(@"singup_title", nil) forState:UIControlStateNormal];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gestures
- (void) handleTab:(UIGestureRecognizer*)gestureTab {
    for (UITextField *textfield in self.textFields) {
        if ([textfield isFirstResponder]) {
            [textfield resignFirstResponder];
        }
    }
}

- (void) handleVerticalSwipe:(UISwipeGestureRecognizer*)gesture {
    for (UITextField *textfield in self.textFields) {
        if ([textfield isFirstResponder]) {
            [textfield resignFirstResponder];
        }
    }
}



#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didReqistrationReceiveData:(PHResponse *)response
{
    //ResponseAuth *responseAuth = (ResponseAuth *)response;
    CoreDataProfile *profile = [[CoreDataProfile alloc] init];
    NSInteger id_user = [profile.profileID integerValue];
    NSString *stringLabel = [NSString stringWithFormat:@"Complete. UserID: %@", profile.profileID];
    [[AnaliticsModel sharedManager] sendEventCategory:@"Registration" andAction:@"Action" andLabel:stringLabel withValue:[NSNumber numberWithInteger:id_user]];
    
    [self.registrationButton setEnabled:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RegistrationCompleteNotification object:nil];
}

-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error
{
    //
    NSString *stringLabel = [NSString stringWithFormat:@"Error. Code: %li", (unsigned long)error.code];
    [[AnaliticsModel sharedManager] sendEventCategory:@"Registration" andAction:@"Action" andLabel:stringLabel withValue:[NSNumber numberWithInteger:error.code]];
    
    [self.registrationButton setEnabled:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self statusAlertText:NSLocalizedString([error.userInfo objectForKey:@"ErrorKey"], nil)];
}


#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == TextFieldEmail) {
        return [textField emailShouldChangeCharactersInRange:range replacementString:string];
    } else {
        return YES;
    }
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    for (int i=0; i<[self.textFields count]; i++) {
        UITextField *textField = [self.textFields objectAtIndex:i];
        if(i == [self.textFields count] - 1) {
            [textField resignFirstResponder];
            [self actionRegistration:nil];
            
        } else if([textField isFirstResponder]) {
            textField = [self.textFields objectAtIndex:i+1];
            [textField becomeFirstResponder];
            return NO;
        }
        
    }

    
    return YES;
}

// Начали редактирование
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    UITextField *lastTextField = (UITextField*)[self.textFields lastObject];
    
    if (CGRectGetHeight(self.view.frame) > 500) {
        return;
    }
    
    if (textField == lastTextField) {
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
    
    UITextField *lastTextField = (UITextField*)[self.textFields lastObject];
    if (textField == lastTextField) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y + 50), self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }
    
}



#pragma mark - Actions
- (IBAction)actionRegistration:(UIButton *)sender {
    NSString *firstName = [(UITextField*)[self.textFields objectAtIndex:0] text];
    NSString *lastName  = [(UITextField*)[self.textFields objectAtIndex:1] text];
    NSString *email     = [(UITextField*)[self.textFields objectAtIndex:2] text];
    NSString *pass      = [(UITextField*)[self.textFields objectAtIndex:3] text];
    NSString *elsepass  = [(UITextField*)[self.textFields objectAtIndex:4] text];
    
    //
    if ([firstName length] < 1) {
        [self statusText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"firstname", nil), NSLocalizedString(@"is_too_short", nil)]];
        return;
    }
    
    if ([lastName length] < 1) {
        [self statusText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"lastname", nil), NSLocalizedString(@"is_too_short", nil)]];
        return;
    }
    
    if ([email length] < 3) {
        [self statusText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"email", nil), NSLocalizedString(@"is_too_short", nil)]];
        return;
    }
    
    if ([pass length] < 3) {
        [self statusText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"password", nil), NSLocalizedString(@"is_too_short", nil)]];
        return;
    }
    
    if ([elsepass length] < 3) {
        [self statusText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"password", nil), NSLocalizedString(@"is_too_short", nil)]];
        return;
    }
    
    if (![elsepass isEqualToString:pass]) {
        [self statusText:NSLocalizedString(@"passwords_is_not_equal", nil)];
        return;
    }
    
    //
    [sender setEnabled:NO];
    
    
    //
    [self statusText:@""];
    
    //
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"singup_title", nil);
    
    //
    PHouseApi *phouseApi = [[PHouseApi alloc] init];
    [phouseApi registationFirstName:firstName andLastName:lastName andEmail:email withPassword:pass andDelegate:self];
}


- (IBAction)actionCloseButton:(UIBarButtonItem *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:RegistrationCancelNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) statusText:(NSString*)status {
    CGPoint point = CGPointMake(CGRectGetMidX(self.view.frame),
                                CGRectGetMidY(self.view.frame));
    [self.view makeToast:status
                duration:1.f
                position:[NSValue valueWithCGPoint:point]
                   title:NSLocalizedString(@"error", nil)
                   image:nil];

}

- (void) statusAlertText:(NSString*)status {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:status delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

@end
