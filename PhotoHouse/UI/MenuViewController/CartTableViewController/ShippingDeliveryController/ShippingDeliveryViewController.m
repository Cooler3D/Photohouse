//
//  ShippingDeliveryViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 9/11/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "ShippingDeliveryViewController.h"

#import "MenuTableViewController.h"

#import "PopUpListView.h"

#import "SkinModel.h"
#import "PHouseApi.h"

#import "CoreDataShopCart.h"
#import "AnaliticsModel.h"

#import "MBProgressHUD.h"
#import "CustomProgressView.h"

#import "PHouseApi.h"
#import "CoreDataProfile.h"
#import "ResponseGetDeliveries.h"
#import "ResponseMakeOrdes.h"
#import "ResponseAuth.h"
#import "DeliveryCity.h"
#import "DeliveryType.h"
#import "Payment.h"

#import "PhAppNotifications.h"

#import "UploadImageManager.h"

#import "StoreItem.h"
#import "PrintData.h"
#import "PrintImage.h"


NSInteger const REUPLOAD_MAX_COUNT = 12;

NSString *const GoToHistorySegue = @"HistorySegue";

NSString *const DELIVERY_TEXT_DEFAULT = @"Введите ваш комментарий, например:\nУдобное время доставки, код домофона, имя получателя и т.д.";

typedef enum {
    TextFielTypeFirstName,
    TextFielTypeLastName,
    TextFielTypeAddress,
    TextFielTypePhone
}TextFielType;


typedef enum {
    UIFirstName = 0 << 16,
    UILastName  = 1 << 16,
    UIFather    = 1 << 2,
    UIAddress   = 1 << 3,
    UIPhone     = 1 << 4,
    UIPostCity  = 1 << 5,
    UIPostindex = 1 << 6,
    UIDeliveryCity = 1 << 7,
    UIPayment   = 1 << 8,
    UIComment   = 1 << 9,
    UISend      = 1 << 10
} UIComponentType;



typedef enum {
    AlertTypeUpload,
    AlertTypeDeliveryOk
} AlertType;


@interface ShippingDeliveryViewController () <UITextViewDelegate, UITextFieldDelegate, PopUpListDelegate, UIAlertViewDelegate, PHouseApiDelegate, UploadImageManagerDelegate>
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UITextView *informationTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *deliveryButton;
@property (weak, nonatomic) IBOutlet UIButton *paymentButton;

@property (weak, nonatomic) PopUpListView *popUpView;

@property (strong, nonatomic) NSMutableArray *allOrders;
@property (weak, nonatomic) MBProgressHUD *hud;
@property (weak, nonatomic) CustomProgressView *customProgressView;

@property (strong, nonatomic) ResponseGetDeliveries *response;
@property (strong, nonatomic) DeliveryCity *deliveryCity;
@property (strong, nonatomic) DeliveryType *deliveryType;
@property (strong, nonatomic) Payment *paymentType;


@property (assign, nonatomic) UIComponentType componentDelivery;

@property (strong, nonatomic) UploadImageManager *uploadManager;


/// Сообщение о отмене загрузки
@property (weak, nonatomic) UIAlertView *alertView;
@end



@implementation ShippingDeliveryViewController
{
    NSInteger reUploadCount;
    
    
}


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
    [[AnaliticsModel sharedManager] setScreenName:@"Shop Delivery Screen"];
    
    
    // Init PopUp
    PopUpListView *popUp = [[[NSBundle mainBundle] loadNibNamed:@"PopUpListView" owner:self options:nil] firstObject];
    [popUp setCenter:CGPointMake(160, 200)];
    [popUp setHidden:YES];
    [self.view addSubview:popUp];
    self.popUpView = popUp;
    
    
    self.componentDelivery = UIFirstName | UIAddress;
    if (self.componentDelivery & UILastName) {
        NSLog(@"LastName");
    }
    if (self.componentDelivery & UIFirstName) {
        NSLog(@"FirstName");
    }
    if (self.componentDelivery & UIAddress) {
        NSLog(@"Address");
    }
    
    if (self.componentDelivery & UIComment) {
        NSLog(@"Comment");
    }
    
    
    // Navigation Bar
    SkinModel *photomodel = [SkinModel sharedManager];
    self.navigationItem.titleView = [photomodel headerForViewControllerWithTitle:NSLocalizedString(@"delivery_title", nil)];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[photomodel headerColorWithViewController]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    
    
    // Default
