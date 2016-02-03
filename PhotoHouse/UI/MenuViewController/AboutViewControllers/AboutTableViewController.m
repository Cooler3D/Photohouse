//
//  AboutTableViewController.m
//  PhotoHouse
//
//  Created by Дмитрий Мартынов on 8/25/14.
//  Copyright (c) 2014 Дмитрий Мартынов. All rights reserved.
//

#import "AboutTableViewController.h"

#import "MenuTableViewController.h"

#import "UIViewController+ECSlidingViewController.h"
#import "ECSlidingViewController.h"


#import "SkinModel.h"
#import "AnaliticsModel.h"


NSString *const FACEBOOK    = @"https://www.facebook.com/pages/PhotoHouse/288745767977631?ref=aymt_homepage_panel";
NSString *const INSTAGRAM   = @"http://instagram.com/photohouse_media/";
NSString *const VK          = @"https://vk.com/club76594369";
NSString *const WEB         = @"http://photohouse.info/";



@interface AboutTableViewController ()
@property (assign, nonatomic) MDMenuSlideType menuSlideType;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;
@end



@implementation AboutTableViewController

/*- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}*/
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
    
    // Analitics
    [[AnaliticsModel sharedManager] setScreenName:@"About Screen"];
    
    // Navigation Bar
    SkinModel *model = [SkinModel sharedManager];
    // Фоновый цвет
    [self.navigationController.navigationBar setBarTintColor:[model headerColorWithViewController]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // Название
    self.navigationItem.titleView = [model headerForViewControllerWithTitle:NSLocalizedString(@"about_title", nil)];
    
    [self.menuBarButton setTintColor:[UIColor whiteColor]];
    
    
    
    // Slize Menu
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
    [self.view addGestureRecognizer:swipeOpen];
    
    UISwipeGestureRecognizer *swipeClose = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureSwipe:)];
    [swipeClose setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeClose];
    
    
    // Version
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString * versionBuildString = [NSString stringWithFormat:@"%@: %@ (%@)", NSLocalizedString(@"version", nil), appVersionString, appBuildString];
    [self.versionLabel setText:versionBuildString];
    
    
    [self.aboutTextView setText:NSLocalizedString(@"about_text", nil)];
    [self.aboutTextView setTextColor:[UIColor whiteColor]];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Gesture
- (void)gestureSwipe:(UISwipeGestureRecognizer *)gesture {
    //[self.revealViewController revealToggle:self];
    [self actionMenuBarButton:nil];
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


- (IBAction)actionVKButton:(UIButton *)sender {
    // Check Menu Opened
    if ([self hasMenuOpened]) {
        return;
    }
    
    
    NSURL *url = [NSURL URLWithString:VK];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)actionInstagramButton:(id)sender {
    NSURL *url = [NSURL URLWithString:INSTAGRAM];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)actionFaceBookButton:(id)sender {
    // Check Menu Opened
    if ([self hasMenuOpened]) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:FACEBOOK];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)actionWebButton:(id)sender {
    NSURL *url = [NSURL URLWithString:WEB];
    [[UIApplication sharedApplication] openURL:url];
}


#pragma mark - Private
- (BOOL) hasMenuOpened
{
    if (self.menuSlideType == MDMenuSlideTypeOpened) {
        [self actionMenuBarButton:self.menuBarButton];
        return YES;
    } else {
        return NO;
    }
}

@end