//#warning ToDo: Uncomment
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    ResponseAuth *profile = [coreProfile profile];
    
    UITextField *firstNameTextField = [self.textFields objectAtIndex:TextFielTypeFirstName];
    [firstNameTextField setText:[profile.firstname stringByReplacingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding]];
    
    UITextField *lastNameTextField = [self.textFields objectAtIndex:TextFielTypeLastName];
    [lastNameTextField setText:[profile.lastname stringByReplacingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding]];
    
    
    UITextField *addressTextField = [self.textFields objectAtIndex:TextFielTypeAddress];
    UITextField *phoneTextField = [self.textFields objectAtIndex:TextFielTypePhone];
    [firstNameTextField setPlaceholder:NSLocalizedString(@"input_firstname", nil)];
    [lastNameTextField setPlaceholder:NSLocalizedString(@"input_lastname", nil)];
    [addressTextField setPlaceholder:NSLocalizedString(@"input_adsress", nil)];
    [phoneTextField setPlaceholder:NSLocalizedString(@"input_phone", nil)];
    
    
    
    //
    [self.deliveryButton.titleLabel setNumberOfLines:0];
    [self.deliveryButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.deliveryButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.paymentButton.titleLabel setNumberOfLines:0];
    [self.paymentButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.paymentButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.informationTextView setText:DELIVERY_TEXT_DEFAULT];
    [self.informationTextView setTextColor:[UIColor grayColor]];
    
    
    
    //
    // Single Click
    UITapGestureRecognizer *gestureTab =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleTab:)];
    [self.view addGestureRecognizer:gestureTab];
    
    
    
    // Delivery
    /*PHouseApi *pHouseApi = [[PHouseApi alloc] init];
    [pHouseApi getDeliveriesWithDelegate:self];
    [pHouseApi getPhonesListAndSaveToProfileWithDelegate:self];
    [pHouseApi getAddressListAndSaveToProfileWithDelegate:self];*/
    PHouseApi *model = [[PHouseApi alloc] init];
    
    
    // Возможно они уже сохранены
//#warning ToDo: Uncomment
    if (!coreProfile.getAddressProfile)
    {
        // Требуется получить адрес
        [model getAddressListAndSaveToProfileWithDelegate:self];
    }
    else
    {
        // Address
        [self pHouseApi:nil didLastAddress:[coreProfile getAddressProfile]];
    }
    
    if (!coreProfile.getAddressProfile)
    {
        // Требуется получить адрес
        [model getPhonesListAndSaveToProfileWithDelegate:self];
    }
    else
    {
        // Address
        [self pHouseApi:nil didLastPhone:[coreProfile getPhoneProfile]];
    }

    
    ResponseGetDeliveries *delivery = [[ResponseGetDeliveries alloc] init];
    [self pHouseApi:nil didDeliveriesReceiveData:delivery];
}



-(void)viewDidAppear:(BOOL)animated {
    // Navigation Bar
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    
    // Custom BackButton
    UIImage *image = [UIImage imageNamed:@"prevNavigation"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionBackBarButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [barButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:barButton animated:NO];

}





-(void)viewWillDisappear:(BOOL)animated
{
    // Save Address and Phone
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    UITextField *addressTextField = [self.textFields objectAtIndex:TextFielTypeAddress];
    if (![addressTextField.text isEqualToString:@""]) {
        [coreProfile saveAddress:addressTextField.text];
    }
    
    UITextField *phoneTextField = [self.textFields objectAtIndex:TextFielTypePhone];
    if (![phoneTextField.text isEqualToString:@""]) {
        [coreProfile savePhone:phoneTextField.text];
    }
    
    // Save Delivery
    [coreProfile saveDeliveryUiCityName:_deliveryCity.uiname andDeliveryCode:_deliveryType.code andUiPaymentName:_paymentType.uiname];
    
    
//    // Stop Upload
//    if (_uploadManager) {
//        [_uploadManager stopUpload];
//    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Gestures
- (void) handleTab:(UIGestureRecognizer*)gestureTab {
    for (UITextField *textfield in self.textFields) {
        [textfield resignFirstResponder];
    }
    [self.informationTextView resignFirstResponder];
}




#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    for (int i=0; i<[self.textFields count]; i++) {
        UITextField *textField = [self.textFields objectAtIndex:i];
        if(i == [self.textFields count] - 1) {
            [textField resignFirstResponder];
            
        } else if([textField isFirstResponder]) {
            textField = [self.textFields objectAtIndex:i+1];
            [textField becomeFirstResponder];
            return NO;
        }
        
    }
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([[self.textFields objectAtIndex:TextFielTypeAddress] isEqual:textField]) {
        return YES;
    }
    
    if (![[self.textFields objectAtIndex:TextFielTypePhone] isEqual:textField]) {
        return NO;
    }
    
    /*NSLog(@"textField test: %@", textField.text);
    NSLog(@"range: %@", NSStringFromRange(range));
    NSLog(@"new symbols: %@", string);*/
    
    NSCharacterSet *validator = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray *components = [string componentsSeparatedByCharactersInSet:validator];
    
    if ([components count] > 1) {
        return NO;
    }
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    //NSLog(@"newString: %@", newString);
    
    
    NSArray *validComponents = [newString componentsSeparatedByCharactersInSet:validator];
    newString = [validComponents componentsJoinedByString:@""];
    
    
    
    
    NSMutableString *resultString = [NSMutableString string];
    
    
    
    static const int localNumberMaxLenght = 7;
    static const int areaCodeMaxLenght = 3;
    static const int contryCodeMaxLenght = 0;
    
    
    /*
     +XX (XXX) XXX-XXXX
     */
    
    NSInteger localNumberlenght = MIN([newString length], localNumberMaxLenght);
    
    if (localNumberlenght > 0) {
        NSString *number = [newString substringFromIndex:(int)[newString length] - localNumberlenght];
        
        [resultString appendString:number];
        
        if ([resultString length] > 3) {
            [resultString insertString:@"-" atIndex:3];
        }
    }
    
    
    
    if ([newString length] > localNumberMaxLenght) {
        NSInteger areaCodeLenght = MIN((int)[newString length] - localNumberMaxLenght, areaCodeMaxLenght);
        
        NSRange codeRange = NSMakeRange((int)[newString length] - localNumberMaxLenght - areaCodeLenght, areaCodeLenght);
        
        NSString *area = [newString substringWithRange:codeRange];
        
        area = [NSString stringWithFormat:@"(%@) ", area];
        
        [resultString insertString:area atIndex:0];
    }
    
    
    if ([newString length] > localNumberMaxLenght + contryCodeMaxLenght) {
        NSInteger countryCodeLenght = MIN((int)[newString length] - localNumberMaxLenght - contryCodeMaxLenght, contryCodeMaxLenght);
        
        NSRange countryRange = NSMakeRange(0, countryCodeLenght);
        
        NSString *country = [newString substringWithRange:countryRange];
        
        //country = [NSString stringWithFormat:@"+%@ ", country];
        
        [resultString insertString:country atIndex:0];
    }
    
    textField.text = resultString;
    
    return NO;
}




#pragma mark - UITextViewDelegate
// Начали редактирование
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == self.informationTextView) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y - 165), self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }
}



// Закончили редактирование
-(void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == self.informationTextView) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationBeginsFromCurrentState:YES];
        self.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y + 165), self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
    }
}



-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:DELIVERY_TEXT_DEFAULT]) {
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        [textView setText:DELIVERY_TEXT_DEFAULT];
        [textView setTextColor:[UIColor grayColor]];
    }
    return YES;
}




/*#pragma mark - UploadImageQueueDelegate
- (void) uploadImagesQueue:(UploadImageQueue *)queueModel didUploadedAllImagesComplete:(NSArray *)records
{
    // ProgressBar
    [self.customProgressView removeFromSuperview];
    [self.hud setLabelText:@"Отправка"];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    
    // Send
    NSArray *deliveryOrder = [_response getDeliveryForOrderWithDeliveryCity:_deliveryCity];
    [self.allOrders addObject:deliveryOrder];
    [self sendToPhotoHouse:self.allOrders];
}


- (void) uploadImagesQueue:(UploadImageQueue *)queueModel didUploadImagesGeneralProgress:(CGFloat)progress
{
    if (self.hud && self.customProgressView) {
        [self.customProgressView setProgressMain:progress];
    }
}

- (void) uploadImagesQueue:(UploadImageQueue *)queueModel didUploadSingleProgress:(CGFloat)progress
{
    if (self.hud && self.customProgressView) {
        [self.customProgressView setProgressDetail:progress];
    }
}


-(void)uploadImagesQueue:(UploadImageQueue *)queueModel didUploadedFailWithError:(NSError *)error
{
    if (reUploadCount <= 0)
    {
        // Show Message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                        message:error.localizedDescription
                                                       delegate:self
                                              cancelButtonTitle:@"Отмена"
                                              otherButtonTitles:@"Повторить попытку",
                              nil];
        [alert show];
    }
    else
    {
        // ReUpload
        [self.uploadImageQueue reUploadImage];
        reUploadCount--;
    }
}*/





#pragma mark - UploadImageManagerDelegate
-(void)uploadImageManager:(UploadImageManager *)manager didImagesSaved:(PrintImage *)printImage withPrintData:(PrintData *)printData
{
}

-(void)uploadImageManager:(UploadImageManager *)manager didAllImagesSaved:(PrintData *)printData
{
    [self.customProgressView removeFromSuperview];
    [self.hud setLabelText:NSLocalizedString(@"sending", nil)];
    [self.hud setMode:MBProgressHUDModeIndeterminate];
    
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [self sendToPhotoHouse:[coreShop getAllItemsWithNeedAddImages:YES]];
}

-(void)uploadImageManager:(UploadImageManager *)manager didUploadProgress:(CGFloat)progress
{
    if (self.hud && self.customProgressView) {
        [self.customProgressView setProgressDetail:progress];
    }
}

-(void)uploadImageManager:(UploadImageManager *)manager didUploadAllImagesProgress:(CGFloat)progress
{
    if (self.hud && self.customProgressView) {
        [self.customProgressView setProgressMain:progress];
    }
}



-(void)uploadImageManager:(UploadImageManager *)manager didCancelUpload:(PrintData *)printData
{
    [self backToStore];
}




#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSLog(@"click: %@", (buttonIndex == 1 ? @"ReUpload" : @"Cancel Upload"));
    if (buttonIndex == 1) {
        //[self.uploadImageQueue reUploadImage];
        [_uploadManager stopUpload];
//        [self backToStore];
    } /*else if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }*/
    
    //
    //reUploadCount = REUPLOAD_MAX_COUNT;
    
    
    if (alertView.tag == AlertTypeDeliveryOk) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GoToStoreSegueNotification object:nil];
    }
}



#pragma mark - Actions
- (IBAction)actionDeliveryButton:(UIButton *)sender
{
    if (self.response == nil) {
        self.response = [[ResponseGetDeliveries alloc] init];
    }
    
    //if ([self.response.deliveries count] > 0) {
        [self.popUpView setCenter:CGPointMake(CGRectGetMidX(self.view.frame),
                                             CGRectGetMaxY(self.deliveryButton.frame) + 176 + (CGRectGetHeight(self.popUpView.frame) / 2))];
        [self.popUpView setDelegate:self];
        [self.popUpView showTypesArray:[_response getAllCityUINames] withTypeInput:TypeInputCityDelivery];
        [self.popUpView setHidden:NO];
    //}
    
    // ChangeTitle
    [sender setTitle:NSLocalizedString(@"choose_delivery_city_btn", nil) forState:UIControlStateNormal];
}



- (IBAction)actionPaymentButton:(UIButton *)sender
{
    if (self.response == nil) {
        self.response = [[ResponseGetDeliveries alloc] init];
    }
    
    
    // Берем первый объект
    DeliveryType *deliveryType = [_deliveryCity.types firstObject];
    NSArray *payments = [_response getAllPaymentForUICityName:_deliveryCity.uiname andCodeDelivery:deliveryType.code];
    

    [self.popUpView setCenter:CGPointMake(CGRectGetMidX(self.view.frame),
                                          CGRectGetMaxY(self.deliveryButton.frame) + 236 + (CGRectGetHeight(self.popUpView.frame) / 2))];
    [self.popUpView setDelegate:self];
    [self.popUpView showTypesArray:payments withTypeInput:TypeInputTypePayment];
    [self.popUpView setHidden:NO];
    
    // Button
    [self.paymentButton setTitle:@"Выбирите из списка тип оплаты" forState:UIControlStateNormal];
}



- (IBAction)actionSendButton:(UIButton *)sender
{
    // FirstName
    NSString  *firstName = [(UITextField*)[self.textFields objectAtIndex:0] text];
    if ([firstName length] < 1) {
        [self showAlertView:NSLocalizedString(@"input_firstname", nil)];
        return;
    }
    
    
    // LastName
    NSString *lastName = [(UITextField*)[self.textFields objectAtIndex:1] text];
    if ([lastName length] < 1) {
        [self showAlertView:NSLocalizedString(@"input_lastname", nil)];
        return;
    }
    
    // Phone
    NSString *phone = [(UITextField*)[self.textFields objectAtIndex:TextFielTypePhone] text];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
    if ([phone length] < 10) {
        [self showAlertView:NSLocalizedString(@"input_phone", nil)];
        return;
    } else {
        phone = [(UITextField*)[self.textFields objectAtIndex:TextFielTypePhone] text];
    }
    
    NSString *address = [(UITextField*)[self.textFields objectAtIndex:2] text];
    if ([address length] < 10) {
        [self showAlertView:NSLocalizedString(@"input_address_is_too_short", nil)];
        return;
    }
    
    // Доставка
//#warning ToDO: UNComment
    if (_deliveryCity == nil) {
        //[self showAlertView:@"Выберите тип доставки"];
        //return;
        _deliveryCity = [_response getDefaultDeliveryCity];
    }
    
    
    //
    [sender setEnabled:NO];
    
    // Custom Progress
    CustomProgressView *customView = [[[NSBundle mainBundle] loadNibNamed:@"CustomProgressView" owner:self options:nil] firstObject];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeCustomView];
    [hud setLabelText:NSLocalizedString(@"upload_to_server", nil)];
    [hud setCustomView:customView];
    self.hud = hud;
    self.customProgressView = customView;

    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
        NSArray *allOrders = [coreShop getAllItemsWithNeedAddImages:YES];
        
        UploadImageManager *uploadManager = [[UploadImageManager alloc] initShopCartPrintDatas:allOrders];
        [uploadManager setDelegate:self];
        [uploadManager startUpload];
        _uploadManager = uploadManager;
    });
}



- (void) actionBackBarButton:(UIBarButtonItem *)sender
{
    // Идет ли активная отправка
    if (_uploadManager) {
        NSString *text = NSLocalizedString(@"do_you_want_cancel_upload", nil);
        [self showAlertUpload:NSLocalizedString(@"Attention", nil) andMessage:text];
    } else {
         [self backToStore];
    }
}




#pragma mark - Methods
- (void) showAlertView:(NSString*)text
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil)
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



- (void) showAlertUpload:(NSString *)title andMessage:(NSString *)uploadText
{
    __weak ShippingDeliveryViewController *weakSelf = self;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:uploadText
                                                   delegate:weakSelf
                                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          otherButtonTitles:NSLocalizedString(@"cancel_upload", nil), nil];
    [alert show];
    self.alertView = alert;
}



- (void) showAlertDeliveryOkView:(NSString*)text
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"complete", nil)
                                                    message:text
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert setTag:AlertTypeDeliveryOk];
    [alert show];
}




- (void) sendToPhotoHouse:(NSArray*)allOrders
{
    NSString  *firstName = [(UITextField*)[self.textFields objectAtIndex:0] text];
    NSString *lastName = [(UITextField*)[self.textFields objectAtIndex:1] text];
    NSString *phone = [(UITextField*)[self.textFields objectAtIndex:TextFielTypePhone] text];
    NSString *address = [(UITextField*)[self.textFields objectAtIndex:2] text];
    
    
    
    // Comments
    if ([self.informationTextView.text isEqualToString:DELIVERY_TEXT_DEFAULT]) {
        self.informationTextView.text = @"";
    }
    
    [self.hud hide:YES];
    self.hud = nil;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = NSLocalizedString(@"send_order", nil);
    self.hud = hud;
    
    
    
    // Delivery PrintData
    StoreItem *storeItem = [[StoreItem alloc] initDelivetyCity:_deliveryCity];
    PrintData *deliveryPrintData = [[PrintData alloc] initWithStoreItem:storeItem andUniqueNum:0];
    
    
    //
    PHouseApi *api = [[PHouseApi alloc] init];
    [api makeOrderFirstName:firstName
                andLastName:lastName
                   andPhone:phone
                 andAddress:address
                withComment:self.informationTextView.text
       andPhotoRecordsArray:allOrders
        andDeliveryPrintDta:deliveryPrintData
                andDelegate:self];
    
    // Analitics
    NSString *stringLabel = [NSString stringWithFormat:@"Send. Count: %li", (long)[allOrders count]];
    [[AnaliticsModel sharedManager] sendEventCategory:@"ShopDevivery" andAction:@"Action" andLabel:stringLabel withValue:[NSNumber numberWithInteger:[allOrders count]]];
}



- (void) postNotificationWithShopCartItemsCount:(NSInteger)itemsCount
{
    NSDictionary *userInfo = @{ShopCartItemsCountKey: [NSNumber numberWithInteger:itemsCount]};
    NSNotification *notification = [NSNotification notificationWithName:ShopCartItemsCountNotification object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


- (void) backToStore
{
    [self.navigationController popViewControllerAnimated:YES];
}




/*- (void) startQueueOperations:(NSArray*)operations
{
    UploadImageQueue *uploadQueue = [[UploadImageQueue alloc] init];
    [uploadQueue addPhotoRecordsArrayForUpload:operations];
    [uploadQueue setDelegate:self];
    self.uploadImageQueue = uploadQueue;
}



- (NSArray*)allOpertionWithRecords:(NSArray*)records {
    NSMutableArray *operations = [NSMutableArray array];
    NSInteger section = 0;
    NSInteger row = 0;
    
    for (NSArray *order in records) {
        row = 0;
        for (PhotoRecord *record in order) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:section];
            ImageUploader *imageUploader = [[ImageUploader alloc] initWithPhotoRecord:record andOrderInteger:index andBuyIndex:0 delegate:nil];
            [operations addObject:imageUploader];
            row++;
        }
        section++;
    }
    
    return operations;
}
*/


#pragma mark - PopUpListDelegate
- (void) popUpListView:(PopUpListView *)popUpView didSelectErlyInput:(NSString*)string withType:(TypeInput)typeInput
{
    //
    [popUpView setHidden:YES];
    
    
    //
    UITextField *textField;
    
    switch (typeInput) {
        case TypeInputPhone:
            textField = [self.textFields objectAtIndex:TextFielTypePhone];
            [textField setText:string];
            break;
            
        case TypeInputAddress:
            textField = [self.textFields objectAtIndex:TextFielTypeAddress];
            [textField setText:string];
            break;
            
        case TypeInputCityDelivery:
            [self.deliveryButton setTitle:[NSString stringWithFormat:@"%@ %@:", NSLocalizedString(@"select_the_type_of_delivery_for", nil), string] forState:UIControlStateNormal];
            _deliveryCity = [_response getDeliveryCityWithUICityName:string];
            [popUpView showTypesArray:_deliveryCity.types withTypeInput:TypeInputTypeDelivery];
            [popUpView setHidden:NO];
            break;
            
        case TypeInputTypeDelivery:
            _deliveryCity = [_response getDeliveryCityWithUICityName:_deliveryCity.uiname andCodeDelivery:string];
            _deliveryType = [_deliveryCity.types firstObject];
            [self.paymentButton setTitle:NSLocalizedString(@"select_the_type_of_payment", nil) forState:UIControlStateNormal];
            [self.deliveryButton setTitle:[NSString stringWithFormat:@"%@, %@ - %li %@", _deliveryCity.uiname, _deliveryType.deldescription, (unsigned long)_deliveryType.cost, NSLocalizedString(@"RUB", nil)] forState:UIControlStateNormal];
            break;
            
        case TypeInputTypePayment:
            _deliveryCity = [_response getDeliveryCityWithUICityName:_deliveryCity.uiname
                                                     andCodeDelivery:[(DeliveryType*)[_deliveryCity.types firstObject] code]
                                                    andPaymentUIName:string];
            _paymentType = [[[[_deliveryCity types] firstObject] payments] firstObject];
            [self.paymentButton setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"the_select_type_of_payment:", nil), string]
                                 forState:UIControlStateNormal];
            break;
    }
}






#pragma mark - PHouseApiDelegate
-(void)pHouseApi:(PHouseApi *)phApi didDeliveriesReceiveData:(PHResponse *)response
{
    _response = (ResponseGetDeliveries *)response;
    
    
    // Set NamesBlock
    void (^DeliveryButtonTitles)(void) = ^{
        _deliveryType = [_deliveryCity.types firstObject];
        [self.deliveryButton setTitle:[NSString stringWithFormat:@"%@, %@ - %li %@", _deliveryCity.uiname, _deliveryType.deldescription, (unsigned long)_deliveryType.cost, NSLocalizedString(@"RUB", nil)]
                             forState:UIControlStateNormal];
        
        // PaymentButton
        _paymentType = [_deliveryType.payments firstObject];
        [self.paymentButton setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"the_select_type_of_payment:", nil), _paymentType.uiname]
                         forState:UIControlStateNormal];
    };
    
    
    // Read Saved User
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    [coreProfile getDeliveryMemberWithBlock:^(NSString *uiCityName, NSString *deliveryCode, NSString *uiPaymentName) {
        if ([uiCityName isEqualToString:@""] || [deliveryCode isEqualToString:@""] || [uiPaymentName isEqualToString:@""])
        {
            _deliveryCity = [_response getDefaultDeliveryCity];
        }
        else
        {
            _deliveryCity = [_response getDeliveryCityWithUICityName:uiCityName andCodeDelivery:deliveryCode andPaymentUIName:uiPaymentName];
        }
        
        DeliveryButtonTitles();
    }];
}


-(void)pHouseApi:(PHouseApi *)phApi didLastAddress:(NSString *)address
{
    UITextField *addressTextField = [self.textFields objectAtIndex:TextFielTypeAddress];
    [addressTextField setText:address];
}


-(void)pHouseApi:(PHouseApi *)phApi didLastPhone:(NSString *)phone
{
    UITextField *phoneTextField = [self.textFields objectAtIndex:TextFielTypePhone];
    [phoneTextField setText:phone];
}

-(void)pHouseApi:(PHouseApi *)phApi didFailWithError:(NSError *)error
{
    // Analitics
    NSString *stringLabel = [NSString stringWithFormat:@"Error. Code: %li", (long)error.code];
    [[AnaliticsModel sharedManager] sendEventCategory:@"ShopDevivery" andAction:@"Action" andLabel:stringLabel withValue:[NSNumber numberWithInteger:error.code]];
    
    [self showAlertView:[error localizedDescription]];
    [self.sendButton setEnabled:YES];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (_hud) {
        [_hud hide:YES];
        _hud = nil;
    }
}

-(void)pHouseApi:(PHouseApi *)phApi didMakeOrderCompleteData:(PHResponse *)response
{
    // Analitics
    CoreDataProfile *coreProfile = [[CoreDataProfile alloc] init];
    NSString *profileId = [coreProfile profileID];
    NSString *stringLabel = [NSString stringWithFormat:@"Complete. UserID: %@", profileId];
    [[AnaliticsModel sharedManager] sendEventCategory:@"ShopDevivery" andAction:@"Action" andLabel:stringLabel withValue:[NSNumber numberWithInteger:[profileId integerValue]]];
    
    // Может быть открыт AlertView
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:YES];
    
    // Remove
//#warning Release: Uncomment This
    CoreDataShopCart *coreShop = [[CoreDataShopCart alloc] init];
    [coreShop removeAll];
    
    // Post Notification Cart Bajde
    [self postNotificationWithShopCartItemsCount:0];
    
    
    /*[self.sendButton setEnabled:YES];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];*/
    
    
    //
//    if (_paymentType.isPrePayment) {
//        [[UIApplication sharedApplication] openURL:[(ResponseMakeOrdes *)response payUrl]];
//    }
    
    
    // Local Notification
//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    [localNotification setSoundName:UILocalNotificationDefaultSoundName];
//    [localNotification setAlertBody:@"Загрузка загрузка завершена"];
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    
    [self showAlertDeliveryOkView:NSLocalizedString(@"your_order_was_delivered_information_about_your_order_sent_on_email", nil)];
    
    // Notifiactions
//    [[NSNotificationCenter defaultCenter] postNotificationName:GoToStoreSegueNotification object:nil];
    
    //[self performSegueWithIdentifier:GoToHistorySegue sender:self];
}

@end
